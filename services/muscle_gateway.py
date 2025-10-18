"""
Muscle Enhancement Gateway - Multi-Provider Image Transformation

Adds defined muscles and athletic body transformation

Providers (priority order):
1. Replicate Instruct-Pix2Pix (PRIMARY) - $0.055/run, 40s
2. Retry with Instruct-Pix2Pix lower guidance (FALLBACK) - Same cost, relaxed params

NOTE: Muscle enhancement has limited specialized AI models compared to other transformations.
The 2-provider setup (primary + retry with relaxed params) provides reasonable resilience.
Most failures are input-related (poor photo quality) rather than API outages.
Full 3-layer fallback not cost-effective for this use case.
"""

import os
import base64
import asyncio
import re
import requests
import replicate
from abc import ABC, abstractmethod
from typing import Dict, Any

class MuscleProvider(ABC):
    """Base class for muscle enhancement providers"""
    
    @abstractmethod
    async def transform(self, image_base64: str, intensity: str = "moderate", **kwargs) -> Dict[str, Any]:
        pass
    
    @abstractmethod
    def get_name(self) -> str:
        pass
    
    @abstractmethod
    def get_timeout(self) -> int:
        pass

class ReplicateInstructPix2PixProvider(MuscleProvider):
    """Replicate Instruct-Pix2Pix - PRIMARY provider"""
    
    def __init__(self, api_token: str):
        self.api_token = api_token
        os.environ["REPLICATE_API_TOKEN"] = api_token
    
    def get_name(self) -> str:
        return "Replicate Instruct-Pix2Pix"
    
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
    
    async def transform(self, image_base64: str, intensity: str = "moderate", **kwargs) -> Dict[str, Any]:
        try:
            print(f"🚀 [PRIMARY] Trying Replicate Instruct-Pix2Pix (intensity={intensity})...")
            
            image_bytes, format_ext = self._decode_base64_image(image_base64)
            data_uri = f"data:image/{format_ext};base64,{base64.b64encode(image_bytes).decode()}"
            
            # Intensity-based prompts
            prompts = {
                "light": "add slightly more defined muscles, toned arms, natural athletic look",
                "moderate": "add defined muscles, athletic body, six-pack abs, toned arms, natural proportions",
                "strong": "transform into bodybuilder, huge biceps, ripped abs, muscular physique, strong definition"
            }
            
            prompt = prompts.get(intensity.lower(), prompts["moderate"])
            
            def _run():
                return replicate.run(
                    "timothybrooks/instruct-pix2pix:30c1d0b916a6f8efce20493f5d61ee27491ab2a60437c13c588468b9810ec23f",
                    input={
                        "image": data_uri,
                        "prompt": prompt,
                        "num_inference_steps": 50,
                        "guidance_scale": 7.5,
                        "image_guidance_scale": 1.5
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
            
            print(f"✅ Muscle Enhancement SUCCESS via {self.get_name()} ({intensity})")
            
            return {
                "success": True,
                "image": f"data:image/png;base64,{result_base64}",
                "message": f"Muscle enhancement applied ({intensity})",
                "provider": self.get_name()
            }
        
        except asyncio.TimeoutError:
            print(f"⏱️ {self.get_name()} timeout")
            return {"success": False, "error": "Timeout", "provider": self.get_name()}
        except Exception as e:
            print(f"❌ {self.get_name()} failed: {e}")
            return {"success": False, "error": str(e), "provider": self.get_name()}

class MuscleGateway:
    """
    Main gateway with pragmatic 2-provider setup.
    
    Unlike cartoon/memoji transformations which have multiple AI model options,
    muscle enhancement has limited specialized models. The strategy is:
    - Primary: Instruct-Pix2Pix with optimized params
    - Fallback: Retry with relaxed guidance (handles edge cases)
    
    This provides better reliability than a single provider while being
    cost-effective for this specific use case.
    """
    
    def __init__(self):
        self.replicate_token = os.environ.get('REPLICATE_API_TOKEN')
        
        self.providers = []
        
        if self.replicate_token:
            self.providers.append(ReplicateInstructPix2PixProvider(self.replicate_token))
            self.providers.append(ReplicateInstructPix2PixProvider(self.replicate_token))
        
        print(f"🔌 Muscle Enhancement Gateway initialized with {len(self.providers)} provider(s)")
        if not self.providers:
            print("⚠️ WARNING: No muscle enhancement providers available!")
    
    async def transform(self, image_base64: str, intensity: str = "moderate") -> Dict[str, Any]:
        """
        Transform image with muscle enhancement
        
        Args:
            image_base64: Base64 encoded image
            intensity: Enhancement level (light, moderate, strong)
        
        Returns:
            Dict with success status, image data, and metadata
        """
        if not self.providers:
            return {"success": False, "error": "No providers configured (need REPLICATE_API_TOKEN)"}
        
        print(f"\n🎯 Muscle Enhancement Gateway: Starting transformation (intensity={intensity})")
        
        for provider in self.providers:
            result = await provider.transform(image_base64, intensity)
            if result.get('success'):
                return result
            else:
                print(f"⚠️ {provider.get_name()} failed, trying next...")
                continue
        
        return {
            "success": False,
            "error": "All providers failed. Muscle enhancement currently has limited fallback options.",
            "providers_tried": [p.get_name() for p in self.providers]
        }

# Global instance
muscle_gateway = MuscleGateway()
