"""
Video Face Swap Gateway - Multi-Provider Video Processing

Swaps user's face into template videos using advanced AI

Providers (priority order):
1. VModel Pro (PRIMARY) - $0.03/sec, highest quality, 4K support, no file limits
2. Replicate Roop Face Swap (FALLBACK) - $0.11/run, proven reliability (28.7K+ runs)

Note: PiAPI removed - only supports video-to-video swap, not photo-to-video
"""

import os
import base64
import asyncio
import re
import requests
import replicate
import time
from abc import ABC, abstractmethod
from typing import Dict, Any, Optional

class VideoSwapProvider(ABC):
    """Base class for video swap providers"""
    
    @abstractmethod
    async def swap(self, user_image_base64: str, template_video_url: str, **kwargs) -> Dict[str, Any]:
        """
        Swap user's face into template video
        
        Args:
            user_image_base64: User's face image (base64)
            template_video_url: URL of template video
            **kwargs: Provider-specific parameters
            
        Returns:
            Dict with 'success', 'job_id', 'video_url', 'status', 'provider'
        """
        pass
    
    @abstractmethod
    def get_name(self) -> str:
        pass
    
    @abstractmethod
    def get_timeout(self) -> int:
        pass

class ReplicateRoopProvider(VideoSwapProvider):
    """Replicate Roop Face Swap - FALLBACK (proven, 28.7K+ runs, $0.11/video)"""
    
    def __init__(self, api_token: str):
        self.api_token = api_token
        os.environ["REPLICATE_API_TOKEN"] = api_token
    
    def get_name(self) -> str:
        return "Replicate Roop"
    
    def get_timeout(self) -> int:
        return 90  # 90 seconds
    
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
    
    async def swap(self, user_image_base64: str, template_video_url: str, **kwargs) -> Dict[str, Any]:
        try:
            print(f"🔄 [FALLBACK] Trying Replicate Roop...")
            
            image_bytes, format_ext = self._decode_base64_image(user_image_base64)
            data_uri = f"data:image/{format_ext};base64,{base64.b64encode(image_bytes).decode()}"
            
            def _run():
                return replicate.run(
                    "arabyai-replicate/roop_face_swap:11b6bf0f4e14d808f655e87e5448233cceff10a45f659d71539cafb7163b2e84",
                    input={
                        "swap_image": data_uri,
                        "target_video": template_video_url
                    }
                )
            
            loop = asyncio.get_event_loop()
            output = await asyncio.wait_for(
                loop.run_in_executor(None, _run),
                timeout=self.get_timeout()
            )
            
            if not output:
                return {"success": False, "error": "Empty output", "provider": self.get_name()}
            
            video_url = output if isinstance(output, str) else (output[0] if isinstance(output, list) else str(output))
            
            print(f"✅ Video Swap SUCCESS via {self.get_name()}")
            
            return {
                "success": True,
                "video_url": video_url,
                "status": "completed",
                "provider": self.get_name()
            }
        
        except asyncio.TimeoutError:
            print(f"⏱️ {self.get_name()} timeout")
            return {"success": False, "error": "Timeout", "provider": self.get_name()}
        except Exception as e:
            error_msg = str(e)
            print(f"❌ {self.get_name()} failed: {error_msg}")
            
            # Log Replicate error details
            print(f"   Error type: {type(e).__name__}")
            if hasattr(e, 'status'):
                print(f"   Status: {getattr(e, 'status', 'N/A')}")
            if hasattr(e, 'detail'):
                print(f"   Detail: {getattr(e, 'detail', 'N/A')}")
            
            return {"success": False, "error": error_msg, "provider": self.get_name()}

class VModelProProvider(VideoSwapProvider):
    """VModel Pro - PRIMARY (highest quality, 4K support, no file limits)"""
    
    def __init__(self, api_token: str):
        self.api_token = api_token
        self.base_url = "https://api.vmodel.ai/api/tasks/v1"
    
    def get_name(self) -> str:
        return "VModel Pro"
    
    def get_timeout(self) -> int:
        return 180  # 3 minutes for high quality
    
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
    
    async def swap(self, user_image_base64: str, template_video_url: str, **kwargs) -> Dict[str, Any]:
        try:
            print(f"🚀 [PRIMARY] Trying VModel Pro...")
            
            image_bytes, format_ext = self._decode_base64_image(user_image_base64)
            user_image_data_uri = f"data:image/{format_ext};base64,{base64.b64encode(image_bytes).decode()}"
            
            headers = {
                'Authorization': f'Bearer {self.api_token}',
                'Content-Type': 'application/json'
            }
            
            payload = {
                "version": "85e248d268bcc04f5302cf9645663c2c12acd03c953ec1a4bbfdc252a65bddc0",
                "input": {
                    "source": user_image_data_uri,
                    "target": template_video_url,
                    "keep_fps": False,
                    "disable_safety_checker": False
                }
            }
            
            def _submit():
                response = requests.post(
                    f"{self.base_url}/create",
                    headers=headers,
                    json=payload,
                    timeout=30
                )
                response.raise_for_status()
                return response.json()
            
            loop = asyncio.get_event_loop()
            result = await loop.run_in_executor(None, _submit)
            
            task_id = result.get('id')  # VModel uses 'id' not 'task_id'
            if not task_id:
                return {
                    "success": False,
                    "error": "No task ID in response",
                    "provider": self.get_name()
                }
            
            print(f"📋 VModel task submitted: {task_id}")
            
            # Poll for completion
            max_attempts = 90  # 3 minutes max
            for attempt in range(max_attempts):
                await asyncio.sleep(2)
                
                def _check_status():
                    status_response = requests.get(
                        f"{self.base_url}/status/{task_id}",
                        headers=headers,
                        timeout=10
                    )
                    status_response.raise_for_status()
                    return status_response.json()
                
                status_result = await loop.run_in_executor(None, _check_status)
                task_status = status_result.get('status')
                
                if task_status == 'succeeded':
                    output = status_result.get('output')
                    if not output or not isinstance(output, list) or len(output) == 0:
                        return {
                            "success": False,
                            "error": "No video URL in output",
                            "provider": self.get_name()
                        }
                    
                    video_url = output[0]
                    print(f"✅ Video Swap SUCCESS via {self.get_name()}")
                    
                    return {
                        "success": True,
                        "video_url": video_url,
                        "job_id": task_id,
                        "status": "completed",
                        "provider": self.get_name()
                    }
                
                elif task_status == 'failed':
                    error_msg = status_result.get('error', 'Unknown error')
                    return {
                        "success": False,
                        "error": error_msg,
                        "provider": self.get_name()
                    }
                
                print(f"⏳ Attempt {attempt + 1}/{max_attempts}: Status = {task_status}")
            
            return {
                "success": False,
                "error": "Timeout waiting for video processing",
                "provider": self.get_name()
            }
        
        except asyncio.TimeoutError:
            print(f"⏱️ {self.get_name()} timeout")
            return {"success": False, "error": "Timeout", "provider": self.get_name()}
        except Exception as e:
            error_msg = str(e)
            print(f"❌ {self.get_name()} failed: {error_msg}")
            
            # Log VModel error details for debugging
            if hasattr(e, 'response'):
                response = getattr(e, 'response', None)
                if response:
                    status_code = getattr(response, 'status_code', 'N/A')
                    response_text = getattr(response, 'text', 'N/A')
                    print(f"   HTTP Status: {status_code}")
                    print(f"   Response: {response_text[:500]}")
            
            return {"success": False, "error": error_msg, "provider": self.get_name()}

class VideoSwapGateway:
    """Main gateway with multi-provider fallback (VModel PRIMARY → Replicate FALLBACK)"""
    
    def __init__(self):
        self.replicate_token = os.environ.get('REPLICATE_API_TOKEN')
        self.vmodel_token = os.environ.get('VMODEL_API_TOKEN')
        
        self.providers = []
        
        # VModel Pro: PRIMARY - Best quality (4K), no file limits, $0.03/sec
        if self.vmodel_token:
            self.providers.append(VModelProProvider(self.vmodel_token))
        
        # Replicate Roop: FALLBACK - Proven reliability, flat $0.11/video
        if self.replicate_token:
            self.providers.append(ReplicateRoopProvider(self.replicate_token))
        
        print(f"🔌 Video Swap Gateway initialized with {len(self.providers)} provider(s)")
        if self.providers:
            provider_names = " → ".join([p.get_name() for p in self.providers])
            print(f"📊 Video Swap Provider priority: {provider_names}")
    
    async def swap_video(self, user_image_base64: str, template_video_url: str) -> Dict[str, Any]:
        """
        Swap user's face into template video
        
        Args:
            user_image_base64: User's face image (base64)
            template_video_url: URL of template video from Supabase
        
        Returns:
            Dict with success status, video_url, and metadata
        """
        if not self.providers:
            return {
                "success": False,
                "error": "No providers configured (need API keys)"
            }
        
        print(f"\n🎯 Video Swap Gateway: Starting swap")
        print(f"📹 Template: {template_video_url}")
        
        for provider in self.providers:
            result = await provider.swap(user_image_base64, template_video_url)
            if result.get('success'):
                return result
            else:
                error_detail = result.get('error', 'Unknown error')
                print(f"⚠️ {provider.get_name()} failed: {error_detail}")
                print(f"   Trying next provider...")
                continue
        
        return {
            "success": False,
            "error": "All providers failed",
            "providers_tried": [p.get_name() for p in self.providers]
        }

# Global instance
video_swap_gateway = VideoSwapGateway()
