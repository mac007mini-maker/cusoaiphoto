#!/usr/bin/env python3
"""
Test Face Swap API
"""

import requests
import base64
import json
from pathlib import Path

# Test with sample images (you need to provide paths)
def test_face_swap():
    # Read template image (target)
    template_path = "test_images/template.jpg"  # Replace with actual path
    source_path = "test_images/face.jpg"        # Replace with actual path
    
    if not Path(template_path).exists() or not Path(source_path).exists():
        print("⚠️  Test images not found. Please provide:")
        print(f"   - {template_path}")
        print(f"   - {source_path}")
        return
    
    # Read and encode images
    with open(template_path, 'rb') as f:
        template_bytes = f.read()
        template_base64 = f"data:image/jpeg;base64,{base64.b64encode(template_bytes).decode()}"
    
    with open(source_path, 'rb') as f:
        source_bytes = f.read()
        source_base64 = f"data:image/jpeg;base64,{base64.b64encode(source_bytes).decode()}"
    
    print("🔄 Testing Face Swap API...")
    print(f"   Template: {template_path}")
    print(f"   Source: {source_path}")
    
    # Call API
    response = requests.post(
        'http://localhost:5000/api/ai/face-swap',
        headers={'Content-Type': 'application/json'},
        json={
            'target_image': template_base64,
            'source_face': source_base64
        },
        timeout=120
    )
    
    if response.status_code == 200:
        data = response.json()
        if data.get('success'):
            print(f"✅ Face swap successful!")
            print(f"   Source: {data.get('source')}")
            
            # Save result
            result_base64 = data['image'].split(',')[1]
            result_bytes = base64.b64decode(result_base64)
            
            output_path = "face_swap_result.png"
            with open(output_path, 'wb') as f:
                f.write(result_bytes)
            
            print(f"💾 Result saved to: {output_path}")
        else:
            print(f"❌ Face swap failed: {data.get('error')}")
    else:
        print(f"❌ API error: {response.status_code}")
        print(f"   {response.text}")

if __name__ == '__main__':
    test_face_swap()
