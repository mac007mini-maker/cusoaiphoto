# 🪟 Hướng dẫn Build APK trên Windows

## 📋 Yêu cầu

- ✅ Flutter SDK đã cài đặt
- ✅ Android SDK đã cài đặt
- ✅ PowerShell (có sẵn trên Windows)

---

## 🚀 Cách Build APK

### **Bước 1: Tạo file secrets.env**

```powershell
# Copy template
Copy-Item secrets.env.template secrets.env

# Mở và điền thông tin
notepad secrets.env
```

**Điền vào secrets.env:**
```bash
export SUPABASE_URL="https://your-project.supabase.co"
export SUPABASE_ANON_KEY="your_anon_key_here"
export HUGGINGFACE_TOKEN="hf_xxxxxxxxxxxx"
export REPLICATE_API_TOKEN="r8_xxxxxxxxxxxx"

# Để test ads, dùng Google test IDs:
export ADMOB_REWARDED_AD_UNIT_ID="ca-app-pub-3940256099942544/5224354917"
export ADMOB_BANNER_AD_UNIT_ID="ca-app-pub-3940256099942544/6300978111"
export ADMOB_INTERSTITIAL_AD_UNIT_ID="ca-app-pub-3940256099942544/1033173712"

# AppLovin (optional)
export APPLOVIN_SDK_KEY="your_key_here"
export APPLOVIN_REWARDED_AD_UNIT_ID="your_id_here"
```

### **Bước 2: Chạy PowerShell script**

**Mở PowerShell trong thư mục project:**

```powershell
# Cho phép chạy script (chỉ cần chạy 1 lần)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Build APK
.\build_with_all_ads.ps1 apk

# Hoặc build App Bundle
.\build_with_all_ads.ps1 appbundle
```

### **Bước 3: Cài APK lên điện thoại**

```powershell
# Kết nối điện thoại qua USB, bật USB Debugging

# Install APK
adb install build\app\outputs\flutter-apk\app-release.apk

# Xem logs khi app chạy
adb logcat | Select-String "AppLovin|AdMob|Rewarded"
```

---

## ❌ Lỗi thường gặp

### **1. "execution of scripts is disabled"**

**Lỗi:**
```
.\build_with_all_ads.ps1 : File cannot be loaded because running scripts is disabled
```

**Giải pháp:**
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

### **2. "flutter: command not found"**

**Lỗi:**
```
flutter : The term 'flutter' is not recognized
```

**Giải pháp:**
- Cài Flutter SDK: https://docs.flutter.dev/get-started/install/windows
- Thêm Flutter vào PATH

### **3. "Android SDK not found"**

**Giải pháp:**
```powershell
# Kiểm tra Android SDK
flutter doctor

# Cài Android Studio để có SDK
```

### **4. Syntax error với `$env:VARIABLE`**

Nếu bạn chạy command thủ công, **ĐỪNG dùng `$VARIABLE`**, phải dùng `$env:VARIABLE`:

**❌ SAI:**
```powershell
flutter build apk --dart-define=ADMOB_APP_ID="$ADMOB_APP_ID"
```

**✅ ĐÚNG:**
```powershell
flutter build apk --dart-define=ADMOB_APP_ID="$env:ADMOB_APP_ID"
```

---

## 🔍 Kiểm tra ads có hoạt động không

### **Xem logs khi app khởi động:**

```powershell
adb logcat | Select-String "AppLovin|AdMob|Rewarded"
```

**Nếu thấy:**
```
✅ AppLovin SDK Key: Found
✅ AdMob Rewarded Ad Unit: Found
✅ Rewarded ad loaded
```
→ **Ads hoạt động!**

**Nếu thấy:**
```
❌ AppLovin SDK Key: MISSING
💡 Using AdMob test ads as fallback
```
→ **App không được build với secrets** → Chạy lại script

---

## 💡 Tips

### **Build nhanh hơn:**

```powershell
# Build APK split theo ABI (file nhỏ hơn)
flutter build apk --split-per-abi --release `
  --dart-define=ADMOB_REWARDED_AD_UNIT_ID="$env:ADMOB_REWARDED_AD_UNIT_ID"
```

### **Build mà không cần secrets.env:**

```powershell
# Set environment variables trực tiếp
$env:ADMOB_REWARDED_AD_UNIT_ID = "ca-app-pub-3940256099942544/5224354917"
$env:SUPABASE_URL = "https://your-project.supabase.co"

# Build
.\build_with_all_ads.ps1 apk
```

### **Dùng Git Bash thay vì PowerShell:**

Nếu bạn cài Git for Windows, có thể dùng bash script:

```bash
# Trong Git Bash
./build_with_all_ads.sh apk
```

---

## 📦 Vị trí file sau khi build

**APK:**
```
build\app\outputs\flutter-apk\app-release.apk
```

**App Bundle:**
```
build\app\outputs\bundle\release\app-release.aab
```

---

## ❓ FAQ

### **Q: Có cần production ad IDs không?**
A: Không! Dùng Google test ads (`ca-app-pub-3940256099942544/...`) để test.

### **Q: Tại sao không dùng bash script?**
A: Bash script (`.sh`) không chạy trên PowerShell. Phải dùng PowerShell script (`.ps1`).

### **Q: Build xong rồi install lên điện thoại thế nào?**
A: 
1. Bật USB Debugging trên điện thoại
2. Kết nối USB
3. Chạy: `adb install build\app\outputs\flutter-apk\app-release.apk`

### **Q: Có cách nào đơn giản hơn không?**
A: Dùng Flutter Web (đang chạy trên Replit) để test trước!

---

## 🎯 TL;DR (Quá dài không đọc)

```powershell
# 1. Tạo secrets.env
Copy-Item secrets.env.template secrets.env
notepad secrets.env  # Điền thông tin

# 2. Cho phép chạy script
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# 3. Build APK
.\build_with_all_ads.ps1 apk

# 4. Install
adb install build\app\outputs\flutter-apk\app-release.apk
```

**Done!** 🎉
