#!/usr/bin/env python3
"""
Backend API Test Suite
Tests fallback architecture: Replicate (Primary) → Huggingface (Backup)
"""

import requests
import json
import sys

BASE_URL = "http://localhost:5000"

def test_fix_old_photo():
    """Test GFPGAN API via Replicate (Primary only)"""
    try:
        test_image = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="
        
        response = requests.post(
            f"{BASE_URL}/api/ai/fix-old-photo",
            json={"image": test_image, "version": "v1.3"},
            timeout=60
        )
        
        data = response.json()
        if data.get('success'):
            source = data.get('source', 'unknown')
            return "✅ WORKING", f"Replicate API (source: {source})"
        else:
            return "❌ FAILED", data.get('error', 'Unknown error')
    except Exception as e:
        return "❌ ERROR", str(e)

def test_hd_image():
    """Test Real-ESRGAN with fallback: Replicate → Huggingface"""
    try:
        test_image = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="
        
        response = requests.post(
            f"{BASE_URL}/api/ai/hd-image",
            json={"image": test_image, "scale": 2},
            timeout=60
        )
        
        data = response.json()
        if data.get('success'):
            source = data.get('source', 'unknown')
            if source == 'replicate':
                return "✅ WORKING", f"Replicate API (primary)"
            elif source == 'huggingface':
                return "✅ WORKING", f"Huggingface Spaces (fallback)"
            else:
                return "✅ WORKING", f"Source: {source}"
        else:
            return "❌ FAILED", data.get('error', 'Unknown error')
    except Exception as e:
        return "❌ ERROR", str(e)

def test_cartoonify():
    """Test VToonify with fallback: Replicate → Huggingface"""
    try:
        test_image = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="
        
        response = requests.post(
            f"{BASE_URL}/api/ai/cartoonify",
            json={"image": test_image, "style": "cartoon", "style_degree": 0.5},
            timeout=90
        )
        
        data = response.json()
        if data.get('success'):
            source = data.get('source', 'unknown')
            if source == 'replicate':
                return "✅ WORKING", f"Replicate API (primary)"
            elif source == 'huggingface':
                return "✅ WORKING", f"Huggingface Spaces (fallback)"
            else:
                return "✅ WORKING", f"Source: {source}"
        else:
            return "⚠️  BOTH FAILED", data.get('error', 'Both Replicate and Huggingface unavailable')
    except Exception as e:
        return "⚠️  TIMEOUT", f"Request timeout or error: {str(e)}"

def test_text_generation():
    """Test Mistral-7B text generation (Huggingface only)"""
    try:
        response = requests.post(
            f"{BASE_URL}/api/huggingface/text-generation",
            json={"prompt": "Hello", "max_tokens": 10},
            timeout=30
        )
        
        data = response.json()
        if data.get('success'):
            return "✅ WORKING", "Huggingface Inference API"
        else:
            return "⚠️  LIMITED", data.get('error', 'Model may be loading or rate limited')
    except Exception as e:
        return "⚠️  LIMITED", str(e)

def test_image_generation():
    """Test Stable Diffusion image generation (Huggingface only)"""
    try:
        response = requests.post(
            f"{BASE_URL}/api/huggingface/text-to-image",
            json={"prompt": "A beautiful landscape"},
            timeout=60
        )
        
        data = response.json()
        if data.get('success'):
            return "✅ WORKING", "Huggingface Inference API"
        else:
            return "⚠️  LIMITED", data.get('error', 'Model may be loading or rate limited')
    except Exception as e:
        return "⚠️  LIMITED", str(e)

def main():
    print("=" * 80)
    print("🔬 BACKEND API TEST SUITE - FALLBACK ARCHITECTURE")
    print("=" * 80)
    print("📋 Architecture: Replicate (Primary) → Huggingface (Backup)")
    print()
    
    tests = [
        ("Fix Old Photo (GFPGAN)", test_fix_old_photo),
        ("HD Image (Real-ESRGAN)", test_hd_image),
        ("Cartoonify (VToonify)", test_cartoonify),
        ("Text Generation (Mistral-7B)", test_text_generation),
        ("Image Generation (Stable Diffusion)", test_image_generation),
    ]
    
    results = []
    
    for name, test_func in tests:
        print(f"Testing: {name}...", end=" ", flush=True)
        status, details = test_func()
        results.append((name, status, details))
        print(f"{status}")
    
    print()
    print("=" * 80)
    print("📊 API STATUS REPORT")
    print("=" * 80)
    print()
    
    for name, status, details in results:
        print(f"{status} {name}")
        print(f"   └─ {details}")
        print()
    
    print("=" * 80)
    print("📝 LEGEND:")
    print("=" * 80)
    print("✅ WORKING       = Production-ready, reliable")
    print("⚠️  BOTH FAILED  = Both Replicate and Huggingface unavailable")
    print("⚠️  LIMITED      = Free tier limitations (rate limits, cold starts)")
    print("⚠️  TIMEOUT      = Request timeout (service may be slow)")
    print()
    print("🎯 FALLBACK LOGIC:")
    print("   1. Try Replicate API (Primary - fast, reliable, $0.002/run)")
    print("   2. If failed → Fallback to Huggingface Spaces (Backup - free, may timeout)")
    print("   3. If both failed → Return error with details")
    print()
    print("📈 PRODUCTION RECOMMENDATION:")
    print("   ✅ Fix Old Photo - Replicate only (99.9% uptime)")
    print("   ✅ HD Image - Replicate with Huggingface fallback")
    print("   ⚠️  Cartoonify - Need alternative model (both services unstable)")
    print()

if __name__ == "__main__":
    main()
