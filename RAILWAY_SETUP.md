# 🚂 Railway Deployment Guide - Viso AI Backend

## Tại Sao Railway?

Railway Hobby ($5/tháng) là lựa chọn tối ưu cho production:

✅ **No Timeout Limit**: 300s timeout (vs Vercel 10s) - Hoàn hảo cho face swap (30-120s)  
✅ **Container 24/7**: Không cold start, performance ổn định  
✅ **Custom Domain**: Domain cố định, không đổi khi restart  
✅ **Powerful**: 8GB RAM / 8 vCPU per service  
✅ **Cost-Effective**: Chỉ $5/tháng (vs Vercel Pro Max $40/tháng)

---

## 📋 Chuẩn Bị

### 1. **Tài Khoản Cần Thiết**
- ✅ GitHub account (để connect Railway)
- ✅ Railway account (sign up free tại [railway.app](https://railway.app))
- ✅ Credit card (cho Railway Hobby plan $5/tháng)

### 2. **API Keys**
Chuẩn bị các API keys sau (lấy từ Replit Secrets):

```bash
HUGGINGFACE_TOKEN=hf_xxxxxxxxxxxxxxxxxxxxxxxx
REPLICATE_API_TOKEN=r8_xxxxxxxxxxxxxxxxxxxxx
PIAPI_API_KEY=xxxxxxxxxxxxxxxx  # Optional
SUPABASE_URL=https://xxx.supabase.co  # Optional
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.xxx  # Optional
```

---

## 🚀 Bước 1: Push Code Lên GitHub

### **1.1. Initialize Git (nếu chưa có)**

```bash
git init
git add .
git commit -m "Prepare Railway deployment"
```

### **1.2. Create GitHub Repository**

1. Vào [github.com/new](https://github.com/new)
2. Repository name: `visoai-backend`
3. Set to **Public** hoặc **Private**
4. Click "Create repository"

### **1.3. Push Code**

```bash
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/visoai-backend.git
git push -u origin main
```

---

## 🛤️ Bước 2: Deploy Lên Railway

### **2.1. Create Railway Account**

1. Vào [railway.app](https://railway.app)
2. Click "Login" → Sign in with GitHub
3. Authorize Railway to access your GitHub

### **2.2. Upgrade to Hobby Plan**

1. Click avatar (góc trên phải) → "Account Settings"
2. Tab "Plans" → Chọn "Hobby" ($5/month)
3. Add credit card → Confirm

### **2.3. Create New Project**

1. Dashboard → Click "New Project"
2. Select "Deploy from GitHub repo"
3. Chọn repository `visoai-backend`
4. Railway sẽ tự động detect và deploy!

---

## 🔐 Bước 3: Add Environment Variables

### **3.1. Open Service Settings**

1. Click vào service vừa deploy (tên `visoai-backend`)
2. Tab "Variables" → Click "Add Variable"

### **3.2. Add Required Variables**

Add từng biến sau (click "Add Variable" cho mỗi key):

| Variable Name | Value | Required |
|--------------|-------|----------|
| `HUGGINGFACE_TOKEN` | `hf_xxx...` | ✅ Yes |
| `REPLICATE_API_TOKEN` | `r8_xxx...` | ✅ Yes |
| `PIAPI_API_KEY` | `xxx...` | ⚠️ Optional |
| `SUPABASE_URL` | `https://xxx.supabase.co` | ⚠️ Optional |
| `SUPABASE_ANON_KEY` | `eyJhbGci...` | ⚠️ Optional |

### **3.3. Redeploy**

Railway sẽ tự động redeploy sau khi add variables.

---

## 🌐 Bước 4: Get Railway Domain

### **4.1. Find Your Domain**

1. Click vào service
2. Tab "Settings" → Section "Networking"
3. Click "Generate Domain"
4. Copy domain (ví dụ: `visoai-backend-production.up.railway.app`)

### **4.2. (Optional) Add Custom Domain**

Nếu có domain riêng:

1. Tab "Settings" → "Networking"
2. Click "Custom Domain" → Enter domain
3. Add DNS records theo hướng dẫn Railway

---

## ✅ Bước 5: Verify Deployment

### **5.1. Test Health Check**

```bash
curl https://YOUR-RAILWAY-DOMAIN.up.railway.app/
```

**Expected response:**
```json
{
  "status": "online",
  "service": "Viso AI Backend",
  "version": "1.0.0",
  "endpoints": [...]
}
```

### **5.2. Test Face Swap (nhẹ)**

```bash
curl -X POST https://YOUR-RAILWAY-DOMAIN.up.railway.app/api/ai/face-swap \
  -H "Content-Type: application/json" \
  -d '{"target_image":"data:image/png;base64,...","source_face":"data:image/png;base64,..."}' \
  -w "\nTime: %{time_total}s\n"
```

Nếu trả về JSON response (không phải timeout) → **Deploy thành công!** ✅

---

## 📱 Bước 6: Update Flutter App

### **6.1. Update API Domain**

Mở `lib/services/huggingface_service.dart`:

```dart
// Đổi dòng này:
static const String _defaultApiDomain = '8bf1f206-1bbf-468e-94c3-c805a85c0cc0-00-3pryuqwgngpev.sisko.replit.dev';

// Thành:
static const String _defaultApiDomain = 'visoai-backend-production.up.railway.app';
```

### **6.2. Rebuild APK**

```bash
# Clean build cũ
flutter clean

# Build APK tối ưu
flutter build apk --release --split-per-abi
```

**Kết quả:** 3 APK files trong `build/app/outputs/flutter-apk/`

### **6.3. Install APK**

1. Gỡ app cũ (nếu có)
2. Copy `app-arm64-v8a-release.apk` vào điện thoại
3. Cài đặt và test face swap

---

## 💰 Chi Phí Railway

### **Hobby Plan Breakdown**

```
$5 credits/tháng bao gồm:

Backend Service:
  • RAM: 512MB - 1GB
  • vCPU: Shared
  • Cost: ~$3-4/month

PostgreSQL (Optional):
  • RAM: 256MB
  • Cost: ~$1-2/month

TOTAL: ~$5/month (vừa đủ credits!)
```

### **Monitor Usage**

1. Dashboard → Project → Tab "Usage"
2. Xem estimated cost
3. Set alerts nếu vượt $5

---

## 🔧 Troubleshooting

### **Issue 1: Build Failed**

**Lỗi:** `Failed to install requirements.txt`

**Fix:**
```bash
# Verify requirements.txt format
cat requirements.txt

# Should NOT have syntax errors
```

### **Issue 2: App Crashed**

**Check Logs:**
1. Railway dashboard → Service → Tab "Logs"
2. Tìm error message
3. Common issues:
   - Missing environment variables
   - Port binding error (Railway auto-set PORT)

### **Issue 3: Timeout Still Happening**

**Verify:**
1. Check Railway logs for actual execution time
2. Ensure gunicorn timeout = 300s (đã set trong Procfile)
3. Test với curl và check response time

---

## 📊 Railway vs Vercel vs Replit

| | **Railway Hobby** | **Vercel Free** | **Replit** |
|---|---|---|---|
| **Timeout** | ✅ 300s | ❌ 10s | ✅ No limit |
| **Domain** | ✅ Cố định | ✅ Cố định | ❌ Đổi khi restart |
| **Cold Start** | ✅ Không | ⚠️ Có (1-3s) | ✅ Không |
| **RAM** | ✅ 8GB | ⚠️ 1GB | ⚠️ Varies |
| **Cost** | 💰 $5/mo | ✅ Free | ✅ Free (dev) |
| **Production Ready** | ✅ Yes | ⚠️ Limited | ❌ No |

---

## 🎯 Next Steps

### **Production Checklist**

- [ ] Deploy backend to Railway
- [ ] Add all environment variables
- [ ] Test all API endpoints
- [ ] Update Flutter app with Railway domain
- [ ] Build and test APK
- [ ] Monitor Railway usage
- [ ] (Optional) Add custom domain
- [ ] (Optional) Setup monitoring/alerts

---

## 📚 Resources

- Railway Docs: https://docs.railway.com
- Railway Discord: https://discord.gg/railway
- GitHub repo: https://github.com/YOUR_USERNAME/visoai-backend

---

## 💬 Support

Nếu gặp vấn đề:
1. Check Railway logs first
2. Verify environment variables
3. Test API với curl
4. Check GitHub repo có push đủ files chưa

**Happy deploying!** 🚀
