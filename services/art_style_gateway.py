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

class ReplicateNeuralNeighborProvider(ArtStyleProvider):
    """Replicate Neural Neighbor Style Transfer - PRIMARY provider"""
    
    def __init__(self, api_token: str):
        self.api_token = api_token
        os.environ["REPLICATE_API_TOKEN"] = api_token
    
    def get_name(self) -> str:
        return "Replicate Neural Neighbor"
    
    def get_timeout(self) -> int:
        return 60
    
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
            print(f"🚀 [PRIMARY] Trying Replicate Neural Neighbor (style={style})...")
            
            image_bytes, format_ext = self._decode_base64_image(image_base64)
            data_uri = f"data:image/{format_ext};base64,{base64.b64encode(image_bytes).decode()}"
            
            # Style image URLs (using public art images)
            style_images = {
                "mosaic": "https://upload.wikimedia.org/wikipedia/commons/thumb/0/00/Alexander_the_Great_mosaic.jpg/800px-Alexander_the_Great_mosaic.jpg",
                "oil": "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Van_Gogh_-_Starry_Night_-_Google_Art_Project.jpg/800px-Van_Gogh_-_Starry_Night_-_Google_Art_Project.jpg",
                "watercolor": "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f4/Paul_Cezanne_166.jpg/800px-Paul_Cezanne_166.jpg"
            }
            
            style_image = style_images.get(style.lower(), style_images["mosaic"])
            
            def _run():
                return replicate.run(
                    "nkolkin13/neuralneighborstyletransfer:7c7a8f9f69ff8e2f85c062aa97f3f3a839a5e06ca4f8a8c66eb7207c1673b54e",
                    input={
                        "image": data_uri,
                        "style_image": style_image
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
            
            print(f"✅ Art Style SUCCESS via {self.get_name()} ({style})")
            
            return {
                "success": True,
                "image": f"data:image/png;base64,{result_base64}",
                "message": f"Applied {style} art style",
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
            
            print(f"📥 Downloading result...")
            def _download():
                response = requests.get(result_url, timeout=30)
                response.raise_for_status()
                return response.content
            
            content = await loop.run_in_executor(None, _download)
            result_base64 = base64.b64encode(content).decode()
            
            print(f"✅ Art Style SUCCESS via {self.get_name()}")
            
            return {
                "success": True,
                "image": f"data:image/png;base64,{result_base64}",
                "message": "Applied oil painting style (fallback)",
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
            self.providers.append(ReplicateNeuralNeighborProvider(self.replicate_token))
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
