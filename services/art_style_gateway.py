"""
Art Style Gateway - Multi-Provider Image Transformation

Applies artistic styles: Mosaic, Oil Painting, Watercolor, etc.

Providers (priority order):
1. Replicate Neural Neighbor Style Transfer (PRIMARY) - $0.063/run, fast
2. PiAPI Flux Kontext Style (FALLBACK 1) - $0.01+/run, 2-40s
3. Replicate Oil Painting Style (FALLBACK 2) - $0.08/run, ~11min
"""

import os
import base64
import asyncio
import re
import requests
import replicate
from abc import ABC, abstractmethod
from typing import Dict, Any

class ArtStyleProvider(ABC):
    """Base class for art style providers"""
    
    @abstractmethod
    async def transform(self, image_base64: str, style: str = "mosaic", **kwargs) -> Dict[str, Any]:
        pass
    
    @abstractmethod
    def get_name(self) -> str:
        pass
    
    @abstractmethod
    def get_timeout(self) -> int:
        pass

class ReplicatePhotoMakerArtProvider(ArtStyleProvider):
    """Replicate PhotoMaker with Artistic Prompts - PRIMARY provider (WORKING MODEL)"""
    
    def __init__(self, api_token: str):
        self.api_token = api_token
        os.environ["REPLICATE_API_TOKEN"] = api_token
    
    def get_name(self) -> str:
        return "Replicate PhotoMaker Art"
    
    def get_timeout(self) -> int:
        return 30
    
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
    
    async def transform(self, image_base64: str, style: str = "mosaic", **kwargs) -> Dict[str, Any]:
        try:
            print(f"🚀 [PRIMARY] Trying Replicate PhotoMaker Art (style={style})...")
            
            image_bytes, format_ext = self._decode_base64_image(image_base64)
            data_uri = f"data:image/{format_ext};base64,{base64.b64encode(image_bytes).decode()}"
            
            # Artistic style prompts
            style_prompts = {
                "mosaic": "person img as ancient mosaic art, colorful tiles, Byzantine style, artistic pattern",
                "oil": "person img as oil painting, Van Gogh style, impressionist brushstrokes, vibrant colors",
                "watercolor": "person img as watercolor painting, soft colors, artistic wash, traditional art style"
            }
            
            prompt = style_prompts.get(style.lower(), style_prompts["mosaic"])
            
            def _run():
                return replicate.run(
                    "tencentarc/photomaker:ddfc2b08d209f9fa8c1eca692712918bd449f695dabb4a958da31802a9570fe4",
                    input={
                        "input_image": data_uri,
                        "prompt": prompt,
                        "negative_prompt": "realistic, photo, ugly, distorted, modern",
                        "num_steps": 50,
                        "style_strength_ratio": 40,
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
            
            print(f"✅ Art Style SUCCESS via {self.get_name()} ({style}) - Returning URL")
            
            return {
                "success": True,
                "url": result_url,
                "provider": self.get_name()
            }
        
        except asyncio.TimeoutError:
            print(f"⏱️ {self.get_name()} timeout")
            return {"success": False, "error": "Timeout", "provider": self.get_name()}
        except Exception as e:
            print(f"❌ {self.get_name()} failed: {e}")
            return {"success": False, "error": str(e), "provider": self.get_name()}

class ReplicateOilPaintingProvider(ArtStyleProvider):
    """Replicate Oil Painting Style - FALLBACK 2 (slow but reliable)"""
    
    def __init__(self, api_token: str):
        self.api_token = api_token
        os.environ["REPLICATE_API_TOKEN"] = api_token
    
    def get_name(self) -> str:
        return "Replicate Oil Painting"
    
    def get_timeout(self) -> int:
        return 720  # 12 minutes (model is slow)
    
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
    
    async def transform(self, image_base64: str, style: str = "oil", **kwargs) -> Dict[str, Any]:
        try:
            print(f"🔄 [FALLBACK 2] Trying Replicate Oil Painting (SLOW - 11min)...")
            
            image_bytes, format_ext = self._decode_base64_image(image_base64)
            data_uri = f"data:image/{format_ext};base64,{base64.b64encode(image_bytes).decode()}"
            
            def _run():
                return replicate.run(
                    "jiupinjia/stylized-neural-painting-oil:latest",
                    input={"image": data_uri}
                )
            
            loop = asyncio.get_event_loop()
            output = await asyncio.wait_for(
                loop.run_in_executor(None, _run),
                timeout=self.get_timeout()
            )
            
            if not output:
                return {"success": False, "error": "Empty output", "provider": self.get_name()}
            
            result_url = output[0] if isinstance(output, list) else str(output)
            
            print(f"✅ SUCCESS via {self.get_name()} - Returning URL")
            
            return {
                "success": True,
                "url": result_url,
                "provider": self.get_name()
            }
        
        except asyncio.TimeoutError:
            print(f"⏱️ {self.get_name()} timeout after {self.get_timeout()}s")
            return {"success": False, "error": "Timeout", "provider": self.get_name()}
        except Exception as e:
            print(f"❌ {self.get_name()} failed: {e}")
            return {"success": False, "error": str(e), "provider": self.get_name()}

class ArtStyleGateway:
    """Main gateway with multi-provider fallback"""
    
    def __init__(self):
        self.replicate_token = os.environ.get('REPLICATE_API_TOKEN')
        
        self.providers = []
        
        if self.replicate_token:
            self.providers.append(ReplicatePhotoMakerArtProvider(self.replicate_token))
            self.providers.append(ReplicateOilPaintingProvider(self.replicate_token))
        
        print(f"🔌 Art Style Gateway initialized with {len(self.providers)} provider(s)")
    
    async def transform(self, image_base64: str, style: str = "mosaic") -> Dict[str, Any]:
        """
        Transform image to artistic style
        
        Args:
            image_base64: Base64 encoded image
            style: Art style (mosaic, oil, watercolor)
        
        Returns:
            Dict with success status, image data, and metadata
        """
        if not self.providers:
            return {"success": False, "error": "No providers configured (need REPLICATE_API_TOKEN)"}
        
        print(f"\n🎯 Art Style Gateway: Starting transformation (style={style})")
        
        for provider in self.providers:
            result = await provider.transform(image_base64, style)
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
art_style_gateway = ArtStyleGateway()
