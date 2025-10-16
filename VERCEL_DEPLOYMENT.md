# Hướng Dẫn Deploy Backend Flask lên Vercel

## Tại sao nên dùng Vercel thay vì Replit?

✅ **URL cố định** - Không thay đổi khi restart
✅ **Miễn phí** - Free tier đủ cho production
✅ **Tự động scale** - Xử lý tăng traffic
✅ **Zero-config** - Deploy Flask chỉ với vài click

---

## Chuẩn bị

### 1. Cấu trúc thư mục cần thiết

Tạo cấu trúc sau cho Vercel:

```
your-project/
├── api/
│   └── index.py          # Flask app chính
├── services/             # Các service hiện tại
│   ├── face_swap_gateway.py
│   └── ...
├── requirements.txt      # Python dependencies
└── vercel.json          # Config Vercel
```

### 2. Tạo file `api/index.py`

Di chuyển code từ `api_server.py` sang `api/index.py`:

```python
from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import os
import sys

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from services.face_swap_gateway import FaceSwapGateway

app = Flask(__name__)
CORS(app)

# Initialize services
face_swap_gateway = FaceSwapGateway()

@app.route('/api/face-swap-v2', methods=['POST'])
def face_swap_v2():
    # Your face swap logic here
    pass

@app.route('/api/ai/hd-image', methods=['POST'])
def hd_image():
    # Your HD image logic here
    pass

# Add all other endpoints...

@app.route('/')
def home():
    return jsonify({
        "status": "online",
        "service": "Viso AI Backend",
        "version": "1.0.0"
    })
```

### 3. Tạo file `vercel.json`

```json
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/api/index" }
  ],
  "env": {
    "REPLICATE_API_TOKEN": "@replicate_token",
    "HUGGINGFACE_TOKEN": "@huggingface_token",
    "SUPABASE_URL": "@supabase_url",
    "SUPABASE_ANON_KEY": "@supabase_key"
  }
}
```

### 4. Cập nhật `requirements.txt`

```txt
Flask==3.0.3
flask-cors==4.0.0
gradio-client
pillow
replicate
requests
```

---

## Deploy lên Vercel

### Bước 1: Tạo tài khoản Vercel

1. Truy cập [vercel.com](https://vercel.com)
2. Sign up với GitHub account
3. Authorize Vercel

### Bước 2: Push code lên GitHub

```bash
git add .
git commit -m "Prepare for Vercel deployment"
git push origin main
```

### Bước 3: Import Project vào Vercel

1. Vào Vercel Dashboard → **Add New** → **Project**
2. Chọn repository của bạn
3. Vercel tự động detect Flask
4. Click **Deploy**

### Bước 4: Thêm Environment Variables

1. Vào Project Settings → **Environment Variables**
2. Thêm các biến:
   - `REPLICATE_API_TOKEN` = your-replicate-token
   - `HUGGINGFACE_TOKEN` = your-hf-token
   - `SUPABASE_URL` = your-supabase-url
   - `SUPABASE_ANON_KEY` = your-supabase-key

3. Click **Save**

### Bước 5: Redeploy

1. Vào **Deployments** tab
2. Click **Redeploy** để áp dụng env vars

---

## Cập nhật Flutter App

### Thay đổi API URL trong Flutter

Mở `lib/services/huggingface_service.dart`:

```dart
class HuggingfaceService {
  // Thay đổi domain mặc định sang Vercel
  static const String _defaultApiDomain = 'your-project.vercel.app';
  static const String _apiDomain = String.fromEnvironment('API_DOMAIN', defaultValue: _defaultApiDomain);
  
  static String get baseUrl {
    if (kIsWeb) {
      final origin = Uri.base.origin;
      return '$origin/api/huggingface';
    } else {
      return 'https://$_apiDomain/api/huggingface';
    }
  }
  
  static String get aiBaseUrl {
    if (kIsWeb) {
      final origin = Uri.base.origin;
      return '$origin/api/ai';
    } else {
      return 'https://$_apiDomain/api/ai';
    }
  }
}
```

### Build lại APK

```bash
flutter build apk --release --split-per-abi
```

---

## Testing

### Test API trên Vercel

```bash
# Check status
curl https://your-project.vercel.app/

# Test face swap
curl -X POST https://your-project.vercel.app/api/face-swap-v2 \
  -H "Content-Type: application/json" \
  -d '{"source_image": "...", "target_image": "..."}'
```

---

## Lợi ích

✅ **URL cố định** - `https://your-project.vercel.app` không đổi
✅ **Tự động deploy** - Push code là tự động deploy
✅ **Free SSL** - HTTPS tự động
✅ **Global CDN** - Nhanh ở mọi khu vực
✅ **Logs & Analytics** - Theo dõi lỗi dễ dàng

---

## Alternative: Supabase Edge Functions

⚠️ **Lưu ý**: Supabase Edge Functions **KHÔNG hỗ trợ Python/Flask**

Nếu muốn dùng Supabase:
1. Viết lại backend bằng **TypeScript/Deno**
2. HOẶC deploy Flask ở nơi khác (Vercel/Fly.io) và gọi từ Supabase

**Recommendation**: Dùng Vercel cho đơn giản nhất!

---

## Troubleshooting

### Lỗi: "502 Bad Gateway"
- Kiểm tra `requirements.txt` có đầy đủ dependencies
- Check Vercel logs: Project → Deployments → View Function Logs

### Lỗi: "Unable to find Python version"
- Vào Settings → General → Node.js Version
- Đổi sang **18.x**

### API chạy chậm
- Vercel serverless có cold start (~1-2s lần đầu)
- Giải pháp: Upgrade Vercel Pro hoặc dùng Keep-Alive ping

---

## Chi phí

| Plan | Giá | Limits |
|------|-----|--------|
| Hobby (Free) | $0 | 100GB bandwidth/month, 1000 invocations/day |
| Pro | $20/month | 1TB bandwidth, unlimited invocations |

**Kết luận**: Free tier đủ cho testing và MVP!
