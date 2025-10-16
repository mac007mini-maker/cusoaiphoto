# 🚀 Hướng Dẫn Deploy Backend Lên Vercel

## ✅ Đã Chuẩn Bị Sẵn

Mình đã tạo sẵn các file cần thiết:
- ✅ `api/index.py` - Flask backend API
- ✅ `vercel.json` - Config Vercel
- ✅ `requirements.txt` - Python dependencies
- ✅ `services/` - Các service AI hiện có

## 📋 Thông Tin Bạn Cần Gửi

### 1. API Keys/Secrets (Bạn đã có sẵn)

Bạn cần cung cấp các API keys sau (đã có trong Replit secrets):

```bash
# Bắt buộc
HUGGINGFACE_TOKEN=hf_xxxxxxxxxxxxxxxxxxxxxxxx
REPLICATE_API_TOKEN=r8_xxxxxxxxxxxxxxxxxxxxx

# Tùy chọn (nếu có)
PIAPI_API_KEY=xxxxxxxxxxxxxxxx
SUPABASE_URL=https://xxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.xxxxx
```

### 2. GitHub Repository

**Option A: Tạo repo mới**
1. Vào GitHub → New Repository
2. Tên repo: `visoai-backend` (hoặc tên bạn thích)
3. Public hoặc Private đều được
4. Không cần README, gitignore

**Option B: Dùng repo hiện có**
- Nếu đã có repo, chỉ cần push code lên

## 🔧 Các Bước Deploy

### Bước 1: Push Code Lên GitHub

```bash
# Khởi tạo git (nếu chưa có)
git init

# Add tất cả files
git add .

# Commit
git commit -m "Prepare backend for Vercel deployment"

# Link với GitHub repo
git remote add origin https://github.com/YOUR_USERNAME/visoai-backend.git

# Push
git push -u origin main
```

### Bước 2: Deploy Lên Vercel

1. **Truy cập Vercel**
   - Vào [vercel.com](https://vercel.com)
   - Click "Sign Up" với GitHub account
   - Authorize Vercel

2. **Import Project**
   - Click "Add New" → "Project"
   - Chọn repository `visoai-backend`
   - Vercel tự động detect Flask/Python
   - Click "Deploy"

3. **Thêm Environment Variables**
   - Sau khi deploy, vào Project Settings
   - Tab "Environment Variables"
   - Thêm từng biến:
     ```
     Name: HUGGINGFACE_TOKEN
     Value: [API key của bạn]
     ```
   - Làm tương tự cho:
     - `REPLICATE_API_TOKEN`
     - `PIAPI_API_KEY` (optional)
     - `SUPABASE_URL` (optional)
     - `SUPABASE_ANON_KEY` (optional)

4. **Redeploy**
   - Vào tab "Deployments"
   - Click "Redeploy" để apply env vars
   - Đợi ~30 giây

### Bước 3: Lấy URL Production

Sau khi deploy xong, Vercel sẽ cho bạn URL kiểu:
```
https://visoai-backend.vercel.app
```

**URL này cố định, không đổi!** ✨

## 📱 Cập Nhật Flutter App

### Option 1: Rebuild với URL mới

Mở terminal và build lại:

```bash
# Thay YOUR_DOMAIN bằng domain Vercel của bạn
flutter build apk --release \
  --dart-define=API_DOMAIN=visoai-backend.vercel.app \
  --split-per-abi \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --tree-shake-icons
```

### Option 2: Cập nhật default domain

Mở `lib/services/huggingface_service.dart` và đổi:

```dart
// Thay bằng Vercel domain của bạn
static const String _defaultApiDomain = 'visoai-backend.vercel.app';
```

Sau đó build:
```bash
flutter build apk --release --split-per-abi
```

## ✅ Kiểm Tra

### Test API

```bash
# Health check
curl https://visoai-backend.vercel.app/

# Test face swap
curl -X POST https://visoai-backend.vercel.app/api/ai/face-swap-v2 \
  -H "Content-Type: application/json" \
  -d '{
    "target_image": "data:image/png;base64,...",
    "source_face": "data:image/png;base64,..."
  }'
```

### Xem Logs

1. Vào Vercel Dashboard
2. Project → Deployments
3. Click deployment mới nhất
4. Xem "Function Logs" để debug

## 🎯 Lợi Ích

✅ **URL cố định** - Không đổi khi restart
✅ **Auto-deploy** - Push code là tự động deploy
✅ **Free tier** - 100GB bandwidth/month miễn phí
✅ **Global CDN** - Nhanh trên toàn thế giới
✅ **SSL miễn phí** - HTTPS tự động

## 🔄 Update Sau Này

Mỗi lần sửa code:
```bash
git add .
git commit -m "Update API logic"
git push
```

→ Vercel tự động deploy lại trong ~1 phút!

## 📊 Monitoring

### Xem Usage
- Vercel Dashboard → Project → Analytics
- Theo dõi requests, errors, latency

### Set Alerts (Optional)
- Settings → Notifications
- Nhận email khi có lỗi hoặc downtime

## 🆘 Troubleshooting

### Lỗi: "502 Bad Gateway"
- Kiểm tra `requirements.txt` đầy đủ
- Check Function Logs để xem lỗi gì

### Lỗi: "Build Failed"
- Đảm bảo `api/index.py` không có syntax error
- Xem Build Logs để biết nguyên nhân

### API chậm lần đầu
- Cold start của serverless (~1-2s)
- Lần sau sẽ nhanh hơn

## 💰 Chi Phí

| Plan | Giá | Bandwidth | Functions |
|------|-----|-----------|-----------|
| Hobby (Free) | $0 | 100GB/month | 1000 invocations/day |
| Pro | $20/month | 1TB | Unlimited |

**Free tier đủ cho testing và production nhỏ!**

---

## 📝 Tóm Tắt - Bạn Cần Làm

1. ✅ Push code lên GitHub
2. ✅ Import project vào Vercel
3. ✅ Thêm env vars (API keys)
4. ✅ Redeploy
5. ✅ Rebuild Flutter app với Vercel domain
6. ✅ Test và enjoy!

**Thời gian: ~15 phút** ⚡

---

Nếu cần giúp đỡ, ping mình bất cứ lúc nào! 🚀
