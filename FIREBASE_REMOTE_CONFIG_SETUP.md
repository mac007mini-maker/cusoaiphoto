# 🔥 Firebase Remote Config Setup Guide - Bật/Tắt Ads Từ Xa

## 📋 TÓM TẮT

Guide này hướng dẫn chi tiết cách setup **Firebase Remote Config** để:
- ✅ Bật/tắt ads từ xa (không cần update app)
- ✅ Control banner ads, rewarded ads riêng biệt
- ✅ Marketing strategy: Tắt ads khi 0-5k users → Bật ads khi 5k-10k users
- ✅ 100% policy-compliant (Google official solution)

---

## 🚀 BƯỚC 1: TẠO FIREBASE PROJECT

### 1.1. Tạo Project (hoặc dùng project có sẵn)

1. Vào [Firebase Console](https://console.firebase.google.com)
2. Click **"Add project"** (hoặc chọn project hiện tại)
3. Điền tên project: `viso-ai-photo-avatar` (hoặc tên tùy chọn)
4. Enable Google Analytics (recommended)
5. Click **"Create project"**

---

## 📱 BƯỚC 2: THÊM ANDROID APP

### 2.1. Thêm Android App vào Firebase

1. Trong Firebase Console, click **⚙️ Project Settings**
2. Click **"Add app"** → Chọn **Android** icon
3. Điền thông tin:
   ```
   Android package name: com.visoai.photoheadshot
   App nickname (optional): Viso AI Android
   Debug signing certificate SHA-1: (optional, bỏ qua)
   ```
4. Click **"Register app"**

### 2.2. Download google-services.json

1. Click **"Download google-services.json"**
2. Copy file vào project tại: `android/app/google-services.json`

### 2.3. Cấu hình Android (Đã có sẵn)

Firebase SDK đã được setup sẵn trong project này. Verify file `android/build.gradle`:

```gradle
// Đã có: Google Services plugin
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.2'
    }
}
```

File `android/app/build.gradle`:

```gradle
// Đã có: Apply plugin
apply plugin: 'com.google.gms.google-services'
```

---

## 🍎 BƯỚC 3: THÊM iOS APP

### 3.1. Thêm iOS App vào Firebase

1. Trong Firebase Console, click **"Add app"** → Chọn **iOS** icon
2. Điền thông tin:
   ```
   iOS bundle ID: com.visoai.photoheadshot
   App nickname (optional): Viso AI iOS
   App Store ID: (bỏ qua nếu chưa publish)
   ```
3. Click **"Register app"**

### 3.2. Download GoogleService-Info.plist

1. Click **"Download GoogleService-Info.plist"**
2. Copy file vào project:
   - **Manual:** Đặt trong `ios/Runner/GoogleService-Info.plist`
   - **Xcode:** Drag & drop vào `Runner` folder (recommended)

### 3.3. Cấu hình iOS (Đã có sẵn)

Firebase SDK đã được setup sẵn. Verify file `ios/Runner/Info.plist`:

```xml
<!-- Đã có: Google Services URL Scheme -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

---

## 🌐 BƯỚC 4: THÊM WEB APP (Optional)

### 4.1. Thêm Web App

1. Click **"Add app"** → Chọn **Web** icon (</> icon)
2. Điền App nickname: `Viso AI Web`
3. ✅ Check **"Also set up Firebase Hosting"** (recommended)
4. Click **"Register app"**

### 4.2. Copy Firebase Config

Firebase sẽ hiển thị config code:

```javascript
const firebaseConfig = {
  apiKey: "AIzaSy...",
  authDomain: "viso-ai-....firebaseapp.com",
  projectId: "viso-ai-...",
  storageBucket: "viso-ai-....appspot.com",
  messagingSenderId: "...",
  appId: "1:...:web:...",
  measurementId: "G-..."
};
```

**✅ DONE - File `lib/firebase_options.dart` đã được tạo với config thực tế:**

```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return ios;
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC2VGc-o0LbF10JHn-nRU53chEY5FiXO_c',
    authDomain: 'viso-ai-photo-avatar.firebaseapp.com',
    projectId: 'viso-ai-photo-avatar',
    storageBucket: 'viso-ai-photo-avatar.firebasestorage.app',
    messagingSenderId: '987545828793',
    appId: '1:987545828793:web:8ae2e8f8feda5c44bb4a68',
    measurementId: 'G-ETCJCW0GDT',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCbqiWSgg7FqVt3luFUerAibXk97lnxYaE',
    appId: '1:987545828793:android:7c1fbb39b74255a4bb4a68',
    messagingSenderId: '987545828793',
    projectId: 'viso-ai-photo-avatar',
    storageBucket: 'viso-ai-photo-avatar.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyATFSyLkOYrpLvQ87Qu6_grUUkmuBaL9ak',
    appId: '1:987545828793:ios:836edababf0b4769bb4a68',
    messagingSenderId: '987545828793',
    projectId: 'viso-ai-photo-avatar',
    storageBucket: 'viso-ai-photo-avatar.firebasestorage.app',
    iosBundleId: 'com.visoai.photoheadshot',
  );
}
```

**✅ DONE - `main.dart` đã được update:**

```dart
import 'firebase_options.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // ...
}
```

---

## ⚙️ BƯỚC 5: SETUP REMOTE CONFIG PARAMETERS

### 5.1. Vào Remote Config

1. Firebase Console → **Engage** → **Remote Config**
2. Click **"Create configuration"**

### 5.2. Tạo Parameters

Click **"Add parameter"** cho từng parameter sau:

#### **Parameter 1: ads_enabled**
```
Parameter key: ads_enabled
Data type: Boolean
Default value: false  ← BẮT ĐẦU VỚI FALSE (marketing phase)
Description: Master switch to enable/disable all ads
```

#### **Parameter 2: banner_ads_enabled**
```
Parameter key: banner_ads_enabled
Data type: Boolean
Default value: false
Description: Control banner ads in bottom navigation
```

#### **Parameter 3: rewarded_ads_enabled**
```
Parameter key: rewarded_ads_enabled
Data type: Boolean
Default value: false
Description: Control rewarded ads (face swap, etc.)
```

#### **Parameter 4: interstitial_ads_enabled**
```
Parameter key: interstitial_ads_enabled
Data type: Boolean
Default value: false
Description: Control interstitial ads (future use)
```

#### **Parameter 5: app_open_ads_enabled**
```
Parameter key: app_open_ads_enabled
Data type: Boolean
Default value: false
Description: Control app open ads (shown on app launch/resume)
```

#### **Parameter 6: native_ads_enabled**
```
Parameter key: native_ads_enabled
Data type: Boolean
Default value: false
Description: Control native ads (future use)
```

#### **Parameter 7: min_user_count_for_ads**
```
Parameter key: min_user_count_for_ads
Data type: Number
Default value: 5000
Description: Minimum user count before enabling ads
```

### 5.3. Publish Changes

1. Click **"Publish changes"**
2. Confirm với **"Publish"**

✅ **Remote Config đã sẵn sàng!**

---

## 🎮 BƯỚC 6: TEST REMOTE CONFIG

### 6.1. Build & Run App

**Web:**
```bash
flutter run -d chrome
```

**Android:**
```bash
flutter run
```

**iOS:**
```bash
flutter run
```

### 6.2. Check Console Logs

Khi app khởi động, anh sẽ thấy logs:

```
✅ Firebase initialized
✅ Remote Config initialized
   - ads_enabled: false
   - banner_ads_enabled: false
   - rewarded_ads_enabled: false
   - app_open_ads_enabled: false
   - native_ads_enabled: false
🚫 Ads disabled via Remote Config - skipping ad initialization
```

### 6.3. Verify Ads Disabled

- ✅ Bottom navigation KHÔNG có ad banner
- ✅ Face swap button KHÔNG yêu cầu xem ads (proceed trực tiếp)
- ✅ Console log: "🚫 Rewarded ads disabled via Remote Config"

---

## 📈 BƯỚC 7: BẬT ADS THEO CHIẾN LƯỢC

### 7.1. Marketing Phase (0-5k users)

**Firebase Console → Remote Config:**

```
ads_enabled = false
banner_ads_enabled = false
rewarded_ads_enabled = false
app_open_ads_enabled = false
native_ads_enabled = false
```

**Click "Publish changes"**

**Kết quả:**
- ✅ User download app → KHÔNG thấy ads
- ✅ Trải nghiệm mượt mà → Retention cao
- ✅ Word-of-mouth marketing tốt

### 7.2. Monetization Phase (5k+ users)

**Firebase Console → Remote Config:**

```
ads_enabled = true              ← Toggle to TRUE (master switch)
banner_ads_enabled = true       ← Enable banner ads
rewarded_ads_enabled = true     ← Enable rewarded ads
app_open_ads_enabled = true     ← Enable app open ads
native_ads_enabled = false      ← Keep disabled (future use)
```

**Click "Publish changes"**

**Kết quả:**
- ✅ Ads bật NGAY LẬP TỨC (không cần update app!)
- ✅ User hiện tại: Bắt đầu thấy ads
- ✅ User mới: Thấy ads từ đầu

### 7.3. Verify Changes

**User mở app lại:**
```
✅ Firebase initialized
✅ Remote Config initialized
   - ads_enabled: true          ← Changed!
   - banner_ads_enabled: true
   - rewarded_ads_enabled: true
   - app_open_ads_enabled: true
   - native_ads_enabled: false
📢 Ads enabled via Remote Config - initializing ad services
```

- ✅ Bottom navigation có ad banner
- ✅ Face swap yêu cầu xem rewarded ad
- ✅ Ads hoạt động bình thường

---

## 🎯 BƯỚC 8: ADVANCED - CONDITIONAL TARGETING

### 8.1. Add Conditions (Optional)

Firebase Remote Config hỗ trợ targeting theo:
- **Country/Region**: Bật ads chỉ ở US, tắt ở Vietnam
- **App Version**: Bật ads từ version 1.2.0+
- **User Property**: Tắt ads cho premium users
- **Random Percentile**: A/B testing (50% users thấy ads)

**Ví dụ: Tắt ads cho Vietnam (marketing):**

1. Click **"Add condition"** trong Remote Config
2. Chọn **"User in region/country"**
3. Select **"Vietnam"**
4. Set value: `ads_enabled = false`
5. Default (other countries): `ads_enabled = true`

### 8.2. User Property - Premium Users

**In app code:**

```dart
import 'package:firebase_analytics/firebase_analytics.dart';

// Set user property
await FirebaseAnalytics.instance.setUserProperty(
  name: 'user_type',
  value: 'premium',
);
```

**Firebase Console:**

1. Add condition → **"User property"**
2. Property: `user_type`
3. Operator: `exactly matches`
4. Value: `premium`
5. Set: `ads_enabled = false`

---

## 🔄 BƯỚC 9: UPDATE & REFRESH FLOW

### 9.1. App Lifecycle Refresh

Code đã tự động refresh khi app resume:

```dart
// In main.dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    RemoteConfigService().refresh();
  }
}
```

### 9.2. Manual Refresh (Optional)

Thêm button trong Settings page:

```dart
ElevatedButton(
  onPressed: () async {
    await RemoteConfigService().refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Config updated!')),
    );
  },
  child: Text('Refresh Ads Config'),
)
```

### 9.3. Fetch Intervals

**Development:**
```dart
minimumFetchInterval: const Duration(minutes: 1),  // Test nhanh
```

**Production:**
```dart
minimumFetchInterval: const Duration(hours: 12),  // Tiết kiệm quota
```

---

## ⚠️ TROUBLESHOOTING

### Issue 1: Firebase not initialized

**Error:**
```
❌ Firebase not configured (will use defaults)
```

**Fix:**
1. Verify `google-services.json` (Android) trong `android/app/`
2. Verify `GoogleService-Info.plist` (iOS) trong `ios/Runner/`
3. Verify `firebase_options.dart` có đúng API keys

### Issue 2: Remote Config returns default values

**Possible causes:**
1. Chưa publish changes trong Firebase Console
2. Fetch interval chưa hết (đợi 1 phút hoặc restart app)
3. Network issue (check internet connection)

**Fix:**
```dart
// Force fetch immediately (debug only)
await _remoteConfig.setConfigSettings(RemoteConfigSettings(
  fetchTimeout: const Duration(seconds: 10),
  minimumFetchInterval: Duration.zero,  // No caching
));
await _remoteConfig.fetchAndActivate();
```

### Issue 3: Ads vẫn hiện dù remote config = false

**Check:**
1. Xem console logs để verify remote config values
2. Clear app data và reinstall
3. Verify code check remote config trước khi show ads:

```dart
if (RemoteConfigService().adsEnabled) {
  // Show ads
}
```

---

## 📊 MONITORING & ANALYTICS

### 10.1. Check Firebase Analytics

1. Firebase Console → **Analytics** → **Events**
2. Monitor events:
   - `remote_config_fetched`
   - `remote_config_activated`
   - Ad events (impressions, clicks)

### 10.2. A/B Testing (Advanced)

1. Firebase Console → **A/B Testing**
2. Create experiment:
   - **Goal:** Optimize ad revenue
   - **Variant A:** `ads_enabled = false` (50% users)
   - **Variant B:** `ads_enabled = true` (50% users)
3. Track metrics:
   - Revenue per user
   - Retention rate
   - Session duration

---

## ✅ FINAL CHECKLIST

### Firebase Setup:
- [ ] Firebase project created
- [ ] Android app added + google-services.json downloaded
- [ ] iOS app added + GoogleService-Info.plist downloaded
- [ ] Web app added (optional) + firebase_options.dart created
- [ ] Remote Config parameters created (ads_enabled, banner_ads_enabled, etc.)
- [ ] Default values set (false for marketing phase)
- [ ] Changes published

### App Integration:
- [ ] Dependencies installed (firebase_core, firebase_remote_config)
- [ ] RemoteConfigService created
- [ ] main.dart updated (initialize Firebase + Remote Config)
- [ ] Ads initialization conditional on remote config
- [ ] Bottom navigation checks remote config
- [ ] Rewarded ads check remote config
- [ ] Console logs verify remote config values

### Testing:
- [ ] App builds successfully
- [ ] Remote Config fetched on launch
- [ ] Ads disabled when remote config = false
- [ ] Ads enabled when remote config = true
- [ ] Toggle in Firebase Console works instantly

---

## 🎉 DONE!

Anh đã setup xong Firebase Remote Config! Giờ anh có thể:

1. **Marketing Phase:** Toggle `ads_enabled = false` → Không ads, giữ users
2. **Monetization Phase:** Toggle `ads_enabled = true` → Bật ads ngay lập tức
3. **Premium Users:** Set condition `user_type = premium` → Tắt ads
4. **A/B Testing:** Test 50% users có ads, 50% không ads → Tối ưu revenue

**🚀 Chiến lược thành công!**

---

## 📞 SUPPORT

Có vấn đề? Check:
1. Console logs khi app khởi động
2. Firebase Console → Remote Config → Published values
3. `SECURITY_AND_REMOTE_ADS_GUIDE.md` để hiểu cách hoạt động

**Happy monetizing! 💰**
