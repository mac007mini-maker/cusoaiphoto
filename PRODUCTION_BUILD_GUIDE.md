# 🚀 Hướng Dẫn Build Production - Google Play & App Store (2025)

## 📋 Tổng Quan

Guide này hướng dẫn chi tiết cách build, config và upload app lên Google Play Store và Apple App Store theo đúng chuẩn policies 2025.

---

# 📱 PHẦN 1: GOOGLE PLAY STORE (ANDROID)

## ✅ Requirements Mới Nhất (2025)

### 1. **Format: AAB (KHÔNG phải APK)**
- Google Play **bắt buộc** Android App Bundle (.aab) từ 2021
- APK chỉ dùng để test local, KHÔNG được upload lên Play Store

### 2. **Target API Level 35 (Android 15)**
- Từ **31/8/2025**: Tất cả app mới phải target API 35+
- Extension đến **1/11/2025** (nếu cần)

### 3. **16KB Page Size Support** (Từ 1/11/2025)
- App phải hỗ trợ 16KB memory page size trên 64-bit devices
- Cần Android Gradle Plugin (AGP) 8.5.1+

---

## 🔧 Bước 1: Cấu Hình Build

### 1.1. Update `android/app/build.gradle`

```gradle
android {
    compileSdkVersion 35  // ✅ Bắt buộc 2025
    
    defaultConfig {
        applicationId "com.visoai.photoheadshot"
        minSdkVersion 21
        targetSdkVersion 35  // ✅ Bắt buộc 2025
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
        multiDexEnabled true
    }
}
```

### 1.2. Update `android/build.gradle`

```gradle
buildscript {
    dependencies {
        classpath 'com.android.tools.build:gradle:8.5.1'  // ✅ Cần 8.5.1+ cho 16KB
    }
}
```

### 1.3. Tạo Upload Keystore (LẦN ĐẦU DUY NHẤT)

```bash
# Tạo keystore để sign app
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload

# Nhập thông tin:
# - Password keystore
# - Password key alias
# - Họ tên, tổ chức, thành phố, quốc gia
```

**⚠️ QUAN TRỌNG:** Lưu file `upload-keystore.jks` và passwords an toàn! Mất keystore = không update app được!

### 1.4. Tạo `android/key.properties`

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=../upload-keystore.jks
```

### 1.5. Config Signing trong `android/app/build.gradle`

```gradle
// Thêm trước android {}
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

### 1.6. Update `.gitignore`

```gitignore
# Keystore files
*.jks
*.keystore
key.properties

# Environment configs
secrets.env
prod.json
```

---

## 🔑 Bước 2: Secrets Management

### 2.1. Tạo `prod.json` cho production

```json
{
  "SUPABASE_URL": "https://your-project.supabase.co",
  "SUPABASE_ANON_KEY": "your_production_anon_key",
  "HUGGINGFACE_TOKEN": "hf_xxxxxxxxxxxxx",
  "REPLICATE_API_TOKEN": "r8_xxxxxxxxxxxxx",
  "ADMOB_APP_ID_ANDROID": "ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX",
  "ADMOB_REWARDED_AD_UNIT_ID": "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX",
  "APPLOVIN_SDK_KEY": "your_production_applovin_key",
  "SUPPORT_EMAIL": "support@yourdomain.com"
}
```

**⚠️ LƯU Ý:** 
- Dùng **REAL API keys** cho production
- KHÔNG commit file này lên Git
- Store trong password manager (1Password, LastPass, etc.)

---

## 📱 Bước 3: Permissions & Privacy

### 3.1. Permissions Đã Có (AndroidManifest.xml)

App hiện tại xin các permissions:
```xml
✅ INTERNET - Kết nối API
✅ WRITE_EXTERNAL_STORAGE (API ≤32) - Lưu ảnh (Android 12-)
✅ READ_EXTERNAL_STORAGE (API ≤32) - Đọc ảnh (Android 12-)
✅ READ_MEDIA_IMAGES (API 33+) - Đọc ảnh (Android 13+)
```

### 3.2. Runtime Permissions (Đã Implement)

App đã implement runtime permission requests trong code:
- `permission_handler` package tự động request quyền khi cần
- User phải approve mỗi permission lúc runtime

---

## 📄 Bước 4: Privacy Policy & Data Safety

### 4.1. Privacy Policy (BẮT BUỘC)

**Yêu cầu:**
- ✅ Host trên URL public (HTTPS)
- ✅ KHÔNG dùng Google Docs editable
- ✅ Dùng domain riêng hoặc GitHub Pages

**Nội dung BẮT BUỘC phải có:**
1. **Data Collection** - Dữ liệu gì được thu thập
2. **Data Usage** - Dùng để làm gì
3. **Third-party Sharing** - Chia sẻ với ai (Supabase, Huggingface, Replicate, AdMob, AppLovin)
4. **User Rights** - Quyền xóa data, export data
5. **Security Practices** - Bảo mật như thế nào
6. **Contact Info** - Email support, địa chỉ công ty

**Template Privacy Policy:** (Xem file `PRIVACY_POLICY_TEMPLATE.md`)

### 4.2. Data Safety Form (Google Play Console)

Khi upload app, phải điền form này:

**Data Types Collected:**
- ✅ **Photos/Videos** - User upload ảnh để xử lý AI
- ✅ **Device ID** - AdMob/AppLovin dùng cho ads targeting
- ✅ **App Activity** - Analytics tracking

**Data Usage:**
- ✅ App functionality - Xử lý ảnh AI
- ✅ Advertising - Hiển thị ads
- ✅ Analytics - Theo dõi usage

**Data Sharing:**
- ✅ Supabase - Store ảnh processed
- ✅ Huggingface/Replicate - AI processing
- ✅ AdMob/AppLovin - Ad networks

---

## 🏗️ Bước 5: Build Production AAB

### 5.1. Clean Build

```bash
flutter clean
flutter pub get
```

### 5.2. Build Release AAB

```bash
flutter build appbundle \
  --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --dart-define-from-file=prod.json
```

**Flags giải thích:**
- `--release` - Build production mode
- `--obfuscate` - Bảo vệ code khỏi reverse engineering
- `--split-debug-info` - Tách debug symbols cho crash reporting
- `--dart-define-from-file` - Inject secrets từ prod.json

### 5.3. Verify Output

```bash
# File AAB ở đây:
ls -lh build/app/outputs/bundle/release/app-release.aab

# Check size (thường 20-50MB)
```

---

## 📤 Bước 6: Upload Lên Google Play Console

### 6.1. Tạo App (Lần Đầu)

1. Vào [Google Play Console](https://play.google.com/console)
2. Click **Create App**
3. Điền thông tin:
   - App name: **Viso AI - Photo Avatar Headshot**
   - Default language: **English (United States)**
   - App type: **App**
   - Free/Paid: **Free** (hoặc Paid nếu có in-app purchase)

### 6.2. Complete Store Listing

**Main Store Listing:**
- ✅ App name (tối đa 50 ký tự)
- ✅ Short description (tối đa 80 ký tự)
- ✅ Full description (tối đa 4000 ký tự)
- ✅ App icon (512x512 PNG)
- ✅ Screenshots (tối thiểu 2 ảnh, tối đa 8 ảnh)
  - Phone: 16:9 hoặc 9:16
  - Tablet: Tùy chọn
- ✅ Feature graphic (1024x500 PNG)

**App Content:**
- ✅ Privacy policy URL
- ✅ App access (full access hay cần login?)
- ✅ Ads declaration (Yes - app có ads)
- ✅ Content rating (điền questionnaire)
- ✅ Target audience (18+ recommended vì có AI content)
- ✅ News app declaration (No)
- ✅ COVID-19 contact tracing (No)
- ✅ Data safety (điền form)

### 6.3. Upload AAB

1. **Testing Track (Recommended First):**
   - Release → Testing → Internal testing
   - Upload `app-release.aab`
   - Add testers (email addresses)
   - Review & Start rollout

2. **Production (Sau khi test xong):**
   - Release → Production
   - Upload `app-release.aab`
   - Review & Start rollout

### 6.4. Review Process

- ⏱️ Thời gian: 1-7 ngày
- 📧 Sẽ nhận email khi approved/rejected
- ❌ Nếu rejected: Xem lý do, fix, upload lại

---

## ✅ Android Checklist

- [ ] Update `compileSdkVersion` & `targetSdkVersion` = 35
- [ ] Update Android Gradle Plugin ≥ 8.5.1
- [ ] Tạo upload keystore (lần đầu)
- [ ] Config signing trong build.gradle
- [ ] Tạo prod.json với REAL keys
- [ ] Build AAB với --obfuscate
- [ ] Host privacy policy URL
- [ ] Complete Data Safety Form
- [ ] Upload AAB lên Internal Testing
- [ ] Test trên real devices
- [ ] Promote to Production

---

# 🍎 PHẦN 2: APPLE APP STORE (iOS)

## ✅ Requirements Mới Nhất (2025)

### 1. **Xcode 16+ & iOS 18 SDK** (BẮT BUỘC)
- Từ **April 2025**: Tất cả app phải build với Xcode 16+
- Deployment target: iOS 13+ vẫn OK (app chạy trên thiết bị cũ được)

### 2. **Privacy Manifest** (BẮT BUỘC từ 1/5/2024)
- File `PrivacyInfo.xcprivacy` bắt buộc
- Khai báo Required Reason APIs
- Third-party SDKs phải có privacy manifests

### 3. **Apple Developer Program**
- Phí: **$99/năm** (bắt buộc để publish)

---

## 🔧 Bước 1: Setup Development Environment

### 1.1. Install/Update Xcode

```bash
# Download từ Mac App Store
# Hoặc: https://developer.apple.com/xcode/

# Set Xcode command-line tools
sudo xcode-select --switch /Applications/Xcode.app

# Verify
xcodebuild -version  # Phải ≥ 16.0
```

### 1.2. Update CocoaPods

```bash
sudo gem install cocoapods
pod repo update
```

### 1.3. Update Flutter & Dependencies

```bash
flutter upgrade
flutter pub upgrade
flutter clean
```

---

## 🔑 Bước 2: iOS Privacy Manifest (BẮT BUỘC)

### 2.1. Tạo `PrivacyInfo.xcprivacy`

1. Mở `ios/Runner.xcworkspace` trong Xcode
2. Right-click **Runner** folder → New File
3. Chọn **iOS → Resource → App Privacy**
4. Name: `PrivacyInfo.xcprivacy`
5. Save vào **Runner** folder

### 2.2. Nội Dung Privacy Manifest

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Tracking Declaration -->
    <key>NSPrivacyTracking</key>
    <true/>
    
    <!-- Required Reason APIs -->
    <key>NSPrivacyAccessedAPITypes</key>
    <array>
        <!-- UserDefaults API -->
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>CA92.1</string> <!-- Store user preferences -->
            </array>
        </dict>
        
        <!-- File Timestamp API -->
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryFileTimestamp</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>C617.1</string> <!-- Cache management -->
            </array>
        </dict>
    </array>
    
    <!-- Data Collection -->
    <key>NSPrivacyCollectedDataTypes</key>
    <array>
        <dict>
            <key>NSPrivacyCollectedDataType</key>
            <string>NSPrivacyCollectedDataTypePhotosorVideos</string>
            <key>NSPrivacyCollectedDataTypeLinked</key>
            <false/>
            <key>NSPrivacyCollectedDataTypeTracking</key>
            <false/>
            <key>NSPrivacyCollectedDataTypePurposes</key>
            <array>
                <string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string>
            </array>
        </dict>
    </array>
    
    <!-- Tracking Domains -->
    <key>NSPrivacyTrackingDomains</key>
    <array>
        <string>googleadservices.com</string>
        <string>applovin.com</string>
    </array>
</dict>
</plist>
```

**Approved Reason Codes:**
- `CA92.1` - UserDefaults for app preferences
- `C617.1` - File timestamps for cache
- Xem đầy đủ: [Apple Required Reason APIs](https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api)

---

## 📱 Bước 3: Permissions & Info.plist

### 3.1. Permissions Đã Có (Info.plist)

```xml
✅ NSPhotoLibraryUsageDescription - "Viso AI needs access to your photo library to save your AI-generated images."
✅ NSPhotoLibraryAddUsageDescription - "Viso AI needs permission to save AI-generated images to your photo library."
```

### 3.2. Camera Permission (Nếu cần)

Nếu app dùng camera để chụp ảnh, thêm:

```xml
<key>NSCameraUsageDescription</key>
<string>Viso AI needs camera access to take photos for AI processing.</string>
```

---

## 🏗️ Bước 4: Build Production IPA

### 4.1. Update Version

Edit `pubspec.yaml`:
```yaml
version: 1.0.0+1
#       ^^^ Version name (user sees)
#           ^ Build number (increment mỗi lần upload)
```

### 4.2. Config Xcode Signing

1. Mở `ios/Runner.xcworkspace` trong Xcode
2. Select **Runner** target
3. Tab **Signing & Capabilities**:
   - ✅ **Team**: Chọn Apple Developer Team
   - ✅ **Automatically manage signing**: Bật
   - ✅ **Bundle Identifier**: `com.visoai.photoheadshot`

### 4.3. Build IPA

```bash
flutter build ipa \
  --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --dart-define-from-file=prod.json
```

**Output:**
- File IPA: `build/ios/ipa/*.ipa`
- XCArchive: `build/ios/archive/Runner.xcarchive`

---

## 📤 Bước 5: Upload Lên App Store

### 5.1. Validate & Upload (Xcode)

1. Mở Xcode
2. Menu: **Window → Organizer**
3. Tab **Archives** → Chọn archive mới nhất
4. Click **Validate App**:
   - Chọn distribution method: **App Store Connect**
   - Chọn distribution certificate
   - Wait validation (2-5 phút)
5. Nếu validate OK → Click **Distribute App**
6. Monitor upload trong **Activities** tab

### 5.2. App Store Connect Setup

1. Vào [App Store Connect](https://appstoreconnect.apple.com)
2. **My Apps → + → New App**
3. Điền thông tin:
   - **Platform**: iOS
   - **Name**: Viso AI - Photo Avatar Headshot
   - **Primary Language**: English (U.S.)
   - **Bundle ID**: com.visoai.photoheadshot
   - **SKU**: visoai-001 (unique identifier)

### 5.3. Complete App Information

**App Information:**
- ✅ Category: Photo & Video
- ✅ Subcategory: Tùy chọn
- ✅ Content Rights: "Does not use third-party content"

**Pricing:**
- ✅ Price: Free (hoặc set giá)

**App Privacy:**
- ✅ Privacy Policy URL (bắt buộc)
- ✅ Complete questionnaire về data collection

**Age Rating:**
- Complete questionnaire → Likely 12+ or 17+ (vì AI content)

**App Review Information:**
- ✅ Contact info (phone, email)
- ✅ Demo account (nếu cần login)
- ✅ Notes cho reviewer

**Version Information:**
- ✅ Screenshots (tối thiểu):
  - 6.5" iPhone: 1242x2688 (2-10 ảnh)
  - 12.9" iPad: 2048x2732 (optional)
- ✅ Description (tối đa 4000 ký tự)
- ✅ Keywords (tối đa 100 ký tự, cách nhau bằng dấu phẩy)
- ✅ Support URL
- ✅ Marketing URL (optional)

### 5.4. Submit for Review

1. Select build (từ Xcode upload)
2. Complete all required fields
3. Click **Submit for Review**
4. Wait 1-7 days for approval

---

## ✅ iOS Checklist

- [ ] Xcode 16+ installed
- [ ] Apple Developer Program enrolled ($99/year)
- [ ] Update CocoaPods
- [ ] Create `PrivacyInfo.xcprivacy` với Required Reason APIs
- [ ] Update Info.plist permissions
- [ ] Config Xcode signing (Team, Bundle ID)
- [ ] Tạo prod.json với REAL keys (iOS specific)
- [ ] Build IPA với --obfuscate
- [ ] Validate app trong Xcode Organizer
- [ ] Upload to App Store Connect
- [ ] Complete app information
- [ ] Submit for review

---

# 🔐 PHẦN 3: SECRETS MANAGEMENT BEST PRACTICES

## 📁 Cấu Trúc Secrets Files

```
project/
├── .env/
│   ├── dev.json          # Development (test keys)
│   ├── staging.json      # Staging
│   └── prod.json         # Production (REAL keys)
├── .env.example          # Template (commit vào Git)
└── .gitignore            # Chặn .env/ folder
```

## 🔑 Prod.json Template (Android & iOS)

```json
{
  "SUPABASE_URL": "https://xxxxx.supabase.co",
  "SUPABASE_ANON_KEY": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "HUGGINGFACE_TOKEN": "hf_xxxxxxxxxxxxxxxxxxxxxxxx",
  "REPLICATE_API_TOKEN": "r8_xxxxxxxxxxxxxxxxxxxxxxxx",
  
  "ADMOB_APP_ID_ANDROID": "ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX",
  "ADMOB_APP_ID_IOS": "ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX",
  "ADMOB_REWARDED_AD_UNIT_ID": "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX",
  
  "APPLOVIN_SDK_KEY": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  
  "SUPPORT_EMAIL": "support@yourdomain.com"
}
```

## 🛡️ Security Best Practices

1. **NEVER commit secrets to Git**
   ```gitignore
   .env/
   *.env
   prod.json
   key.properties
   *.jks
   ```

2. **Use password manager** (1Password, LastPass, Bitwarden)
3. **Obfuscate builds**: Always use `--obfuscate`
4. **Rotate keys** nếu bị leak
5. **Use backend proxy** cho highly sensitive keys

---

# 📊 PHẦN 4: COMMON ISSUES & TROUBLESHOOTING

## ❌ Google Play Rejections

### Issue: "Target API level too low"
**Fix:** Update `targetSdkVersion` = 35 trong `android/app/build.gradle`

### Issue: "Privacy policy URL invalid"
**Fix:** 
- Host trên HTTPS
- Không dùng Google Docs editable
- URL phải active (không 404)

### Issue: "Data Safety form incomplete"
**Fix:** Điền đầy đủ form, match với privacy policy

### Issue: "Missing required permissions declaration"
**Fix:** Thêm permissions vào AndroidManifest.xml

---

## ❌ App Store Rejections

### Issue: "ITMS-91053: Missing API declaration"
**Fix:** Add Required Reason APIs vào `PrivacyInfo.xcprivacy`

### Issue: "Invalid privacy manifest"
**Fix:** 
- Verify reason codes đúng
- Check XML format valid

### Issue: "App crashes on launch"
**Fix:**
- Test trên real device trước khi submit
- Check crash logs trong Xcode Organizer

### Issue: "Missing screenshot sizes"
**Fix:** Upload đủ sizes theo Apple requirements

---

# 🎯 PHẦN 5: FINAL CHECKLIST

## 📱 Before Submitting to Stores:

### Both Platforms:
- [ ] Test app thoroughly trên real devices
- [ ] All features work với REAL API keys
- [ ] Privacy policy hosted và accessible
- [ ] Screenshots chất lượng cao
- [ ] App description đầy đủ, hấp dẫn
- [ ] Support email responsive
- [ ] Version numbers correct

### Android Specific:
- [ ] AAB file build thành công
- [ ] Signed với upload keystore
- [ ] Data Safety Form complete
- [ ] Content rating complete
- [ ] Target API 35

### iOS Specific:
- [ ] IPA file build thành công
- [ ] Privacy Manifest complete
- [ ] All Required Reason APIs declared
- [ ] Xcode signing configured
- [ ] TestFlight tested (optional nhưng recommended)

---

## 📞 Support Resources

- **Google Play Help**: https://support.google.com/googleplay/android-developer
- **App Store Connect Help**: https://developer.apple.com/support/app-store-connect/
- **Flutter Deployment Docs**: https://docs.flutter.dev/deployment

---

**🎉 CHÚC ANH LAUNCH THÀNH CÔNG!** 🚀
