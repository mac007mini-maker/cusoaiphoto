#!/usr/bin/env python3
"""
Viso AI Backend API for Vercel
Converted from BaseHTTPRequestHandler to Flask for serverless deployment
"""
import os
import sys
import json
import asyncio
from flask import Flask, request, jsonify
from flask_cors import CORS

# Add parent directory to path to import services
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from services.image_ai_service import image_ai_service
from services.face_swap_gateway import face_swap_gateway, FaceSwapMediaType
from services.hd_image_gateway import hd_image_gateway

app = Flask(__name__)
CORS(app)

# Environment variables
HUGGINGFACE_TOKEN = os.getenv('HUGGINGFACE_TOKEN')

@app.route('/')
def home():
    """Health check endpoint"""
    return jsonify({
        'status': 'online',
        'service': 'Viso AI Backend',
        'version': '1.0.0',
        'endpoints': [
            '/api/huggingface/text-generation',
            '/api/huggingface/text-to-image',
            '/api/ai/hd-image',
            '/api/ai/fix-old-photo',
            '/api/ai/cartoonify',
            '/api/ai/face-swap',
            '/api/ai/face-swap-v2',
            '/api/ai/video-face-swap'
        ]
    })

@app.route('/api/huggingface/text-generation', methods=['POST'])
def text_generation():
    """Text generation using Huggingface models"""
    try:
        data = request.get_json()
        prompt = data.get('prompt', '')
        model = data.get('model', 'mistralai/Mistral-7B-Instruct-v0.2')
        
        if not HUGGINGFACE_TOKEN:
            return jsonify({'error': 'HUGGINGFACE_TOKEN not configured'}), 500
        
        import requests as http_requests
        hf_url = f'https://api-inference.huggingface.co/models/{model}'
        payload = {
            'inputs': prompt,
            'parameters': {
                'max_new_tokens': data.get('max_tokens', 250),
                'temperature': data.get('temperature', 0.7),
                'top_p': data.get('top_p', 0.9),
            }
        }
        
        response = http_requests.post(
            hf_url,
            headers={'Authorization': f'Bearer {HUGGINGFACE_TOKEN}'},
            json=payload,
            timeout=30
        )
        
        if response.status_code == 200:
            return jsonify({'success': True, 'result': response.json()})
        else:
            return jsonify({'error': f'Huggingface API error: {response.text}'}), response.status_code
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/huggingface/text-to-image', methods=['POST'])
def text_to_image():
    """Text to image generation using Huggingface models"""
    try:
        data = request.get_json()
        prompt = data.get('prompt', '')
        model = data.get('model', 'stabilityai/stable-diffusion-2-1')
        
        if not HUGGINGFACE_TOKEN:
            return jsonify({'error': 'HUGGINGFACE_TOKEN not configured'}), 500
        
        import requests as http_requests
        import base64
        
        hf_url = f'https://api-inference.huggingface.co/models/{model}'
        payload = {'inputs': prompt}
        
        response = http_requests.post(
            hf_url,
            headers={'Authorization': f'Bearer {HUGGINGFACE_TOKEN}'},
            json=payload,
            timeout=60
        )
        
        if response.status_code == 200:
            image_bytes = response.content
            image_base64 = base64.b64encode(image_bytes).decode('utf-8')
            return jsonify({
                'success': True,
                'image': f'data:image/png;base64,{image_base64}'
            })
        else:
            return jsonify({'error': f'Huggingface API error: {response.text}'}), response.status_code
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/ai/hd-image', methods=['POST'])
def hd_image():
    """HD Image Enhancement using Multi-Provider Gateway (Replicate PRIMARY → PiAPI FALLBACK)"""
    try:
        data = request.get_json()
        image_base64 = data.get('image', '')
        scale = data.get('scale', 4)
        
        if not image_base64:
            return jsonify({'error': 'No image provided'}), 400
        
        # Use HD Image Gateway (Replicate PRIMARY, skips slow Huggingface)
        result = asyncio.run(hd_image_gateway.enhance_image(image_base64, scale))
        
        if result['success']:
            return jsonify(result)
        else:
            return jsonify(result), 500
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/ai/fix-old-photo', methods=['POST'])
def fix_old_photo():
    """Fix Old Photo using GFPGAN"""
    try:
        data = request.get_json()
        image_base64 = data.get('image', '')
        version = data.get('version', 'v1.3')
        
        if not image_base64:
            return jsonify({'error': 'No image provided'}), 400
        
        result = asyncio.run(image_ai_service.fix_old_photo(image_base64, version))
        
        if result['success']:
            return jsonify(result)
        else:
            return jsonify(result), 500
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/ai/cartoonify', methods=['POST'])
def cartoonify():
    """Cartoonify image using VToonify"""
    try:
        data = request.get_json()
        image_base64 = data.get('image', '')
        style = data.get('style', 'cartoon')
        style_degree = data.get('style_degree', 0.5)
        
        if not image_base64:
            return jsonify({'error': 'No image provided'}), 400
        
        result = asyncio.run(image_ai_service.cartoonify(image_base64, style, style_degree))
        
        if result['success']:
            return jsonify(result)
        else:
            return jsonify(result), 500
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/ai/face-swap', methods=['POST'])
def face_swap_legacy():
    """Face Swap (Legacy endpoint) - redirects to v2"""
    return face_swap_v2()

@app.route('/api/ai/face-swap-v2', methods=['POST'])
def face_swap_v2():
    """Face Swap using Multi-Provider Gateway (Replicate → PiAPI)"""
    try:
        print("📥 [FACE_SWAP] Received request")
        data = request.get_json()
        
        target_image = data.get('target_image', '')
        source_face = data.get('source_face', '')
        
        print(f"🖼️  [FACE_SWAP] Target: {target_image[:50]}...")
        print(f"👤 [FACE_SWAP] Source: {source_face[:50]}...")
        
        if not target_image or not source_face:
            return jsonify({'error': 'Both target_image and source_face required'}), 400
        
        print("🚀 [FACE_SWAP] Calling gateway...")
        result = asyncio.run(face_swap_gateway.swap_face(
            target=target_image,
            source=source_face,
            media_type=FaceSwapMediaType.IMAGE
        ))
        
        print(f"📤 [FACE_SWAP] Result: success={result.get('success')}")
        
        if result.get('success'):
            # Download and convert to base64
            result_url = result.get('result_url')
            if result_url:
                try:
                    print(f"⬇️  [FACE_SWAP] Downloading result from: {result_url[:80]}...")
                    import base64
                    import requests as http_requests
                    
                    img_response = http_requests.get(result_url, timeout=30)
                    
                    if img_response.status_code != 200:
                        raise Exception(f"HTTP {img_response.status_code} from result URL")
                    
                    image_data = img_response.content
                    print(f"📦 [FACE_SWAP] Downloaded {len(image_data)} bytes")
                    
                    # Validate image data
                    if image_data.startswith(b'<!DOCTYPE') or image_data.startswith(b'<html'):
                        raise Exception("Received HTML instead of image")
                    
                    # Check for valid image signatures
                    valid_signatures = [
                        b'\xFF\xD8\xFF',  # JPEG
                        b'\x89PNG',        # PNG
                        b'GIF8',           # GIF
                        b'RIFF',           # WEBP
                        b'BM'              # BMP
                    ]
                    
                    is_valid = any(image_data.startswith(sig) for sig in valid_signatures)
                    if not is_valid:
                        raise Exception(f"Invalid image signature. First bytes: {image_data[:20]}")
                    
                    # Convert to base64
                    result_base64 = base64.b64encode(image_data).decode('utf-8')
                    print(f"✅ [FACE_SWAP] Successfully encoded {len(result_base64)} base64 chars")
                    
                    return jsonify({
                        'success': True,
                        'image': result_base64,  # Changed from 'result' to 'image' for Flutter compatibility
                        'provider': result.get('provider', 'unknown')
                    })
                    
                except Exception as download_error:
                    print(f"❌ [FACE_SWAP] Download failed: {download_error}")
                    return jsonify({
                        'success': False,
                        'error': f'Failed to download result: {str(download_error)}'
                    }), 500
            else:
                return jsonify({'success': False, 'error': 'No result URL in response'}), 500
        else:
            error_msg = result.get('error', 'Unknown error')
            return jsonify({'success': False, 'error': error_msg}), 500
            
    except Exception as e:
        print(f"❌ [FACE_SWAP] Error: {e}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500

@app.route('/api/ai/video-face-swap', methods=['POST'])
def video_face_swap():
    """Video Face Swap using PiAPI"""
    try:
        print("📥 [VIDEO_FACE_SWAP] Received request")
        data = request.get_json()
        
        video_url = data.get('video_url', '')
        source_face = data.get('source_face', '')
        
        if not video_url or not source_face:
            return jsonify({'error': 'Both video_url and source_face required'}), 400
        
        result = asyncio.run(face_swap_gateway.swap_face(
            target=video_url,
            source=source_face,
            media_type=FaceSwapMediaType.VIDEO
        ))
        
        if result.get('success'):
            return jsonify(result)
        else:
            return jsonify(result), 500
            
    except Exception as e:
        print(f"❌ [VIDEO_FACE_SWAP] Error: {e}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    # For local testing
    app.run(host='0.0.0.0', port=5000, debug=True)
