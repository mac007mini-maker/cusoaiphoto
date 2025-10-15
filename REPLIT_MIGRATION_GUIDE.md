# Hướng Dẫn Di Chuyển Project Sang Tài Khoản Replit Khác

## 📋 Tổng Quan

Hướng dẫn này giúp bạn upload code lên GitHub và import vào tài khoản Replit mới. Toàn bộ quy trình mất khoảng **15-20 phút**.

---

## 🚀 Bước 1: Chuẩn Bị Code Trên Replit Hiện Tại

### 1.1. Kiểm tra file .gitignore

Đảm bảo file `.gitignore` đã loại trừ các file nhạy cảm:

```bash
# Kiểm tra .gitignore có đầy đủ chưa
cat .gitignore
```

File `.gitignore` phải có:
```
# Secrets và môi trường
*.env
secrets.env
.env.local

# Build outputs
build/
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies

# IDE
.idea/
*.iml
.vscode/

# Packages
.packages
pubspec.lock
```

### 1.2. Xác nhận không commit secrets

```bash
# Kiểm tra không có secrets trong code
grep -r "SUPABASE_URL" lib/ || echo "✅ Safe"
grep -r "REPLICATE_API_TOKEN" lib/ || echo "✅ Safe"
```

Nếu thấy secrets hardcoded → **XÓA NGAY** trước khi push lên GitHub!

---

## 📤 Bước 2: Upload Lên GitHub

### 2.1. Tạo Repository Mới Trên GitHub

1. Vào [github.com/new](https://github.com/new)
2. Điền thông tin:
   - **Repository name:** `viso-ai-photo-avatar` (hoặc tên khác)
   - **Visibility:** Private hoặc Public (tùy chọn)
   - **✅ KHÔNG** tick "Add README" (vì đã có code)
3. Click **Create repository**

### 2.2. Push Code Lên GitHub Từ Replit

**Trên Replit Shell, chạy các lệnh sau:**

```bash
# Khởi tạo Git (nếu chưa có)
git init

# Add remote GitHub repository (thay YOUR_USERNAME và YOUR_REPO)
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git

# Add tất cả files
git add .

# Commit
git commit -m "Initial commit - Viso AI Photo Avatar App"

# Push lên GitHub
git branch -M main
git push -u origin main
```

**⚠️ Nếu gặp lỗi authentication:**

Sử dụng **Personal Access Token (PAT)**:
1. Vào GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token (classic)
3. Chọn scopes: `repo` (full control)
4. Copy token
5. Push với token:
```bash
git remote set-url origin https://YOUR_TOKEN@github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main
```

### 2.3. Xác Nhận Code Đã Upload

1. Vào repository GitHub: `https://github.com/YOUR_USERNAME/YOUR_REPO`
2. Kiểm tra có các files chính:
   - ✅ `lib/` folder
   - ✅ `pubspec.yaml`
   - ✅ `api_server.py`
   - ✅ `requirements.txt`
   - ✅ `replit.md`
   - ❌ **KHÔNG** có `secrets.env` hoặc `.env`

---

## 📥 Bước 3: Import Vào Tài Khoản Replit Mới

### 3.1. Đăng Nhập Tài Khoản Replit Mới

1. Logout tài khoản hiện tại (hoặc dùng browser khác)
2. Login tài khoản Replit mới tại [replit.com](https://replit.com)

### 3.2. Import Project Từ GitHub

**Cách 1 - Rapid Import (Nhanh - Cho Public Repo):**

1. Vào URL sau (thay `YOUR_USERNAME` và `YOUR_REPO`):
   ```
   https://replit.com/github.com/YOUR_USERNAME/YOUR_REPO
   ```
2. Replit sẽ tự động import → Click **Import** để xác nhận

**Cách 2 - Guided Import (Đầy đủ - Cho Private/Public Repo):**

1. Vào [replit.com/import](https://replit.com/import)
2. Chọn **GitHub** làm nguồn import
3. Click **Connect GitHub** và authorize Replit truy cập GitHub
4. Chọn repository cần import từ danh sách
5. Chọn **Privacy settings** (Public/Private)
6. Click **Import from GitHub**

### 3.3. Đợi Import Hoàn Tất

Replit sẽ:
- ✅ Copy toàn bộ code
- ✅ Tự động detect ngôn ngữ (Flutter + Python)
- ✅ Tự động cài dependencies (`pubspec.yaml`, `requirements.txt`)
- ⏳ Có thể mất 2-5 phút

---

## 🔧 Bước 4: Cấu Hình Lại Trên Replit Mới

### 4.1. ⚠️ QUAN TRỌNG: Setup Secrets (API Keys)

Replit **KHÔNG** import secrets vì lý do bảo mật. Bạn PHẢI add lại thủ công:

1. **Mở Secrets tool:**
   - Click sidebar → **Tools** → **Secrets**
   - Hoặc click biểu tượng khóa 🔒 ở sidebar

2. **Add từng secret:**

| Key | Value | Nguồn lấy |
|-----|-------|-----------|
| `SUPABASE_URL` | `https://xxxxx.supabase.co` | Supabase Project Settings |
| `SUPABASE_ANON_KEY` | `eyJhbGc...` | Supabase Project Settings → API |
| `HUGGINGFACE_TOKEN` | `hf_xxxxx` | Huggingface → Settings → Access Tokens |
| `REPLICATE_API_TOKEN` | `r8_xxxxx` | Replicate → Account → API Tokens |

**Cách thêm secret:**
- Click **+ New Secret**
- Nhập **Key** (ví dụ: `SUPABASE_URL`)
- Nhập **Value** (copy từ nguồn tương ứng)
- Click **Add Secret**

### 4.2. Kiểm Tra Workflow

1. **Mở Workflows tool:**
   - Click sidebar → **Tools** → **Workflows**
   - Hoặc click biểu tượng ⚙️

2. **Kiểm tra workflow "Server" đã có chưa:**

Nếu **CHƯA CÓ** → Add workflow mới:
- **Name:** `Server`
- **Command:** `python3 api_server.py`
- **Output type:** `webview`
- **Wait for port:** `5000`

Nếu **ĐÃ CÓ** → Kiểm tra command đúng là `python3 api_server.py`

### 4.3. Cài Đặt Dependencies (Nếu Cần)

Replit thường tự động cài, nhưng nếu thiếu:

**Flutter:**
```bash
flutter pub get
```

**Python:**
```bash
pip install -r requirements.txt
```

---

## ✅ Bước 5: Test Và Chạy App

### 5.1. Build Flutter Web

```bash
flutter build web --release
```

Đợi build xong (khoảng 1-2 phút).

### 5.2. Start Server

Click nút **Run** ở đầu màn hình hoặc:

```bash
python3 api_server.py
```

### 5.3. Kiểm Tra App Hoạt Động

1. **Web preview sẽ mở tự động** tại `http://0.0.0.0:5000`
2. **Test các chức năng:**
   - ✅ Homepage load được
   - ✅ Face Swap templates hiển thị (kiểm tra Supabase connection)
   - ✅ Đa ngôn ngữ hoạt động (Settings → Language)
   - ✅ API AI hoạt động (test HD photo, face swap)

### 5.4. Kiểm Tra Console Logs

Nếu có lỗi, check logs:

1. Click **Console** tab dưới màn hình
2. Tìm lỗi:
   - ❌ `KeyError: 'SUPABASE_URL'` → Chưa setup secrets
   - ❌ `Failed to load templates` → Sai Supabase credentials
   - ❌ `Replicate API error` → Sai REPLICATE_API_TOKEN

---

## 🐛 Bước 6: Troubleshooting

### ❌ Lỗi: "Secrets not found"

**Nguyên nhân:** Chưa add secrets hoặc sai tên key.

**Giải pháp:**
1. Vào **Tools → Secrets**
2. Xác nhận có đủ 4 secrets: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `HUGGINGFACE_TOKEN`, `REPLICATE_API_TOKEN`
3. Key phải **CHÍNH XÁC** (không có khoảng trắng, viết hoa đúng)

### ❌ Lỗi: "Port 5000 already in use"

**Giải pháp:**
```bash
# Kill process cũ
pkill -f api_server.py
# Chạy lại
python3 api_server.py
```

### ❌ Lỗi: "Flutter not found"

**Giải pháp:**
```bash
# Install Flutter module
nix-env -iA nixpkgs.flutter
```

### ❌ Lỗi: Templates không load

**Nguyên nhân:** Sai Supabase credentials.

**Giải pháp:**
1. Kiểm tra `SUPABASE_URL` và `SUPABASE_ANON_KEY` đúng chưa
2. Test Supabase connection:
```bash
curl -H "apikey: YOUR_SUPABASE_ANON_KEY" \
     "YOUR_SUPABASE_URL/storage/v1/bucket/face-swap-templates"
```

### ❌ Lỗi: AI features không hoạt động

**Nguyên nhân:** Sai API tokens.

**Giải pháp:**
1. Kiểm tra `HUGGINGFACE_TOKEN` và `REPLICATE_API_TOKEN`
2. Test Replicate API:
```bash
curl -H "Authorization: Token YOUR_REPLICATE_API_TOKEN" \
     https://api.replicate.com/v1/models
```

---

## 📱 Bước 7: Build APK (Optional - Trên Local Windows)

Replit chỉ hỗ trợ Flutter Web. Để build APK:

### 7.1. Clone Code Về Máy Local

```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO
```

### 7.2. Tạo File secrets.env

Tạo file `secrets.env` (dùng `secrets.env.template` làm mẫu):

```env
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
HUGGINGFACE_TOKEN=hf_xxxxx
REPLICATE_API_TOKEN=r8_xxxxx
ADMOB_REWARDED_AD_UNIT_ID=ca-app-pub-3940256099942544/5224354917
APPLOVIN_SDK_KEY=your_key_here
```

### 7.3. Build APK

**Windows PowerShell:**
```powershell
.\build_with_all_ads.ps1 apk
```

**Unix/Mac:**
```bash
chmod +x build_with_all_ads.sh
./build_with_all_ads.sh apk
```

APK output: `build/app/outputs/flutter-apk/app-release.apk`

---

## 📝 Checklist Tổng Hợp

### Trên Replit Cũ:
- [ ] Kiểm tra `.gitignore` đầy đủ
- [ ] Không có secrets hardcoded trong code
- [ ] Push code lên GitHub thành công

### Trên GitHub:
- [ ] Repository đã có đầy đủ code
- [ ] Không có file `secrets.env` hoặc `.env`

### Trên Replit Mới:
- [ ] Import project thành công
- [ ] Add đủ 4 secrets (Supabase, Huggingface, Replicate)
- [ ] Workflow "Server" đã setup đúng
- [ ] Dependencies đã cài xong
- [ ] Build Flutter Web thành công
- [ ] App chạy được ở port 5000
- [ ] Test các features hoạt động

### Testing:
- [ ] Homepage load được
- [ ] Face Swap templates hiển thị
- [ ] Đa ngôn ngữ hoạt động
- [ ] AI features hoạt động (HD, face swap, etc.)

---

## 🔗 Links Tham Khảo

- **Replit Import:** [replit.com/import](https://replit.com/import)
- **GitHub Token:** [github.com/settings/tokens](https://github.com/settings/tokens)
- **Supabase Dashboard:** [app.supabase.com](https://app.supabase.com)
- **Huggingface Tokens:** [huggingface.co/settings/tokens](https://huggingface.co/settings/tokens)
- **Replicate API:** [replicate.com/account/api-tokens](https://replicate.com/account/api-tokens)

---

## 📞 Hỗ Trợ

Nếu gặp vấn đề:
1. Kiểm tra **Console logs** trong Replit
2. Xem file **PROJECT_GUIDE.md** cho hướng dẫn tổng quan
3. Xem file **QUICK_REFERENCE.md** cho commands nhanh
4. Dùng Replit Agent để debug

---

**Chúc bạn migration thành công! 🚀**
