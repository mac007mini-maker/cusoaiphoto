"""
HD Image Enhancement Gateway - Replicate Only

Strategy: Direct Replicate Real-ESRGAN (removing Huggingface bottleneck)
- Skips slow Huggingface Inference API (404 errors, 10s timeout)
- Uses Replicate Real-ESRGAN directly: Fast, reliable, $0.0019/run
- Future: Can add PiAPI or other providers if they support image enhancement
"""

import os
import base64
import re
import asyncio
import requests
import replicate
from typing import Dict, Any

class HDImageGateway:
    def __init__(self):
        self.replicate_token = os.environ.get('REPLICATE_API_TOKEN')
        
        # Provider status
        self.replicate_enabled = bool(self.replicate_token)
        
        # Provider priority (Replicate PRIMARY - only provider for now)
        self.providers = []
        if self.replicate_enabled:
            self.providers.append('replicate')
        
        print(f"🔌 HD Image Gateway initialized with {len(self.providers)} provider(s)")
        if self.providers:
            print(f"📊 Using Replicate Real-ESRGAN (direct, no Huggingface bottleneck)")
    
    def _decode_base64_image(self, base64_str: str) -> tuple:
        """Decode base64 string to bytes, returns (bytes, format_ext)"""
        data_uri_pattern = r'^data:image/(jpeg|jpg|png|gif|webp|bmp);base64,'
        match = re.match(data_uri_pattern, base64_str, re.IGNORECASE)
        
        format_ext = 'png'  # Default
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
    
    async def _enhance_replicate(self, image_base64: str, scale: int) -> Dict[str, Any]:
        """Enhance image using Replicate Real-ESRGAN"""
        try:
            print(f"🚀 [PRIMARY] Trying Replicate Real-ESRGAN (scale={scale}x)...")
            
            image_bytes, format_ext = self._decode_base64_image(image_base64)
            data_uri = f"data:image/{format_ext};base64,{base64.b64encode(image_bytes).decode()}"
            
            def _run_replicate():
                return replicate.run(
                    "nightmareai/real-esrgan:42fed1c4974146d4d2414e2be2c5277c7fcf05fcc3a73abf41610695738c1d7b",
                    input={
                        "image": data_uri,
                        "scale": scale,
                        "face_enhance": False
                    }
                )
            
            loop = asyncio.get_event_loop()
            output = await loop.run_in_executor(None, _run_replicate)
            
            if not output:
                print(f"❌ Replicate returned empty output")
                return {"success": False, "error": "Replicate returned no result"}
            
            result_url = str(output)
            print(f"✅ HD Image SUCCESS via Replicate (scale={scale}x) - Returning URL")
            
            return {
                "success": True,
                "url": result_url,
                "source": "replicate"
            }
        
        except Exception as e:
            print(f"❌ Replicate Real-ESRGAN failed: {e}")
            return {"success": False, "error": str(e)}
    
    
    async def enhance_image(self, image_base64: str, scale: int = 4) -> Dict[str, Any]:
        """
        Enhance image using Replicate Real-ESRGAN
        
        Args:
            image_base64: Base64 encoded image (with or without data URI)
            scale: Upscale factor (2, 4, etc.)
        
        Returns:
            Dict with success status, image data, and metadata
        """
        if not self.replicate_enabled:
            return {
                "success": False,
                "error": "Replicate not configured (need REPLICATE_API_TOKEN)"
            }
        
        print(f"\n🎯 HD Image Gateway: Starting enhancement (scale={scale}x)")
        
        # Use Replicate Real-ESRGAN directly (skip slow Huggingface)
        result = await self._enhance_replicate(image_base64, scale)
        
        if result.get('success'):
            return result
        else:
            return {
                "success": False,
                "error": f"Replicate Real-ESRGAN failed: {result.get('error', 'Unknown error')}"
            }

# Global gateway instance
hd_image_gateway = HDImageGateway()
