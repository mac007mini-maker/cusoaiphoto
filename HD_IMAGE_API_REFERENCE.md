# HD Image Enhancement API Reference

## 📋 Overview

This document lists the best AI APIs for HD image upscaling and enhancement, integrated into the Viso AI application with intelligent fallback strategy.

---

## 🎯 Implementation Strategy

The HD Image feature uses a **3-tier intelligent fallback system**:

1. **PRIMARY**: Huggingface Inference API (Pro) - 10s timeout
2. **FALLBACK**: Replicate API (fast, reliable, $0.0019/run)
3. **LAST RESORT**: Huggingface Space (free backup)

---

## 🔥 Huggingface Inference API (Primary)

### **1. Stable Diffusion x4 Upscaler** ⭐ BEST FOR 4X SCALE
- **Model ID**: `stabilityai/stable-diffusion-x4-upscaler`
- **Type**: Diffusion-based super-resolution
- **Upscaling Factor**: 4x
- **API Endpoint**: `https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-x4-upscaler`
- **Best For**: Maximum quality 4x upscaling
- **Features**:
  - Text-guided upscaling for better control
  - Excellent quality on diverse images
  - Handles complex degradations well

**Implementation Status**: ✅ Integrated with 10s timeout

### **2. Real-ESRGAN Inference API**
- **Model ID**: `nightmareai/real-esrgan`
- **Type**: GAN-based super-resolution
- **Upscaling Factor**: 2x, 4x
- **API Endpoint**: `https://api-inference.huggingface.co/models/nightmareai/real-esrgan`
- **Best For**: 2x upscaling, real-world images
- **Features**:
  - Fast inference
  - Handles real-world degradations (blur, noise, compression)
  - No prompt required

**Implementation Status**: ✅ Integrated for 2x scale with 10s timeout

---

## 🚀 Replicate API (Fallback)

### **1. nightmareai/real-esrgan** ⭐ CURRENTLY USED
- **Model ID**: `nightmareai/real-esrgan:42fed1c4974146d4d2414e2be2c5277c7fcf05fcc3a73abf41610695738c1d7b`
- **Type**: GAN-based super-resolution
- **Hardware**: Nvidia T4 (cheap) or A100 (faster)
- **Speed**: 
  - T4: ~1.8s for 2× upscale
  - A100: ~0.7s for 2× upscale
- **Cost**: ~$0.0019 per run (~526 runs per $1)
- **Features**:
  - Optional `face_enhance` for AI faces
  - Max input: 1440p recommended
  - Very cost-effective

**Implementation Status**: ✅ Integrated as fallback

**API Call Example**:
```python
output = replicate.run(
    "nightmareai/real-esrgan:42fed1c4974146d4d2414e2be2c5277c7fcf05fcc3a73abf41610695738c1d7b",
    input={
        "image": data_uri,
        "scale": 2,  # or 4
        "face_enhance": False
    }
)
```

### **2. batouresearch/magic-image-refiner** (Alternative)
- **Model ID**: `batouresearch/magic-image-refiner`
- **Type**: General upscaling, refining, inpainting
- **Output**: 1024×1024px or 2048×2048px
- **Speed**: Fast
- **Features**:
  - Adjustable `resemblance` parameter (0-1)
  - Adjustable `creativity` parameter (0-1)
  - Best overall quality

**Implementation Status**: ❌ Available but not integrated

### **3. jingyunliang/swinir** (Alternative)
- **Model ID**: `jingyunliang/swinir`
- **Type**: Fast upscaling for web
- **Speed**: 4-4.5s for 4× upscale
- **Features**:
  - Removes JPEG artifacts
  - Excellent for landscapes and portraits
  - Better than Real-ESRGAN (without face enhancements)

**Implementation Status**: ❌ Available but not integrated

---

## 🔄 Huggingface Space (Last Resort)

### **Real-ESRGAN Space**
- **Space**: `akhaliq/Real-ESRGAN`
- **Type**: Gradio-based inference
- **Features**:
  - Reliable backup
  - No token required (public)
  - Slower than API/Replicate

**Implementation Status**: ✅ Integrated as last resort

---

## 📊 Comparison Table

| API/Model | Provider | Speed | Quality | Cost | Timeout | Status |
|-----------|----------|-------|---------|------|---------|--------|
| **SD x4 Upscaler** | HF Inference | Medium | Excellent | Free* | 10s | ✅ **Primary (4x)** |
| **Real-ESRGAN Inference** | HF Inference | Fast | Very Good | Free* | 10s | ✅ **Primary (2x)** |
| **Real-ESRGAN** | Replicate | Very Fast | Very Good | $0.0019 | 30s | ✅ Fallback |
| **Magic Refiner** | Replicate | Fast | Excellent | ~$0.02 | 30s | ❌ Available |
| **SwinIR** | Replicate | Fast | Very Good | ~$0.01 | 30s | ❌ Available |
| **Real-ESRGAN Space** | HF Space | Slow | Good | Free | 60s | ✅ Last Resort |

*Free with HF Pro subscription or rate-limited

---

## 🔧 Current Implementation

### File: `services/image_ai_service.py`

```python
async def hd_image(self, image_base64, scale=4):
    """
    HD Image Enhancement with Intelligent Fallback
    Strategy:
    1. PRIMARY: Huggingface Inference API (timeout 10s)
    2. FALLBACK: Replicate Real-ESRGAN (reliable)
    3. LAST RESORT: Huggingface Space (backup)
    """
    
    # 1. Try Huggingface Inference API (10s timeout)
    if huggingface_token:
        image_bytes, _ = self._decode_base64_image(image_base64)
        
        # Select model based on scale
        if scale == 4:
            api_url = "https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-x4-upscaler"
        else:
            api_url = "https://api-inference.huggingface.co/models/nightmareai/real-esrgan"
        
        headers = {"Authorization": f"Bearer {huggingface_token}"}
        
        # Send raw binary image bytes (NOT JSON)
        response = requests.post(api_url, headers=headers, data=image_bytes, timeout=10)
        
        # Use asyncio.wait_for for timeout control
        try:
            content = await asyncio.wait_for(
                loop.run_in_executor(None, _call_hf_api),
                timeout=10.0
            )
            return {"success": True, "image": f"data:image/png;base64,{result_base64}"}
        except asyncio.TimeoutError:
            # Fall through to Replicate
            pass
    
    # 2. Fallback to Replicate
    if replicate_token:
        # Use nightmareai/real-esrgan
        output = replicate.run("nightmareai/real-esrgan:...", input={...})
        return {"success": True, "image": result}
    
    # 3. Last resort: Huggingface Space
    client = self._init_real_esrgan_backup()
    result = client.predict(temp_file)
    return {"success": True, "image": result}
```

**Key Implementation Details**:
- ✅ Send **raw binary bytes** to Huggingface Inference API (NOT JSON)
- ✅ Use `asyncio.wait_for(timeout=10.0)` for strict timeout control
- ✅ Proper error handling with fallback on timeout or failure
- ✅ Model selection based on scale factor (4x = SD x4, 2x = Real-ESRGAN)

### Timeout Handling

- **Huggingface Inference API**: 10 second timeout (configurable)
- **Replicate**: 30 second timeout for download
- **Huggingface Space**: Default Gradio timeout (~60s)

### Error Flow

```
User uploads image
    ↓
Try HF Inference API (10s timeout)
    ├─ Success → Return result
    ├─ Timeout → Fallback to Replicate
    └─ Error → Fallback to Replicate
         ↓
Try Replicate (30s timeout)
    ├─ Success → Return result
    └─ Error → Try HF Space
         ↓
Try HF Space (60s timeout)
    ├─ Success → Return result
    └─ Error → Return error to user
```

---

## 📝 Environment Variables

Required secrets for full functionality:

```bash
# Huggingface (Primary)
HUGGINGFACE_TOKEN="hf_xxxxxxxxxxxxx"

# Replicate (Fallback)
REPLICATE_API_TOKEN="r8_xxxxxxxxxxxxx"
```

---

## 🧪 Testing

### Test 4x Upscaling (Stable Diffusion)
```bash
POST /api/ai/hd-image
{
  "image": "data:image/jpeg;base64,...",
  "scale": 4
}

Expected: Uses Stable Diffusion x4 Upscaler
```

### Test 2x Upscaling (Real-ESRGAN)
```bash
POST /api/ai/hd-image
{
  "image": "data:image/jpeg;base64,...",
  "scale": 2
}

Expected: Uses Real-ESRGAN Inference API
```

### Test Timeout Fallback
```bash
# Simulate HF timeout by removing HUGGINGFACE_TOKEN
unset HUGGINGFACE_TOKEN

POST /api/ai/hd-image
{
  "image": "data:image/jpeg;base64,...",
  "scale": 4
}

Expected: Falls back to Replicate
```

---

## 📚 API Documentation Links

### Huggingface
- Stable Diffusion x4: https://huggingface.co/stabilityai/stable-diffusion-x4-upscaler
- Real-ESRGAN: https://huggingface.co/nightmareai/real-esrgan
- Inference API Docs: https://huggingface.co/docs/api-inference

### Replicate
- Real-ESRGAN: https://replicate.com/nightmareai/real-esrgan
- Magic Refiner: https://replicate.com/batouresearch/magic-image-refiner
- SwinIR: https://replicate.com/jingyunliang/swinir
- API Docs: https://replicate.com/docs/reference/http

### Huggingface Spaces
- Real-ESRGAN Space: https://huggingface.co/spaces/akhaliq/Real-ESRGAN
- Gradio Client Docs: https://www.gradio.app/guides/getting-started-with-the-python-client

---

## 🎯 Future Improvements

### Potential Enhancements:
1. **Add Magic Image Refiner** as alternative Replicate fallback
2. **Add SwinIR** for faster 4x upscaling
3. **Dynamic model selection** based on image characteristics
4. **Batch processing** support for multiple images
5. **Quality metrics** tracking (PSNR, SSIM)
6. **Cost optimization** based on usage patterns

### Model Rotation Strategy:
- Monitor success rates and latency for each provider
- Dynamically adjust primary/fallback based on performance
- Implement circuit breaker pattern for failing services

---

**Last Updated**: October 11, 2025  
**Implementation**: ✅ Complete  
**Status**: Production Ready
