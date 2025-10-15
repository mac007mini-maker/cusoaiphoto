#!/usr/bin/env python3
import os
import sys
import json
import asyncio
from http.server import HTTPServer, BaseHTTPRequestHandler, SimpleHTTPRequestHandler
from urllib.request import Request, urlopen
from urllib.error import HTTPError
from pathlib import Path

# Add services to path
sys.path.insert(0, os.path.dirname(__file__))

from services.image_ai_service import image_ai_service
from services.face_swap_gateway import face_swap_gateway, FaceSwapMediaType

HUGGINGFACE_TOKEN = os.getenv('HUGGINGFACE_TOKEN')
PORT = 5000
WEB_DIR = 'build/web'

class HuggingfaceProxyHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=WEB_DIR, **kwargs)
    
    def _set_headers(self, status_code=200, content_type='application/json'):
        self.send_response(status_code)
        self.send_header('Content-Type', content_type)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'POST, GET, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

    def do_GET(self):
        if self.path.startswith('/api/'):
            self._set_headers(404)
            self.wfile.write(json.dumps({'error': 'Use POST for API endpoints'}).encode())
        else:
            # SPA fallback: check if file exists, otherwise serve index.html for Flutter routing
            requested_path = self.path.split('?')[0]  # Remove query params
            full_path = Path(WEB_DIR) / requested_path.lstrip('/')
            
            # If file doesn't exist and it's not a static asset, serve index.html
            if not full_path.exists() and not full_path.is_file():
                if not any(requested_path.startswith(prefix) for prefix in ['/assets/', '/canvaskit/', '/flutter', '/favicon']):
                    self.path = '/index.html'
            
            super().do_GET()

    def do_OPTIONS(self):
        self._set_headers()

    def do_POST(self):
        try:
            if self.path == '/api/huggingface/text-generation':
                self.handle_text_generation()
            elif self.path == '/api/huggingface/text-to-image':
                self.handle_text_to_image()
            elif self.path == '/api/ai/hd-image':
                self.handle_hd_image()
            elif self.path == '/api/ai/fix-old-photo':
                self.handle_fix_old_photo()
            elif self.path == '/api/ai/cartoonify':
                self.handle_cartoonify()
            elif self.path == '/api/ai/face-swap':
                self.handle_face_swap()
            elif self.path == '/api/ai/face-swap-v2':
                self.handle_face_swap_v2()
            elif self.path == '/api/ai/video-face-swap':
                self.handle_video_face_swap()
            else:
                self._set_headers(404)
                self.wfile.write(json.dumps({'error': 'Endpoint not found'}).encode())
        except Exception as e:
            # Global error handler - always return JSON
            print(f"❌ GLOBAL ERROR in do_POST: {type(e).__name__}: {e}")
            import traceback
            traceback.print_exc()
            try:
                self._set_headers(500)
                self.wfile.write(json.dumps({'error': f'Server error: {str(e)}'}).encode())
            except:
                pass  # If we can't even send error response, give up gracefully

    def handle_text_generation(self):
        try:
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            data = json.loads(post_data.decode('utf-8'))
            
            prompt = data.get('prompt', '')
            model = data.get('model', 'mistralai/Mistral-7B-Instruct-v0.2')
            
            if not HUGGINGFACE_TOKEN:
                self._set_headers(500)
                self.wfile.write(json.dumps({'error': 'HUGGINGFACE_TOKEN not configured'}).encode())
                return
            
            hf_url = f'https://api-inference.huggingface.co/models/{model}'
            payload = json.dumps({
                'inputs': prompt,
                'parameters': {
                    'max_new_tokens': data.get('max_tokens', 250),
                    'temperature': data.get('temperature', 0.7),
                    'top_p': data.get('top_p', 0.9),
                }
            }).encode('utf-8')
            
            req = Request(hf_url, data=payload, headers={
                'Authorization': f'Bearer {HUGGINGFACE_TOKEN}',
                'Content-Type': 'application/json',
            })
            
            with urlopen(req, timeout=30) as response:
                result = json.loads(response.read().decode('utf-8'))
                self._set_headers(200)
                self.wfile.write(json.dumps({
                    'success': True,
                    'result': result
                }).encode())
                
        except HTTPError as e:
            error_msg = e.read().decode('utf-8')
            self._set_headers(e.code)
            self.wfile.write(json.dumps({
                'error': f'Huggingface API error: {error_msg}'
            }).encode())
        except Exception as e:
            self._set_headers(500)
            self.wfile.write(json.dumps({
                'error': str(e)
            }).encode())

    def handle_text_to_image(self):
        try:
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            data = json.loads(post_data.decode('utf-8'))
            
            prompt = data.get('prompt', '')
            model = data.get('model', 'stabilityai/stable-diffusion-2')
            
            if not HUGGINGFACE_TOKEN:
                self._set_headers(500)
                self.wfile.write(json.dumps({'error': 'HUGGINGFACE_TOKEN not configured'}).encode())
                return
            
            hf_url = f'https://api-inference.huggingface.co/models/{model}'
            payload = json.dumps({'inputs': prompt}).encode('utf-8')
            
            req = Request(hf_url, data=payload, headers={
                'Authorization': f'Bearer {HUGGINGFACE_TOKEN}',
                'Content-Type': 'application/json',
            })
            
            with urlopen(req, timeout=60) as response:
                import base64
                image_data = base64.b64encode(response.read()).decode('utf-8')
                self._set_headers(200)
                self.wfile.write(json.dumps({
                    'success': True,
                    'image': f'data:image/png;base64,{image_data}'
                }).encode())
                
        except HTTPError as e:
            error_msg = e.read().decode('utf-8')
            self._set_headers(e.code)
            self.wfile.write(json.dumps({
                'error': f'Huggingface API error: {error_msg}'
            }).encode())
        except Exception as e:
            self._set_headers(500)
            self.wfile.write(json.dumps({
                'error': str(e)
            }).encode())

    def handle_hd_image(self):
        """HD Image Enhancement using Real-ESRGAN"""
        try:
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            data = json.loads(post_data.decode('utf-8'))
            
            # Strip common data URI prefixes, service will handle the rest
            image_base64 = data.get('image', '')
            scale = data.get('scale', 4)
            
            if not image_base64:
                self._set_headers(400)
                self.wfile.write(json.dumps({'error': 'No image provided'}).encode())
                return
            
            # Run async function in sync context
            result = asyncio.run(image_ai_service.hd_image(image_base64, scale))
            
            if result['success']:
                self._set_headers(200)
                self.wfile.write(json.dumps(result).encode())
            else:
                self._set_headers(500)
                self.wfile.write(json.dumps(result).encode())
                
        except Exception as e:
            self._set_headers(500)
            self.wfile.write(json.dumps({'error': str(e)}).encode())
    
    def handle_fix_old_photo(self):
        """Fix Old Photo using GFPGAN"""
        try:
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            data = json.loads(post_data.decode('utf-8'))
            
            # Strip common data URI prefixes, service will handle the rest
            image_base64 = data.get('image', '')
            version = data.get('version', 'v1.3')
            
            if not image_base64:
                self._set_headers(400)
                self.wfile.write(json.dumps({'error': 'No image provided'}).encode())
                return
            
            # Run async function in sync context
            result = asyncio.run(image_ai_service.fix_old_photo(image_base64, version))
            
            if result['success']:
                self._set_headers(200)
                self.wfile.write(json.dumps(result).encode())
            else:
                self._set_headers(500)
                self.wfile.write(json.dumps(result).encode())
                
        except Exception as e:
            self._set_headers(500)
            self.wfile.write(json.dumps({'error': str(e)}).encode())
    
    def handle_cartoonify(self):
        """Cartoonify image using VToonify"""
        try:
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            data = json.loads(post_data.decode('utf-8'))
            
            # Strip common data URI prefixes, service will handle the rest
            image_base64 = data.get('image', '')
            style = data.get('style', 'cartoon')
            style_degree = data.get('style_degree', 0.5)
            
            if not image_base64:
                self._set_headers(400)
                self.wfile.write(json.dumps({'error': 'No image provided'}).encode())
                return
            
            # Run async function in sync context
            result = asyncio.run(image_ai_service.cartoonify(image_base64, style, style_degree))
            
            if result['success']:
                self._set_headers(200)
                self.wfile.write(json.dumps(result).encode())
            else:
                self._set_headers(500)
                self.wfile.write(json.dumps(result).encode())
                
        except Exception as e:
            self._set_headers(500)
            self.wfile.write(json.dumps({'error': str(e)}).encode())
    
    def handle_face_swap(self):
        """Face Swap using Multi-Provider Gateway (PiAPI → Replicate)"""
        try:
            print("📥 [FACE_SWAP] Received request")
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            data = json.loads(post_data.decode('utf-8'))
            
            target_image = data.get('target_image', '')  # Template image
            source_face = data.get('source_face', '')    # User's face
            
            print(f"🖼️  [FACE_SWAP] Target: {target_image[:50]}...")
            print(f"👤 [FACE_SWAP] Source: {source_face[:50]}...")
            
            if not target_image or not source_face:
                self._set_headers(400)
                self.wfile.write(json.dumps({'error': 'Both target_image and source_face required'}).encode())
                return
            
            # Use new multi-provider gateway (PiAPI primary, Replicate fallback)
            print("🚀 [FACE_SWAP] Calling gateway...")
            result = asyncio.run(face_swap_gateway.swap_face(
                target=target_image,
                source=source_face,
                media_type=FaceSwapMediaType.IMAGE
            ))
            
            print(f"📤 [FACE_SWAP] Result: success={result.get('success')}")
            
            if result.get('success'):
                # Download image from result_url and convert to base64 for Flutter
                result_url = result.get('result_url')
                if result_url:
                    try:
                        print(f"⬇️  [FACE_SWAP] Downloading result from: {result_url[:80]}...")
                        import base64
                        from urllib.request import urlopen, Request
                        
                        # Use Request to get response info
                        req = Request(result_url)
                        with urlopen(req, timeout=30) as img_response:
                            # Check HTTP status
                            status_code = img_response.getcode()
                            content_type = img_response.headers.get('Content-Type', '')
                            
                            print(f"📊 [FACE_SWAP] Response: {status_code}, Content-Type: {content_type}")
                            
                            # Validate response is actually an image
                            if status_code != 200:
                                raise Exception(f"HTTP {status_code} from result URL")
                            
                            if not content_type.startswith('image/'):
                                raise Exception(f"Invalid content type: {content_type} (expected image/*)")
                            
                            # Download and encode
                            image_data = img_response.read()
                            base64_image = base64.b64encode(image_data).decode('utf-8')
                            
                        # Return format Flutter expects
                        flutter_response = {
                            'success': True,
                            'image': f'data:image/jpeg;base64,{base64_image}'
                        }
                        
                        self._set_headers(200)
                        self.wfile.write(json.dumps(flutter_response).encode())
                        print("✅ [FACE_SWAP] Response sent successfully (base64)")
                    except Exception as download_error:
                        print(f"❌ [FACE_SWAP] Failed to download result: {download_error}")
                        self._set_headers(500)
                        self.wfile.write(json.dumps({
                            'success': False,
                            'error': f'Failed to download result: {str(download_error)}'
                        }).encode())
                else:
                    # No result_url, return error
                    self._set_headers(500)
                    self.wfile.write(json.dumps({
                        'success': False,
                        'error': 'No result_url in response'
                    }).encode())
            else:
                self._set_headers(500)
                self.wfile.write(json.dumps(result).encode())
                print(f"⚠️  [FACE_SWAP] Error response sent: {result.get('error', 'Unknown')[:100]}")
                
        except json.JSONDecodeError as e:
            print(f"❌ JSON decode error in face_swap: {e}")
            self._set_headers(400)
            self.wfile.write(json.dumps({'error': f'Invalid JSON: {str(e)}'}).encode())
        except Exception as e:
            print(f"❌ Unexpected error in face_swap handler: {type(e).__name__}: {e}")
            import traceback
            traceback.print_exc()
            self._set_headers(500)
            self.wfile.write(json.dumps({'error': f'Server error: {str(e)}'}).encode())

    def handle_face_swap_v2(self):
        """Face Swap V2 using Multi-Provider Gateway"""
        try:
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            data = json.loads(post_data.decode('utf-8'))
            
            target_image = data.get('target_image', '')
            source_face = data.get('source_face', '')
            
            if not target_image or not source_face:
                self._set_headers(400)
                self.wfile.write(json.dumps({'error': 'Both target_image and source_face required'}).encode())
                return
            
            # Run async function in sync context
            result = asyncio.run(face_swap_gateway.swap_face(
                target=target_image,
                source=source_face,
                media_type=FaceSwapMediaType.IMAGE
            ))
            
            if result.get('success'):
                self._set_headers(200)
                self.wfile.write(json.dumps(result).encode())
            else:
                self._set_headers(500)
                self.wfile.write(json.dumps(result).encode())
                
        except json.JSONDecodeError as e:
            print(f"❌ JSON decode error in face_swap_v2: {e}")
            self._set_headers(400)
            self.wfile.write(json.dumps({'error': f'Invalid JSON: {str(e)}'}).encode())
        except Exception as e:
            print(f"❌ Unexpected error in face_swap_v2 handler: {type(e).__name__}: {e}")
            import traceback
            traceback.print_exc()
            self._set_headers(500)
            self.wfile.write(json.dumps({'error': f'Server error: {str(e)}'}).encode())

    def handle_video_face_swap(self):
        """Video Face Swap using PiAPI"""
        try:
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            data = json.loads(post_data.decode('utf-8'))
            
            target_video = data.get('target_video', '')
            source_face = data.get('source_face', '')
            webhook_url = data.get('webhook_url')
            
            if not target_video or not source_face:
                self._set_headers(400)
                self.wfile.write(json.dumps({'error': 'Both target_video and source_face required'}).encode())
                return
            
            # Run async function in sync context
            result = asyncio.run(face_swap_gateway.swap_face(
                target=target_video,
                source=source_face,
                media_type=FaceSwapMediaType.VIDEO,
                webhook_url=webhook_url
            ))
            
            if result.get('success'):
                self._set_headers(200)
                self.wfile.write(json.dumps(result).encode())
            else:
                self._set_headers(500)
                self.wfile.write(json.dumps(result).encode())
                
        except json.JSONDecodeError as e:
            print(f"❌ JSON decode error in video_face_swap: {e}")
            self._set_headers(400)
            self.wfile.write(json.dumps({'error': f'Invalid JSON: {str(e)}'}).encode())
        except Exception as e:
            print(f"❌ Unexpected error in video_face_swap handler: {type(e).__name__}: {e}")
            import traceback
            traceback.print_exc()
            self._set_headers(500)
            self.wfile.write(json.dumps({'error': f'Server error: {str(e)}'}).encode())

    def log_message(self, format, *args):
        print(f"[API] {format % args}")

def run_server():
    server_address = ('0.0.0.0', PORT)
    httpd = HTTPServer(server_address, HuggingfaceProxyHandler)
    print(f'🚀 Flutter Web + AI Image Processing Server running on http://0.0.0.0:{PORT}')
    print(f'📡 API Endpoints:')
    print(f'   - POST /api/huggingface/text-generation')
    print(f'   - POST /api/huggingface/text-to-image')
    print(f'   - POST /api/ai/hd-image (Real-ESRGAN)')
    print(f'   - POST /api/ai/fix-old-photo (GFPGAN)')
    print(f'   - POST /api/ai/cartoonify (VToonify)')
    print(f'   - POST /api/ai/face-swap (Face Swap - Legacy)')
    print(f'   - POST /api/ai/face-swap-v2 (Face Swap - Multi-Provider Gateway)')
    print(f'   - POST /api/ai/video-face-swap (Video Face Swap - PiAPI)')
    print(f'🌐 Serving Flutter web from: {WEB_DIR}')
    httpd.serve_forever()

if __name__ == '__main__':
    run_server()
