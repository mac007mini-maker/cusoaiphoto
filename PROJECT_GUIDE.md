# 📚 Viso AI - Hướng dẫn Toàn Diện

**Project:** Flutter AI Photo/Avatar Application  
**Platform:** Web (Replit) + Mobile (Android/iOS)  
**Package Name:** `com.visoai.photoheadshot`

---

## 📋 Mục Lục

1. [Tổng Quan Dự Án](#1-tổng-quan-dự-án)
2. [Kiến Trúc Hệ Thống](#2-kiến-trúc-hệ-thống)
3. [Setup Môi Trường Development](#3-setup-môi-trường-development)
4. [Build & Deploy](#4-build--deploy)
5. [Ad Monetization System](#5-ad-monetization-system)
6. [Multi-Language Support](#6-multi-language-support)
7. [Testing & Debugging](#7-testing--debugging)
8. [Troubleshooting](#8-troubleshooting)
9. [Next Steps](#9-next-steps)

---

## 1. Tổng Quan Dự Án

### 1.1 Mục Đích
Viso AI là ứng dụng Flutter tạo AI headshots và avatars chuyên nghiệp với các tính năng:
- **Face Swapping:** Hoán đổi khuôn mặt với AI
- **Photo Enhancement:** Nâng cấp chất lượng ảnh HD
- **Photo Restoration:** Khôi phục ảnh cũ
- **AI Style Templates:** 20+ template phong cách khác nhau

### 1.2 Tech Stack

**Frontend:**
- Flutter 3.32.0 (Dart 3.8.0)
- FlutterFlow-generated components
- Material Design + Custom UI

**Backend:**
- Python Flask (API proxy server)
- Supabase (Database, Storage, Auth)

**AI Services:**
- Replicate API (Primary - Face swap, GFPGAN)
- Huggingface API (Backup - Stable Diffusion, Real-ESRGAN, VToonify)

**Monetization:**
- **Web:** Google AdMob
- **Mobile:** AppLovin MAX (Primary) + AdMob (Fallback)

**Languages:** 20+ languages (6 fully translated, 14 with English fallback)

---

## 2. Kiến Trúc Hệ Thống

### 2.1 Project Structure

```
visoaiflow-backup/
├── lib/                          # Flutter source code
│   ├── main.dart                 # App entry point
│   ├── flutter_flow/            # FlutterFlow components
│   │   └── internationalization.dart  # Translations (kTranslationsMap)
│   ├── services/                # Business logic
│   │   ├── applovin_service.dart     # AppLovin MAX integration
│   │   └── admob_rewarded_service.dart  # AdMob fallback
│   ├── swapface/                # Face swap feature
│   │   └── swapface_widget.dart      # Ghostface page with ads
│   └── ...
├── android/                     # Android native code
│   └── app/
│       ├── build.gradle         # Package name config
│       └── src/main/AndroidManifest.xml
├── web/                         # Web build output
├── api_server.py               # Python Flask backend
├── build_with_all_ads.sh       # Build script (Linux/Mac)
├── build_with_all_ads.ps1      # Build script (Windows PowerShell)
├── secrets.env.template        # Template for secrets
└── replit.md                   # Project documentation
```

### 2.2 Data Flow

```
User Action
    ↓
Flutter UI (lib/)
    ↓
Service Layer (lib/services/)
    ↓
[Face Swap] → Python Backend (api_server.py) → Replicate API → Result
[Ads] → AppLovin MAX → Success/Fail → AdMob Fallback
[Templates] → Supabase Storage (auto-load via list() API)
```

### 2.3 Ad System Architecture

```
User clicks "Watch Ad"
    ↓
Try AppLovin MAX
    ↓
    ├── Success → Show ad → Reward user
    └── Failed → Fallback to AdMob
            ↓
            ├── Success → Show ad → Reward user
            └── Failed → Show error message
```

---

## 3. Setup Môi Trường Development

### 3.1 Replit Environment (Web Development)

**Hiện trạng:**
- ✅ Flutter Web đang chạy trên Replit
- ✅ Python backend đang hoạt động
- ✅ Workflow: `Server` (python3 api_server.py)
- ✅ URL: http://0.0.0.0:5000

**Secrets đã config (trong Replit Secrets):**
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `HUGGINGFACE_TOKEN`
- `REPLICATE_API_TOKEN`
- `APPLOVIN_SDK_KEY`
- `APPLOVIN_REWARDED_AD_UNIT_ID`
- `ADMOB_REWARDED_AD_UNIT_ID`

**Lưu ý:**
- Replit **CHỈ support Flutter Web**
- Không thể build APK/iOS trên Replit
- Mobile build cần máy local với Flutter SDK

### 3.2 Local Development Environment (Mobile)

**Yêu cầu:**
- Flutter SDK 3.32.0+
- Android SDK (cho Android build)
- Xcode (cho iOS build - Mac only)
- Git

**Setup:**

```bash
# 1. Clone project
git clone <your-repo-url>
cd visoaiflow-backup

# 2. Install dependencies
flutter pub get

# 3. Check environment
flutter doctor

# 4. Tạo secrets.env (xem 3.3)
```

### 3.3 Secrets Configuration

**Tạo file `secrets.env`:**

```bash
# Copy template
cp secrets.env.template secrets.env

# Edit và điền thông tin
nano secrets.env  # hoặc notepad secrets.env trên Windows
```

**Nội dung secrets.env:**

```bash
# Supabase (Required)
export SUPABASE_URL="https://your-project.supabase.co"
export SUPABASE_ANON_KEY="your_anon_key_here"

# AI APIs (Required)
export HUGGINGFACE_TOKEN="hf_xxxxxxxxxxxxx"
export REPLICATE_API_TOKEN="r8_xxxxxxxxxxxxx"

# AdMob (Optional - dùng test ads nếu không có)
export ADMOB_APP_ID="ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX"
export ADMOB_REWARDED_AD_UNIT_ID="ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX"
export ADMOB_BANNER_AD_UNIT_ID="ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX"
export ADMOB_INTERSTITIAL_AD_UNIT_ID="ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX"

# AppLovin MAX (Optional - dùng test mode nếu không có)
export APPLOVIN_SDK_KEY="your_sdk_key_here"
export APPLOVIN_REWARDED_AD_UNIT_ID="your_ad_unit_id"
export APPLOVIN_BANNER_AD_UNIT_ID="your_ad_unit_id"
export APPLOVIN_INTERSTITIAL_AD_UNIT_ID="your_ad_unit_id"
export APPLOVIN_APP_OPEN_AD_UNIT_ID="your_ad_unit_id"
```

**Google Test Ad IDs (Để testing):**

```bash
# Android Test Ads (Luôn hoạt động)
export ADMOB_REWARDED_AD_UNIT_ID="ca-app-pub-3940256099942544/5224354917"
export ADMOB_BANNER_AD_UNIT_ID="ca-app-pub-3940256099942544/6300978111"
export ADMOB_INTERSTITIAL_AD_UNIT_ID="ca-app-pub-3940256099942544/1033173712"
```

---

## 4. Build & Deploy

### 4.1 Build Flutter Web (Replit)

**Automatic:**
- Replit tự động build và serve trên port 5000
- Workflow "Server" chạy `python3 api_server.py`

**Manual Rebuild:**
```bash
flutter build web --release
```

**Publish Web:**
- Click "Deploy" button trong Replit
- Chọn deployment type (VM/Autoscale)
- App sẽ có public URL

### 4.2 Build Android APK (Local Machine)

#### **Linux/Mac:**

```bash
# 1. Tạo secrets.env (nếu chưa có)
cp secrets.env.template secrets.env
nano secrets.env  # Điền thông tin

# 2. Build với script
./build_with_all_ads.sh apk

# 3. APK location:
# build/app/outputs/flutter-apk/app-release.apk

# 4. Install lên điện thoại
adb install build/app/outputs/flutter-apk/app-release.apk
```

#### **Windows PowerShell:**

```powershell
# 1. Tạo secrets.env
Copy-Item secrets.env.template secrets.env
notepad secrets.env  # Điền thông tin

# 2. Cho phép chạy PowerShell script
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# 3. Build với script
.\build_with_all_ads.ps1 apk

# 4. APK location:
# build\app\outputs\flutter-apk\app-release.apk

# 5. Install lên điện thoại
adb install build\app\outputs\flutter-apk\app-release.apk
```

#### **Manual Build (Nếu script không hoạt động):**

```powershell
# Set environment variables
$env:SUPABASE_URL = "your_url"
$env:SUPABASE_ANON_KEY = "your_key"
$env:ADMOB_REWARDED_AD_UNIT_ID = "ca-app-pub-3940256099942544/5224354917"

# Build APK
flutter build apk --release `
  --dart-define=SUPABASE_URL="$env:SUPABASE_URL" `
  --dart-define=SUPABASE_ANON_KEY="$env:SUPABASE_ANON_KEY" `
  --dart-define=ADMOB_REWARDED_AD_UNIT_ID="$env:ADMOB_REWARDED_AD_UNIT_ID"
```

### 4.3 Build App Bundle (For Google Play)

```bash
# Linux/Mac
./build_with_all_ads.sh appbundle

# Windows PowerShell
.\build_with_all_ads.ps1 appbundle

# Output: build/app/outputs/bundle/release/app-release.aab
```

### 4.4 Build iOS (Mac Only)

```bash
./build_with_all_ads.sh ios

# Output: build/ios/iphoneos/Runner.app
```

---

## 5. Ad Monetization System

### 5.1 Ad Networks

**Platform-Specific:**
- **Web:** Google AdMob only
- **Mobile (iOS/Android):** AppLovin MAX (Primary) + AdMob (Fallback)

**Ad Types Implemented:**
- ✅ Rewarded Ads (Face swap feature)
- ✅ Banner Ads (Bottom of pages)
- ✅ Interstitial Ads (Between actions)
- ✅ App Open Ads (App launch)

### 5.2 Implementation Details

**Files:**
- `lib/services/applovin_service.dart` - AppLovin MAX integration
- `lib/services/admob_rewarded_service.dart` - AdMob fallback
- `lib/main.dart` - Ad initialization
- `lib/swapface/swapface_widget.dart` - Rewarded ad usage

**Flow:**
1. User clicks "Swap Face - Watch Ad"
2. App tries AppLovin MAX first
3. If AppLovin fails → Fallback to AdMob
4. If ad shown successfully → User can swap face
5. If both fail → Show error message

### 5.3 Debug Logging

Build APK có comprehensive logging để debug ads:

**Khi app khởi động:**
```
🔍 AppLovin Configuration Check:
  SDK Key: ✅ Found (hoặc ❌ MISSING)
  Rewarded Ad Unit: ✅ Found (hoặc ❌ MISSING)

🔍 AdMob Rewarded Configuration Check:
  Rewarded Ad Unit: ✅ Found (hoặc ❌ MISSING - will use test ads)
```

**Khi load ads:**
```
✅ AppLovin MAX initialized successfully
✅ Rewarded ad loaded
```

**Nếu fail:**
```
❌ AppLovin initialization failed: [error]
💡 Falling back to AdMob...
```

### 5.4 Testing Ads

**Option 1: Google Test Ads (Khuyên dùng)**
- Dùng test ad IDs trong secrets.env
- IDs: `ca-app-pub-3940256099942544/...`
- Luôn hoạt động, không cần approval
- Không risk bị banned

**Option 2: AppLovin Test Mode**
- Setup trong AppLovin Dashboard
- Add device ID vào test devices
- Requires configuration

**Option 3: Production Ads**
- Dùng real ad unit IDs
- Cần approve trong AdMob/AppLovin dashboard
- Risk invalid traffic nếu test nhiều

**Khuyến nghị:** Dùng Google Test Ads cho development!

---

## 6. Multi-Language Support

### 6.1 Supported Languages (20 Total)

**Fully Translated (6):**
- English (en)
- Français (fr)
- Español LatAm (es)
- Português Brasil (pt)
- 简体中文 中国 (zh_Hans)
- 繁體中文 臺灣/香港 (zh_Hant)

**Available with English Fallback (14):**
- Deutsch (de), Italiano (it), Русский (ru), Türkçe (tr)
- العربية (ar), فارسی (fa), हिन्दी (hi)
- Indonesia (id), Tiếng Việt (vi), ไทย (th)
- 한국어 (ko), 日本語 (ja), Polski (pl), Nederlands (nl)

### 6.2 Translation System

**Location:** `lib/flutter_flow/internationalization.dart`

**Structure:**
```dart
final Map<String, Map<String, String>> kTranslationsMap = {
  'unique_key_1': {
    'en': 'English text',
    'fr': 'Texte français',
    'es': 'Texto español',
    // ...
  },
  'unique_key_2': {
    // ...
  },
};
```

**Features:**
- Locale normalization (de-DE → de, pt-PT → pt)
- Automatic fallback to English
- Language selection dialog in Settings
- Persistent language preferences

### 6.3 Adding New Translations

1. Edit `lib/flutter_flow/internationalization.dart`
2. Find key in `kTranslationsMap`
3. Add translation for your language code
4. Rebuild app

---

## 7. Testing & Debugging

### 7.1 Testing Web Version (Replit)

**Live Preview:**
- URL: http://0.0.0.0:5000
- Click "Webview" trong Replit

**Check Console:**
```bash
# Xem workflow logs
# Click vào "Console" tab trong Replit
```

### 7.2 Testing Mobile APK

#### **A. Setup ADB Connection**

**Enable USB Debugging on Phone:**
1. Settings → About phone
2. Tap "Build number" 7 times
3. Developer options → USB debugging (ON)

**Check Connection:**
```powershell
adb devices

# Should show:
# List of devices attached
# ABC123456    device
```

#### **B. Install APK**

```powershell
# Install
adb install build\app\outputs\flutter-apk\app-release.apk

# Or reinstall
adb install -r build\app\outputs\flutter-apk\app-release.apk

# Uninstall
adb uninstall com.visoai.photoheadshot
```

#### **C. View Logs (QUAN TRỌNG)**

**Method 1: Realtime Logs**

```powershell
# Window 1: Logcat
adb logcat -c
adb logcat | Select-String "visoai|AppLovin|AdMob|Flutter|ERROR"

# Window 2: Launch app
adb shell am start -n com.visoai.photoheadshot/.MainActivity
```

**Method 2: Save to File**

```powershell
# Start logging
adb logcat > app_logs.txt

# Mở app, test features, đợi 30 giây

# Stop logging (Ctrl+C)

# Search logs
Select-String -Path app_logs.txt -Pattern "AppLovin|AdMob|ERROR"
```

#### **D. Debug Ads**

**Expected Success Logs:**
```
I/flutter: [OK] AppLovin SDK Key: Found
I/flutter: [OK] AdMob Rewarded Ad Unit: Found
I/AppLovinSdk: Initializing SDK...
I/AppLovinSdk: SDK initialized successfully
I/AppLovinSdk: Rewarded ad loaded
I/flutter: Showing rewarded ad
```

**Common Error Logs:**
```
E/flutter: AppLovin SDK Key: MISSING
E/AppLovinSdk: Invalid SDK Key
E/AdMob: Ad failed to load: ERROR_CODE_NO_FILL
W/flutter: Ad not ready yet, please wait
```

### 7.3 Common Test Scenarios

**Test 1: App Launch**
- ✅ App opens without crash
- ✅ Templates load from Supabase
- ✅ Ads initialize in background

**Test 2: Face Swap with Ad**
- ✅ Click Ghostface → Add photo
- ✅ Click "Swap Face - Watch Ad"
- ✅ Ad displays (AppLovin or AdMob)
- ✅ After watching ad → Face swap works

**Test 3: Language Switching**
- ✅ Settings → Language
- ✅ Select different language
- ✅ UI updates to new language
- ✅ Language persists after app restart

**Test 4: Photo Enhancement**
- ✅ Upload photo
- ✅ Apply HD enhancement
- ✅ Image upscaled correctly
- ✅ Download works

---

## 8. Troubleshooting

### 8.1 Build Errors

#### **Error: "flutter: command not found"**

**Giải pháp:**
```bash
# Add Flutter to PATH
export PATH="$PATH:/path/to/flutter/bin"

# Hoặc dùng full path
/path/to/flutter/bin/flutter build apk
```

#### **Error: "Android SDK not found"**

**Giải pháp:**
- Install Android Studio
- Run `flutter doctor`
- Follow instructions to install SDK

#### **Error: PowerShell script syntax error**

**Giải pháp:**
- Đảm bảo file `build_with_all_ads.ps1` không có emoji
- Dùng manual build command (xem section 4.2)

### 8.2 Ad Issues

#### **Issue: "Ads not ready yet"**

**Nguyên nhân:**
- Ads chưa được build với ad configuration
- Ad IDs invalid hoặc chưa approve
- Internet connection issue

**Giải pháp:**
1. **Kiểm tra build có ad IDs không:**
   ```powershell
   # Xem logcat khi app khởi động
   adb logcat | Select-String "AppLovin|AdMob"
   
   # Tìm dòng:
   # [OK] ADMOB_REWARDED_AD_UNIT_ID: Found
   ```

2. **Dùng Google Test Ads:**
   ```bash
   # secrets.env
   export ADMOB_REWARDED_AD_UNIT_ID="ca-app-pub-3940256099942544/5224354917"
   ```

3. **Rebuild APK:**
   ```powershell
   .\build_with_all_ads.ps1 apk
   adb install -r build\app\outputs\flutter-apk\app-release.apk
   ```

4. **Đợi lâu hơn:**
   - Ads load asynchronously (2-10 giây)
   - Đợi 10 giây sau khi app mở

#### **Issue: AppLovin initialization failed**

**Giải pháp:**
- Bỏ AppLovin, chỉ dùng AdMob
- Comment out AppLovin secrets trong secrets.env
- App sẽ tự động dùng AdMob

#### **Issue: "No fill" error**

**Nguyên nhân:**
- Ad network không có ads available
- Internet connection issue
- Invalid ad unit ID

**Giải pháp:**
- Dùng Google Test Ad IDs
- Check internet connection
- Thử lại sau vài phút

### 8.3 App Crashes

#### **Check Crash Logs:**

```powershell
# Xem crash logs
adb logcat | Select-String "FATAL|AndroidRuntime|crash"
```

#### **Common Crashes:**

**Crash on launch:**
- Missing Supabase credentials
- Invalid secrets configuration
- Missing dependencies

**Crash on face swap:**
- API token invalid
- Network error
- Backend server down

### 8.4 Template Loading Issues

**Issue: Templates không hiển thị**

**Giải pháp:**
1. Check Supabase connection
2. Verify templates exist in Storage bucket `face-swap-templates`
3. Check logs:
   ```powershell
   adb logcat | Select-String "Supabase|Template|Storage"
   ```

---

## 9. Next Steps

### 9.1 Development Roadmap

**Short-term (1-2 weeks):**
- [ ] Fix ads loading delay
- [ ] Optimize template loading speed
- [ ] Add more translations (Vietnamese, Korean, Japanese)
- [ ] Improve error messages

**Mid-term (1 month):**
- [ ] Setup GitHub Actions for auto-build
- [ ] Implement user authentication
- [ ] Add favorites/history feature
- [ ] Setup Firebase Analytics

**Long-term (3+ months):**
- [ ] Launch on Google Play Store
- [ ] Launch on Apple App Store
- [ ] Add premium subscription
- [ ] Implement social sharing

### 9.2 Production Deployment

#### **Web Deployment (Replit):**
1. Click "Deploy" button
2. Select deployment type:
   - **Autoscale:** For stateless apps (recommended)
   - **VM:** For always-running apps
3. Configure custom domain (optional)
4. Deploy!

#### **Mobile Deployment:**

**Google Play Store:**
1. Build App Bundle: `.\build_with_all_ads.ps1 appbundle`
2. Create Google Play Console account
3. Setup app listing, screenshots, description
4. Upload AAB file
5. Submit for review

**Apple App Store:**
1. Build iOS: `./build_with_all_ads.sh ios` (Mac only)
2. Create Apple Developer account
3. Setup App Store Connect
4. Upload IPA via Xcode
5. Submit for review

### 9.3 Monitoring & Analytics

**Setup Firebase:**
```bash
# Add Firebase to project
flutter pub add firebase_core firebase_analytics

# Initialize in main.dart
await Firebase.initializeApp();
```

**Track Events:**
- App launches
- Face swaps completed
- Ads viewed
- Errors/crashes
- User retention

### 9.4 Performance Optimization

**Current Status:**
- Web build size: ~2MB (optimized)
- APK size: ~80MB (can be reduced with split APKs)
- Face swap time: 5-10 seconds

**Improvements:**
- [ ] Implement image caching
- [ ] Optimize template loading
- [ ] Reduce APK size with ProGuard
- [ ] Add loading skeletons
- [ ] Implement progressive image loading

---

## 10. Resources & References

### 10.1 Documentation Links

**Flutter:**
- https://docs.flutter.dev/
- https://pub.dev/packages

**Ad Networks:**
- AdMob: https://developers.google.com/admob/flutter
- AppLovin: https://developers.applovin.com/en/max/flutter

**Backend:**
- Supabase: https://supabase.com/docs
- Replicate: https://replicate.com/docs
- Huggingface: https://huggingface.co/docs

### 10.2 Important Files Reference

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point, ad initialization |
| `lib/flutter_flow/internationalization.dart` | Translations (line 287+) |
| `lib/services/applovin_service.dart` | AppLovin MAX integration |
| `lib/services/admob_rewarded_service.dart` | AdMob fallback |
| `lib/swapface/swapface_widget.dart` | Face swap with rewarded ads |
| `android/app/build.gradle` | Package name, version |
| `android/app/src/main/AndroidManifest.xml` | Permissions, package |
| `api_server.py` | Python Flask backend |
| `build_with_all_ads.sh` | Build script (Unix) |
| `build_with_all_ads.ps1` | Build script (Windows) |
| `secrets.env` | Environment variables (NOT committed) |
| `replit.md` | Project memory/preferences |

### 10.3 Support & Community

**Issues?**
- Check logs first: `adb logcat`
- Search error messages
- Review this guide's Troubleshooting section

**Contact:**
- Replit Support (for platform issues)
- Flutter Community (for Flutter questions)
- AI Service providers (for API issues)

---

## 📝 Summary

Viso AI là Flutter app hoàn chỉnh với:
- ✅ Multi-platform (Web + Mobile)
- ✅ AI-powered features (Face swap, Enhancement)
- ✅ Dual ad network monetization
- ✅ 20+ language support
- ✅ Production-ready codebase

**Development:**
- Web: Replit (live at port 5000)
- Mobile: Local build với Flutter SDK

**Build Process:**
- Web: Auto-build trên Replit
- Android: `.\build_with_all_ads.ps1 apk`
- iOS: `./build_with_all_ads.sh ios`

**Testing:**
- Dùng Google Test Ads
- Debug với `adb logcat`
- Check logs khi app khởi động

**Next:** Deploy to production hoặc continue development theo roadmap!

---

**Last Updated:** October 10, 2025  
**Flutter Version:** 3.32.0  
**Package Name:** com.visoai.photoheadshot
