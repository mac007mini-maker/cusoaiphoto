"""
Animal-Toon Gateway - Multi-Provider Image Transformation

Transforms user photos into cute animal cartoon characters (bunny, cat, fox, etc.)

Providers (priority order):
1. Replicate PhotoMaker (PRIMARY) - $0.004/run, 5s, best ID preservation
2. Replicate InstantID + LoRA (FALLBACK 1) - $0.069/run, 71s
3. PiAPI Flux Furry LoRA (FALLBACK 2) - $0.02/run, 10s
"""

import os
import base64
import asyncio
import re
import requests
import replicate
from abc import ABC, abstractmethod
from typing import Dict, Any

class AnimalToonProvider(ABC):
    """Base class for animal-toon providers"""
    
    @abstractmethod
    async def transform(self, image_base64: str, animal_type: str = "bunny", **kwargs) -> Dict[str, Any]:
        """
        Transform image to animal-toon style
        
        Args:
            image_base64: Base64 encoded image
            animal_type: Type of animal (bunny, cat, fox, etc.)
            **kwargs: Provider-specific parameters
            
        Returns:
            Dict with 'success', 'image', 'message', 'provider'
        """
        pass
    
    @abstractmethod
    def get_name(self) -> str:
        """Return provider name"""
        pass
    
    @abstractmethod
    def get_timeout(self) -> int:
        """Return provider timeout in seconds"""
        pass

class ReplicatePhotoMakerProvider(AnimalToonProvider):
    """Replicate PhotoMaker - PRIMARY provider"""
    
    def __init__(self, api_token: str):
        self.api_token = api_token
        os.environ["REPLICATE_API_TOKEN"] = api_token
    
    def get_name(self) -> str:
        return "Replicate PhotoMaker"
    
    def get_timeout(self) -> int:
        return 30  # Fast model
    
    def _decode_base64_image(self, base64_str: str) -> tuple:
        """Decode base64 string to bytes, returns (bytes, format_ext)"""
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
    
    async def transform(self, image_base64: str, animal_type: str = "bunny", **kwargs) -> Dict[str, Any]:
        """Transform using PhotoMaker"""
        try:
            print(f"🚀 [PRIMARY] Trying Replicate PhotoMaker (animal={animal_type})...")
            
            image_bytes, format_ext = self._decode_base64_image(image_base64)
            data_uri = f"data:image/{format_ext};base64,{base64.b64encode(image_bytes).decode()}"
            
            # Animal-specific prompts
            animal_prompts = {
                "bunny": "person img as cute cartoon bunny character, fluffy ears, soft fur, 3D animation style, kawaii",
                "cat": "person img as cute cartoon cat character, whiskers, feline features, anime style",
                "fox": "person img as cute cartoon fox character, fluffy tail, orange fur, digital art",
                "dog": "person img as cute cartoon dog character, friendly face, soft features, 3D style",
                "bear": "person img as cute cartoon bear character, fluffy, soft features, kawaii style"
            }
            
            prompt = animal_prompts.get(animal_type.lower(), animal_prompts["bunny"])
            
            def _run():
                return replicate.run(
                    "tencentarc/photomaker:ddfc2b08d209f9fa8c1eca692712918bd449f695dabb4a958da31802a9570fe4",
                    input={
                        "input_image": data_uri,
                        "prompt": prompt,
                        "negative_prompt": "deformed hands, nsfw, watermark, ugly, distorted face, bad anatomy",
                        "num_steps": 50,
                        "style_strength_ratio": 35,
                        "num_outputs": 1
                    }
                )
            
            loop = asyncio.get_event_loop()
            output = await asyncio.wait_for(
                loop.run_in_executor(None, _run),
                timeout=self.get_timeout()
            )
            
            if not output:
                return {"success": False, "error": "PhotoMaker returned empty output", "provider": self.get_name()}
            
            # Get result URL
            result_url = output[0] if isinstance(output, list) else str(output)
            
            # Download and convert to base64
            print(f"📥 Downloading result...")
            def _download():
                response = requests.get(result_url, timeout=30)
                response.raise_for_status()
                return response.content
            
            content = await loop.run_in_executor(None, _download)
            result_base64 = base64.b64encode(content).decode()
            
            print(f"✅ Animal-Toon SUCCESS via {self.get_name()} ({animal_type})")
            
            return {
                "success": True,
                "image": f"data:image/png;base64,{result_base64}",
                "message": f"Transformed to {animal_type} character",
                "provider": self.get_name()
            }
        
        except asyncio.TimeoutError:
            print(f"⏱️ {self.get_name()} timeout after {self.get_timeout()}s")
            return {"success": False, "error": "Timeout", "provider": self.get_name()}
        except Exception as e:
            print(f"❌ {self.get_name()} failed: {e}")
            return {"success": False, "error": str(e), "provider": self.get_name()}

class ReplicateInstantIDProvider(AnimalToonProvider):
    """Replicate InstantID - FALLBACK 1 provider"""
    
    def __init__(self, api_token: str):
        self.api_token = api_token
        os.environ["REPLICATE_API_TOKEN"] = api_token
    
    def get_name(self) -> str:
        return "Replicate InstantID"
    
    def get_timeout(self) -> int:
        return 90
    
    def _decode_base64_image(self, base64_str: str) -> tuple:
        """Decode base64 string to bytes, returns (bytes, format_ext)"""
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
    
    async def transform(self, image_base64: str, animal_type: str = "bunny", **kwargs) -> Dict[str, Any]:
        """Transform using InstantID + LoRA"""
        try:
            print(f"🔄 [FALLBACK 1] Trying Replicate InstantID (animal={animal_type})...")
            
            image_bytes, format_ext = self._decode_base64_image(image_base64)
            data_uri = f"data:image/{format_ext};base64,{base64.b64encode(image_bytes).decode()}"
            
            prompt = f"{animal_type} character, anthropomorphic, cute, furry art, digital painting, vibrant colors"
            
            def _run():
                return replicate.run(
                    "zsxkib/instant-id:c45c1a7c84b47c9e7a1107f1c978d265dfb126cdddc3246c87077c2c57e07e2b",
                    input={
                        "image": data_uri,
                        "prompt": prompt,
                        "width": 1024,
                        "height": 1024,
                        "negative_prompt": "realistic, photo, ugly, distorted, nsfw",
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
                return {"success": False, "error": "InstantID returned empty output", "provider": self.get_name()}
            
            result_url = output[0] if isinstance(output, list) else str(output)
            
            print(f"📥 Downloading result...")
            def _download():
                response = requests.get(result_url, timeout=30)
                response.raise_for_status()
                return response.content
            
            content = await loop.run_in_executor(None, _download)
            result_base64 = base64.b64encode(content).decode()
            
            print(f"✅ Animal-Toon SUCCESS via {self.get_name()} ({animal_type})")
            
            return {
                "success": True,
                "image": f"data:image/png;base64,{result_base64}",
                "message": f"Transformed to {animal_type} character (fallback)",
                "provider": self.get_name()
            }
        
        except asyncio.TimeoutError:
            print(f"⏱️ {self.get_name()} timeout after {self.get_timeout()}s")
            return {"success": False, "error": "Timeout", "provider": self.get_name()}
        except Exception as e:
            print(f"❌ {self.get_name()} failed: {e}")
            return {"success": False, "error": str(e), "provider": self.get_name()}

class PiAPIFluxProvider(AnimalToonProvider):
    """PiAPI Flux Furry LoRA - FALLBACK 2 provider"""
    
    def __init__(self, api_key: str):
        self.api_key = api_key
    
    def get_name(self) -> str:
        return "PiAPI Flux"
    
    def get_timeout(self) -> int:
        return 20
    
    async def transform(self, image_base64: str, animal_type: str = "bunny", **kwargs) -> Dict[str, Any]:
        """Transform using PiAPI Flux"""
        try:
            print(f"🔄 [FALLBACK 2] Trying PiAPI Flux (animal={animal_type})...")
            
            # PiAPI implementation would go here
            # For now, return not implemented
            return {
                "success": False,
                "error": "PiAPI Flux not yet implemented",
                "provider": self.get_name()
            }
        
        except Exception as e:
            print(f"❌ {self.get_name()} failed: {e}")
            return {"success": False, "error": str(e), "provider": self.get_name()}

class AnimalToonGateway:
    """Main gateway with multi-provider fallback"""
    
    def __init__(self):
        self.replicate_token = os.environ.get('REPLICATE_API_TOKEN')
        self.piapi_key = os.environ.get('PIAPI_API_KEY')
        
        # Initialize providers
        self.providers = []
        
        if self.replicate_token:
            self.providers.append(ReplicatePhotoMakerProvider(self.replicate_token))
            self.providers.append(ReplicateInstantIDProvider(self.replicate_token))
        
        if self.piapi_key:
            self.providers.append(PiAPIFluxProvider(self.piapi_key))
        
        print(f"🔌 Animal-Toon Gateway initialized with {len(self.providers)} provider(s)")
        for i, provider in enumerate(self.providers, 1):
            print(f"  {i}. {provider.get_name()} (timeout={provider.get_timeout()}s)")
    
    async def transform(self, image_base64: str, animal_type: str = "bunny") -> Dict[str, Any]:
        """
        Transform image to animal-toon style with fallback
        
        Args:
            image_base64: Base64 encoded image (with or without data URI)
            animal_type: Type of animal (bunny, cat, fox, dog, bear)
        
        Returns:
            Dict with success status, image data, and metadata
        """
        if not self.providers:
            return {
                "success": False,
                "error": "No providers configured (need REPLICATE_API_TOKEN or PIAPI_API_KEY)"
            }
        
        print(f"\n🎯 Animal-Toon Gateway: Starting transformation (animal={animal_type})")
        print(f"📊 Available providers: {[p.get_name() for p in self.providers]}")
        
        # Try each provider in order
        for provider in self.providers:
            result = await provider.transform(image_base64, animal_type)
            
            if result.get('success'):
                return result
            else:
                print(f"⚠️ {provider.get_name()} failed, trying next provider...")
                continue
        
        # All providers failed
        return {
            "success": False,
            "error": "All providers failed to transform image",
            "providers_tried": [p.get_name() for p in self.providers]
        }

# Global gateway instance
animal_toon_gateway = AnimalToonGateway()
