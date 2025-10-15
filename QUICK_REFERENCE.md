# ⚡ Quick Reference - Viso AI

Tài liệu tham khảo nhanh cho các task thường dùng.

---

## 🚀 Build APK (Windows)

```powershell
# 1. Setup secrets.env (lần đầu tiên)
Copy-Item secrets.env.template secrets.env
notepad secrets.env  # Điền Supabase URL, keys, và test ads

# 2. Build APK
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\build_with_all_ads.ps1 apk

# 3. Install
adb install build\app\outputs\flutter-apk\app-release.apk
```

---

## 🔍 Debug Ads

```powershell
# Terminal 1: Logcat
adb logcat -c
adb logcat | Select-String "visoai|AppLovin|AdMob|Flutter|ERROR"

# Terminal 2: Launch app
adb shell am start -n com.visoai.photoheadshot/.MainActivity

# Mở app → Đợi 10s → Click "Watch Ad" → Xem logs
```

---

## 🧪 Google Test Ad IDs (Always works)

```bash
# secrets.env
export ADMOB_REWARDED_AD_UNIT_ID="ca-app-pub-3940256099942544/5224354917"
export ADMOB_BANNER_AD_UNIT_ID="ca-app-pub-3940256099942544/6300978111"
export ADMOB_INTERSTITIAL_AD_UNIT_ID="ca-app-pub-3940256099942544/1033173712"
```

---

## 📱 ADB Commands

```powershell
# Check connection
adb devices

# Install APK
adb install -r build\app\outputs\flutter-apk\app-release.apk

# Uninstall
adb uninstall com.visoai.photoheadshot

# Launch app
adb shell am start -n com.visoai.photoheadshot/.MainActivity

# View logs
adb logcat | Select-String "visoai|ERROR"

# Save logs to file
adb logcat > logs.txt
```

---

## 🐛 Common Issues & Quick Fixes

### "Ads not ready yet"
```powershell
# 1. Check build có ads config
adb logcat | Select-String "AppLovin|AdMob"
# Tìm: "[OK] ADMOB_REWARDED_AD_UNIT_ID: Found"

# 2. Nếu MISSING → Rebuild với test ads
# Edit secrets.env, dùng Google test IDs
.\build_with_all_ads.ps1 apk

# 3. Đợi 10 giây sau khi app mở
```

### "flutter: command not found"
```powershell
# Add Flutter to PATH
$env:Path += ";C:\path\to\flutter\bin"
```

### "adb: command not found"
```powershell
# Add ADB to PATH
$env:Path += ";C:\Users\YourName\AppData\Local\Android\Sdk\platform-tools"
```

### "PowerShell script error"
```powershell
# Cho phép chạy script
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

---

## 📂 Important Files

| File | Location |
|------|----------|
| **Main app** | `lib/main.dart` |
| **Translations** | `lib/flutter_flow/internationalization.dart` (line 287+) |
| **Ad services** | `lib/services/applovin_service.dart`, `admob_rewarded_service.dart` |
| **Face swap page** | `lib/swapface/swapface_widget.dart` |
| **Build scripts** | `build_with_all_ads.ps1` (Windows), `.sh` (Unix) |
| **Secrets** | `secrets.env` (create from `.template`) |
| **Package config** | `android/app/build.gradle` |

---

## 🔑 Secrets Checklist

**Required:**
- ✅ SUPABASE_URL
- ✅ SUPABASE_ANON_KEY
- ✅ HUGGINGFACE_TOKEN
- ✅ REPLICATE_API_TOKEN

**For Ads (Optional - use test IDs):**
- ADMOB_REWARDED_AD_UNIT_ID
- APPLOVIN_SDK_KEY (nếu dùng AppLovin)

---

## 🌐 URLs

- **Replit Web:** http://0.0.0.0:5000
- **Package Name:** com.visoai.photoheadshot

---

## 📚 Full Documentation

- **Comprehensive Guide:** `PROJECT_GUIDE.md`
- **Windows Build:** `WINDOWS_BUILD_GUIDE.md`
- **Ad Setup:** `AD_SETUP_GUIDE.md`
- **Debug Guide:** `DEBUG_APP_LOGCAT.md`

---

## ⚡ TL;DR - Build & Test

```powershell
# 1. Setup (lần đầu)
Copy-Item secrets.env.template secrets.env
notepad secrets.env  # Add: SUPABASE_URL, keys, test ads

# 2. Build
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\build_with_all_ads.ps1 apk

# 3. Debug
adb logcat -c
adb logcat | Select-String "visoai|AppLovin|AdMob|ERROR"

# 4. Install & test
adb install -r build\app\outputs\flutter-apk\app-release.apk
```

**Done!** 🎉
