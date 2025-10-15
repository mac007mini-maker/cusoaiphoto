"""
AI Image Processing Service with Intelligent Fallback Strategy

HD Image Enhancement Strategy:
1. PRIMARY: Huggingface Inference API (Pro) - 10s timeout
   - 4x scale: Stable Diffusion x4 Upscaler (best quality)
   - 2x scale: Real-ESRGAN Inference API
2. FALLBACK: Replicate Real-ESRGAN (fast, reliable, $0.0019/run)
3. LAST RESORT: Huggingface Space (free backup)

Other features use: Replicate (Primary) → Huggingface Spaces (Backup)
All blocking I/O runs on loop's default executor (shared, no blocking shutdown)
"""

import os
import base64
import io
import tempfile
import re
import asyncio
from gradio_client import Client
from PIL import Image
import replicate
import requests

class ImageAIService:
    def __init__(self):
        # Initialize Gradio clients for Huggingface Spaces (backup)
        self.real_esrgan_client = None
        self.vtoonify_client = None
        self.face_swap_client = None
        
        # Replicate API token
        self.replicate_token = os.environ.get('REPLICATE_API_TOKEN')
    
    def _init_real_esrgan_backup(self):
        """Initialize Real-ESRGAN Huggingface Space (backup)"""
        if not self.real_esrgan_client:
            try:
                self.real_esrgan_client = Client("akhaliq/Real-ESRGAN")
            except Exception as e:
                print(f"Failed to init Real-ESRGAN backup: {e}")
        return self.real_esrgan_client
    
    def _init_vtoonify_backup(self):
        """Initialize VToonify Huggingface Space (backup)"""
        if not self.vtoonify_client:
            try:
                self.vtoonify_client = Client("PKUWilliamYang/VToonify")
            except Exception as e:
                print(f"Failed to init VToonify backup: {e}")
        return self.vtoonify_client
    
    def _init_face_swap_backup(self):
        """Initialize Face Swap Huggingface Space (backup)"""
        if not self.face_swap_client:
            try:
                self.face_swap_client = Client("felixrosberg/face-swap")
            except Exception as e:
                print(f"Failed to init Face Swap backup: {e}")
        return self.face_swap_client
    
    def _decode_base64_image(self, base64_str):
        """
        Decode base64 string (with or without data URI prefix) to bytes
        Returns: (image_bytes, format_extension)
        """
        # Strip data URI prefix if present
        data_uri_pattern = r'^data:image/(jpeg|jpg|png|gif|webp|bmp);base64,'
        match = re.match(data_uri_pattern, base64_str, re.IGNORECASE)
        
        if match:
            format_ext = match.group(1).lower()
            if format_ext == 'jpg':
                format_ext = 'jpeg'
            base64_str = re.sub(data_uri_pattern, '', base64_str, flags=re.IGNORECASE)
        else:
            format_ext = 'png'  # Default format
        
        try:
            image_bytes = base64.b64decode(base64_str)
            return image_bytes, format_ext
        except Exception as e:
            raise ValueError(f"Invalid base64 string: {e}")
    
    def _save_temp_image(self, base64_str):
        """
        Save base64 image to temporary file, preserving format
        Returns: temp file path (caller must clean up)
        """
        image_bytes, format_ext = self._decode_base64_image(base64_str)
        
        # Create temp file with proper extension
        suffix = f'.{format_ext}'
        temp_file = tempfile.NamedTemporaryFile(delete=False, suffix=suffix)
        
        try:
            # Load image and convert if needed
            image = Image.open(io.BytesIO(image_bytes))
            
            # Convert RGBA to RGB for JPEG format
            if format_ext == 'jpeg' and image.mode in ('RGBA', 'LA', 'P'):
                # Create white background
                rgb_image = Image.new('RGB', image.size, (255, 255, 255))
                if image.mode == 'P':
                    image = image.convert('RGBA')
                rgb_image.paste(image, mask=image.split()[-1] if image.mode in ('RGBA', 'LA') else None)
                image = rgb_image
            
            # Save to temp file
            image.save(temp_file.name, format=format_ext.upper())
            return temp_file.name
            
        except Exception as e:
            # Cleanup on error
            if os.path.exists(temp_file.name):
                os.remove(temp_file.name)
            raise ValueError(f"Failed to save image: {e}")
    
    async def hd_image(self, image_base64, scale=4):
        """
        HD Image Enhancement with Intelligent Fallback
        Strategy:
        1. PRIMARY: Huggingface Inference API (Pro) - 10s timeout
        2. FALLBACK: Replicate Real-ESRGAN (fast, reliable)
        3. LAST RESORT: Huggingface Space (free backup)
        """
        temp_input = None
        result_path = None
        
        # Try Huggingface Inference API first (PRIMARY) with 10s timeout
        huggingface_token = os.environ.get('HUGGINGFACE_TOKEN')
        if huggingface_token:
            try:
                print(f"🚀 [PRIMARY] Trying Huggingface Inference API (timeout=10s, scale={scale})...")
                
                image_bytes, format_ext = self._decode_base64_image(image_base64)
                
                # Choose best model based on scale
                if scale == 4:
                    api_url = "https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-x4-upscaler"
                    print(f"   Using Stable Diffusion x4 Upscaler")
                else:
                    api_url = "https://api-inference.huggingface.co/models/nightmareai/real-esrgan"
                    print(f"   Using Real-ESRGAN Inference API")
                
                headers = {
                    "Authorization": f"Bearer {huggingface_token}",
                }
                
                def _call_hf_api():
                    # Huggingface Inference API expects raw binary image bytes
                    response = requests.post(
                        api_url,
                        headers=headers,
                        data=image_bytes,
                        timeout=10
                    )
                    response.raise_for_status()
                    return response.content
                
                loop = asyncio.get_event_loop()
                
                try:
                    # Try with 10s timeout
                    content = await asyncio.wait_for(
                        loop.run_in_executor(None, _call_hf_api),
                        timeout=10.0
                    )
                    
                    result_base64 = base64.b64encode(content).decode()
                    print(f"✅ HD Image success via Huggingface Pro (scale={scale}x)")
                    
                    return {
                        "success": True,
                        "image": f"data:image/png;base64,{result_base64}",
                        "message": f"Image upscaled {scale}x via Huggingface Pro",
                        "source": "huggingface_pro"
                    }
                
                except asyncio.TimeoutError:
                    print(f"⏱️ Huggingface Pro timeout (>10s)")
                    print(f"🔄 Falling back to Replicate...")
                except Exception as e:
                    print(f"⚠️ Huggingface Pro failed: {e}")
                    print(f"🔄 Falling back to Replicate...")
            
            except Exception as e:
                print(f"⚠️ Huggingface Pro error: {e}")
                print(f"🔄 Falling back to Replicate...")
        else:
            print(f"⚠️ HUGGINGFACE_TOKEN not configured, trying Replicate...")
        
        # Fallback: Replicate Real-ESRGAN (FALLBACK)
        if self.replicate_token:
            try:
                print(f"🔄 [FALLBACK] Trying Replicate Real-ESRGAN (scale={scale})...")
                
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
                
                if output:
                    print(f"📥 Downloading result from Replicate...")
                    
                    def _download():
                        response = requests.get(str(output), timeout=30)
                        response.raise_for_status()
                        return response.content
                    
                    content = await loop.run_in_executor(None, _download)
                    
                    result_base64 = base64.b64encode(content).decode()
                    print(f"✅ Real-ESRGAN success via Replicate (scale={scale}x)")
                    
                    return {
                        "success": True,
                        "image": f"data:image/png;base64,{result_base64}",
                        "message": f"Image upscaled {scale}x via Replicate (fallback)",
                        "source": "replicate"
                    }
            
            except Exception as e:
                print(f"⚠️ Replicate Real-ESRGAN failed: {e}")
                print(f"🔄 Falling back to Huggingface Space (last resort)...")
        else:
            print(f"⚠️ REPLICATE_API_TOKEN not configured, trying Huggingface Space...")
        
        # Last resort: Huggingface Space (LAST RESORT BACKUP)
        try:
            client = self._init_real_esrgan_backup()
            if not client:
                return {"success": False, "error": "All HD image services unavailable (Huggingface Pro, Replicate, Huggingface Space)"}
            
            temp_input = self._save_temp_image(image_base64)
            
            print(f"🔄 [LAST RESORT] Using Huggingface Space Real-ESRGAN...")
            
            def _predict():
                return client.predict(temp_input, api_name="/predict")
            
            loop = asyncio.get_event_loop()
            result_path = await loop.run_in_executor(None, _predict)
            
            with open(result_path, 'rb') as f:
                result_base64 = base64.b64encode(f.read()).decode()
            
            print(f"✅ Real-ESRGAN success via Huggingface Space (last resort)")
            
            return {
                "success": True,
                "image": f"data:image/png;base64,{result_base64}",
                "message": f"Image upscaled {scale}x via Huggingface Space (backup)",
                "source": "huggingface_space"
            }
        
        except Exception as e:
            return {"success": False, "error": f"All HD image services failed: {str(e)}"}
        
        finally:
            # Cleanup temp files
            if temp_input and os.path.exists(temp_input):
                try:
                    os.remove(temp_input)
                except:
                    pass
            if result_path and os.path.exists(result_path):
                try:
                    os.remove(result_path)
                except:
                    pass
    
    async def fix_old_photo(self, image_base64, version='v1.3'):
        """
        Fix Old Photo using GFPGAN (Replicate only - production ready)
        """
        try:
            # Get Replicate API token
            if not self.replicate_token:
                print("❌ REPLICATE_API_TOKEN not configured")
                return {"success": False, "error": "REPLICATE_API_TOKEN not configured"}
            
            # Decode base64 image
            image_bytes, format_ext = self._decode_base64_image(image_base64)
            data_uri = f"data:image/{format_ext};base64,{base64.b64encode(image_bytes).decode()}"
            
            print(f"🔄 Calling Replicate GFPGAN API with version={version}...")
            
            def _run_replicate():
                return replicate.run(
                    "tencentarc/gfpgan:0fbacf7afc6c144e5be9767cff80f25aff23e52b0708f17e20f9879b2f21516c",
                    input={
                        "img": data_uri,
                        "version": version,
                        "scale": 2
                    }
                )
            
            loop = asyncio.get_event_loop()
            # Use default executor (no blocking shutdown)
            output = await loop.run_in_executor(None, _run_replicate)
            
            if output:
                print(f"📥 Downloading result from Replicate...")
                
                def _download():
                    response = requests.get(str(output), timeout=30)
                    response.raise_for_status()
                    return response.content
                
                # Use default executor
                content = await loop.run_in_executor(None, _download)
                
                result_base64 = base64.b64encode(content).decode()
                print(f"✅ GFPGAN restoration successful via Replicate")
                
                return {
                    "success": True,
                    "image": f"data:image/png;base64,{result_base64}",
                    "message": "Old photo restored successfully",
                    "source": "replicate"
                }
            else:
                return {"success": False, "error": "No output from Replicate API"}
        
        except Exception as e:
            print(f"❌ Replicate GFPGAN error: {type(e).__name__}: {e}")
            return {"success": False, "error": f"Photo restoration failed: {str(e)}"}
    
    async def cartoonify(self, image_base64, style='cartoon', style_degree=0.5):
        """
        Cartoonify image
        Primary: Replicate VToonify
        Fallback: Huggingface Space
        """
        temp_input = None
        result_path = None
        
        # Try Replicate VToonify first (PRIMARY)
        if self.replicate_token:
            try:
                print(f"🚀 [PRIMARY] Trying Replicate VToonify (style={style}, degree={style_degree})...")
                
                image_bytes, format_ext = self._decode_base64_image(image_base64)
                data_uri = f"data:image/{format_ext};base64,{base64.b64encode(image_bytes).decode()}"
                
                def _run_replicate():
                    return replicate.run(
                        "412392713/vtoonify:54daf6387dc7c4d41ed5238e28e06277a6ee9027af5cd16486b7e0c261ba2522",
                        input={
                            "image": data_uri,
                            "style": style,
                            "style_degree": float(style_degree),
                            "padding": 200
                        }
                    )
                
                loop = asyncio.get_event_loop()
                # Use default executor (no blocking shutdown)
                output = await loop.run_in_executor(None, _run_replicate)
                
                if output:
                    print(f"📥 Downloading result from Replicate...")
                    
                    def _download():
                        response = requests.get(str(output), timeout=30)
                        response.raise_for_status()
                        return response.content
                    
                    # Use default executor
                    content = await loop.run_in_executor(None, _download)
                    
                    result_base64 = base64.b64encode(content).decode()
                    print(f"✅ VToonify success via Replicate (style={style})")
                    
                    return {
                        "success": True,
                        "image": f"data:image/png;base64,{result_base64}",
                        "message": f"Image cartoonified with {style} style via Replicate",
                        "source": "replicate"
                    }
            
            except Exception as e:
                print(f"⚠️ Replicate VToonify failed: {e}")
                print(f"🔄 Falling back to Huggingface Space...")
        else:
            print(f"⚠️ REPLICATE_API_TOKEN not configured, using Huggingface backup...")
        
        # Fallback to Huggingface Space (BACKUP)
        try:
            client = self._init_vtoonify_backup()
            if not client:
                return {"success": False, "error": "Both Replicate and Huggingface VToonify unavailable"}
            
            temp_input = self._save_temp_image(image_base64)
            
            print(f"🔄 [BACKUP] Using Huggingface VToonify...")
            
            def _predict():
                return client.predict(
                    temp_input,
                    style,
                    style_degree,
                    0,
                    api_name="/predict"
                )
            
            loop = asyncio.get_event_loop()
            # Use default executor
            result_path = await loop.run_in_executor(None, _predict)
            
            with open(result_path, 'rb') as f:
                result_base64 = base64.b64encode(f.read()).decode()
            
            print(f"✅ VToonify success via Huggingface (backup)")
            
            return {
                "success": True,
                "image": f"data:image/png;base64,{result_base64}",
                "message": f"Image cartoonified with {style} style via Huggingface (backup)",
                "source": "huggingface"
            }
        
        except Exception as e:
            return {"success": False, "error": f"All services failed: {str(e)}"}
        
        finally:
            # Cleanup temp files
            if temp_input and os.path.exists(temp_input):
                try:
                    os.remove(temp_input)
                except:
                    pass
            if result_path and os.path.exists(result_path):
                try:
                    os.remove(result_path)
                except:
                    pass

    async def face_swap(self, target_image_base64, source_face_base64):
        """
        Face Swap: Swap face from source onto target image
        Primary: Replicate codeplugtech/face-swap (Only method)
        
        Args:
            target_image_base64: Template/background image (base64)
            source_face_base64: User's face image to swap in (base64)
        """
        # Try Replicate Face Swap (PRIMARY - ONLY METHOD)
        if self.replicate_token:
            try:
                print(f"🚀 [PRIMARY] Trying Replicate Face Swap...")
                
                # Prepare data URIs
                target_bytes, target_ext = self._decode_base64_image(target_image_base64)
                source_bytes, source_ext = self._decode_base64_image(source_face_base64)
                
                target_uri = f"data:image/{target_ext};base64,{base64.b64encode(target_bytes).decode()}"
                source_uri = f"data:image/{source_ext};base64,{base64.b64encode(source_bytes).decode()}"
                
                def _run_replicate():
                    return replicate.run(
                        "codeplugtech/face-swap:278a81e7ebb22db98bcba54de985d22cc1abeead2754eb1f2af717247be69b34",
                        input={
                            "input_image": target_uri,  # Template image
                            "swap_image": source_uri    # User's face
                        }
                    )
                
                loop = asyncio.get_event_loop()
                output = await loop.run_in_executor(None, _run_replicate)
                
                if output:
                    print(f"📥 Downloading face swap result from Replicate...")
                    
                    def _download():
                        response = requests.get(str(output), timeout=60)
                        response.raise_for_status()
                        return response.content
                    
                    content = await loop.run_in_executor(None, _download)
                    
                    result_base64 = base64.b64encode(content).decode()
                    print(f"✅ Face Swap success via Replicate")
                    
                    return {
                        "success": True,
                        "image": f"data:image/png;base64,{result_base64}",
                        "message": "Face swapped successfully",
                        "source": "replicate"
                    }
            
            except Exception as e:
                error_msg = str(e)
                print(f"⚠️ Replicate Face Swap failed: {type(e).__name__}: {e}")
                
                # User-friendly error messages
                if "502" in error_msg or "Bad Gateway" in error_msg:
                    return {
                        "success": False,
                        "error": "Face swap service temporarily unavailable. Please try again in a few moments.",
                        "error_code": "SERVICE_UNAVAILABLE"
                    }
                elif "429" in error_msg or "rate limit" in error_msg.lower():
                    return {
                        "success": False,
                        "error": "Too many requests. Please wait a moment and try again.",
                        "error_code": "RATE_LIMIT"
                    }
                else:
                    return {
                        "success": False,
                        "error": f"Face swap failed: {error_msg}",
                        "error_code": "REPLICATE_ERROR"
                    }
        else:
            print(f"⚠️ REPLICATE_API_TOKEN not configured")
            return {
                "success": False,
                "error": "Face swap service not configured. Please contact support.",
                "error_code": "NOT_CONFIGURED"
            }

# Global service instance
image_ai_service = ImageAIService()
