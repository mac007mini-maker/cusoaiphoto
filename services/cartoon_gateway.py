"""
Cartoon/3D Toon Gateway - Multi-Provider Image Transformation

Transforms user photos into Disney/Pixar-style cartoon characters

Providers (priority order):
1. Replicate PhotoMaker-Style (PRIMARY) - $0.007/run, 8s
2. Replicate InstantID Artistic (FALLBACK 1) - $0.069/run, 71s
3. PiAPI Flux Cartoon LoRA (FALLBACK 2) - $0.02/run, 10s
"""

import os
import base64
import asyncio
import re
import requests
import replicate
from abc import ABC, abstractmethod
from typing import Dict, Any

class CartoonProvider(ABC):
    """Base class for cartoon providers"""
    
    @abstractmethod
    async def transform(self, image_base64: str, **kwargs) -> Dict[str, Any]:
        pass
    
    @abstractmethod
    def get_name(self) -> str:
        pass
    
    @abstractmethod
    def get_timeout(self) -> int:
        pass

class ReplicatePhotoMakerStyleProvider(CartoonProvider):
    """Replicate PhotoMaker-Style - PRIMARY provider"""
    
    def __init__(self, api_token: str):
        self.api_token = api_token
        os.environ["REPLICATE_API_TOKEN"] = api_token
    
    def get_name(self) -> str:
        return "Replicate PhotoMaker-Style"
    
    def get_timeout(self) -> int:
        return 20
    
    def _decode_base64_image(self, base64_str: str) -> tuple:
        data_uri_pattern = r'^data:image/(jpeg|jpg|png|gif|webp|bmp);base64,'
        match = re.match(data_uri_pattern, base64_str, re.IGNORECASE)
        
        format_ext = 'png'
        if match:
            format_ext = match.group(1).lower()
            if format_ext == 'jpg':
                format_ext = 'jpeg'
            base64_str = re.sub(data_uri_pattern, '', base64_str, flags=re.IGNORECASE)
        
        base64_str = base64_str.strip().replace('\n', '').replace('\r', '').replace(' ', '')
        padding_needed = len(base64_str) % 4
        if padding_needed:
            base64_str += '=' * (4 - padding_needed)
        
        image_bytes = base64.b64decode(base64_str)
        return (image_bytes, format_ext)
    
    async def transform(self, image_base64: str, **kwargs) -> Dict[str, Any]:
        try:
            print(f"🚀 [PRIMARY] Trying Replicate PhotoMaker-Style (Cartoon)...")
            
            image_bytes, format_ext = self._decode_base64_image(image_base64)
            data_uri = f"data:image/{format_ext};base64,{base64.b64encode(image_bytes).decode()}"
            
            prompt = "person img as pixar character, 3D cartoon, vibrant colors, studio lighting, animated movie style"
            
            def _run():
                return replicate.run(
                    "tencentarc/photomaker-style:467d062309da518648ba89d226490e02b8ed09b5abc15026e54e31c5a8cd0769",
                    input={
                        "input_image": data_uri,
                        "prompt": prompt,
                        "style_name": "Cartoon",
                        "negative_prompt": "realistic, photo, blurry, ugly, distorted",
                        "num_steps": 30,
                        "style_strength_ratio": 30,
                        "num_outputs": 1
                    }
                )
            
            loop = asyncio.get_event_loop()
            output = await asyncio.wait_for(
                loop.run_in_executor(None, _run),
                timeout=self.get_timeout()
            )
            
            if not output:
                return {"success": False, "error": "Empty output", "provider": self.get_name()}
            
            result_url = output[0] if isinstance(output, list) else str(output)
            
            print(f"📥 Downloading result...")
            def _download():
                response = requests.get(result_url, timeout=30)
                response.raise_for_status()
                return response.content
            
            content = await loop.run_in_executor(None, _download)
            result_base64 = base64.b64encode(content).decode()
            
            print(f"✅ Cartoon SUCCESS via {self.get_name()}")
            
            return {
                "success": True,
                "image": f"data:image/png;base64,{result_base64}",
                "message": "Transformed to cartoon character",
                "provider": self.get_name()
            }
        
        except asyncio.TimeoutError:
            print(f"⏱️ {self.get_name()} timeout")
            return {"success": False, "error": "Timeout", "provider": self.get_name()}
        except Exception as e:
            print(f"❌ {self.get_name()} failed: {e}")
            return {"success": False, "error": str(e), "provider": self.get_name()}

class ReplicateInstantIDArtisticProvider(CartoonProvider):
    """Replicate InstantID Artistic - FALLBACK 1"""
    
    def __init__(self, api_token: str):
        self.api_token = api_token
        os.environ["REPLICATE_API_TOKEN"] = api_token
    
    def get_name(self) -> str:
        return "Replicate InstantID Artistic"
    
    def get_timeout(self) -> int:
        return 90
    
    def _decode_base64_image(self, base64_str: str) -> tuple:
        data_uri_pattern = r'^data:image/(jpeg|jpg|png|gif|webp|bmp);base64,'
        match = re.match(data_uri_pattern, base64_str, re.IGNORECASE)
        
        format_ext = 'png'
        if match:
            format_ext = match.group(1).lower()
            if format_ext == 'jpg':
                format_ext = 'jpeg'
            base64_str = re.sub(data_uri_pattern, '', base64_str, flags=re.IGNORECASE)
        
        base64_str = base64_str.strip().replace('\n', '').replace('\r', '').replace(' ', '')
        padding_needed = len(base64_str) % 4
        if padding_needed:
            base64_str += '=' * (4 - padding_needed)
        
        image_bytes = base64.b64decode(base64_str)
        return (image_bytes, format_ext)
    
    async def transform(self, image_base64: str, **kwargs) -> Dict[str, Any]:
        try:
            print(f"🔄 [FALLBACK 1] Trying Replicate InstantID Artistic...")
            
            image_bytes, format_ext = self._decode_base64_image(image_base64)
            data_uri = f"data:image/{format_ext};base64,{base64.b64encode(image_bytes).decode()}"
            
            prompt = "a person img as a cute 3D cartoon character, disney style, colorful, vibrant"
            
            def _run():
                return replicate.run(
                    "grandlineai/instant-id-artistic:latest",
                    input={
                        "image": data_uri,
                        "prompt": prompt,
                        "width": 1024,
                        "height": 1024,
                        "negative_prompt": "realistic, photo, dark, ugly",
                        "num_inference_steps": 30,
                        "guidance_scale": 5
                    }
                )
            
            loop = asyncio.get_event_loop()
            output = await asyncio.wait_for(
                loop.run_in_executor(None, _run),
                timeout=self.get_timeout()
            )
            
            if not output:
                return {"success": False, "error": "Empty output", "provider": self.get_name()}
            
            result_url = output[0] if isinstance(output, list) else str(output)
            
            print(f"📥 Downloading result...")
            def _download():
                response = requests.get(result_url, timeout=30)
                response.raise_for_status()
                return response.content
            
            content = await loop.run_in_executor(None, _download)
            result_base64 = base64.b64encode(content).decode()
            
            print(f"✅ Cartoon SUCCESS via {self.get_name()}")
            
            return {
                "success": True,
                "image": f"data:image/png;base64,{result_base64}",
                "message": "Transformed to cartoon (fallback)",
                "provider": self.get_name()
            }
        
        except asyncio.TimeoutError:
            print(f"⏱️ {self.get_name()} timeout")
            return {"success": False, "error": "Timeout", "provider": self.get_name()}
        except Exception as e:
            print(f"❌ {self.get_name()} failed: {e}")
            return {"success": False, "error": str(e), "provider": self.get_name()}

class CartoonGateway:
    """Main gateway with multi-provider fallback"""
    
    def __init__(self):
        self.replicate_token = os.environ.get('REPLICATE_API_TOKEN')
        
        self.providers = []
        
        if self.replicate_token:
            self.providers.append(ReplicatePhotoMakerStyleProvider(self.replicate_token))
            self.providers.append(ReplicateInstantIDArtisticProvider(self.replicate_token))
        
        print(f"🔌 Cartoon Gateway initialized with {len(self.providers)} provider(s)")
    
    async def transform(self, image_base64: str) -> Dict[str, Any]:
        if not self.providers:
            return {"success": False, "error": "No providers configured"}
        
        print(f"\n🎯 Cartoon Gateway: Starting transformation")
        
        for provider in self.providers:
            result = await provider.transform(image_base64)
            if result.get('success'):
                return result
            else:
                print(f"⚠️ {provider.get_name()} failed, trying next...")
                continue
        
        return {
            "success": False,
            "error": "All providers failed",
            "providers_tried": [p.get_name() for p in self.providers]
        }

# Global instance
cartoon_gateway = CartoonGateway()
