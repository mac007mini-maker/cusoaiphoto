# 🔐 Firebase Remote Config - Secure Ad IDs Setup Guide

## 📋 Table of Contents
- [Tại Sao Cần Bảo Mật Ad IDs?](#tại-sao-cần-bảo-mật-ad-ids)
- [Cách Hoạt Động](#cách-hoạt-động)
- [Setup Guide](#setup-guide)
- [Testing & Verification](#testing--verification)
- [Troubleshooting](#troubleshooting)

---

## 🛡️ Tại Sao Cần Bảo Mật Ad IDs?

### Vấn Đề:
- **APK dễ bị decompile** → Ad Unit IDs bị lộ
- **Kẻ xấu có thể:**
  - Fake clicks → Google/AppLovin ban account
  - Gắn Ad IDs của bạn vào app khác
  - Vi phạm AdMob/AppLovin policies

### Giải Pháp:
✅ **Firebase Remote Config** - Ad IDs không nằm trong APK  
✅ **Thay đổi real-time** - Không cần update app  
✅ **A/B Testing** - Test các ad networks khác nhau  
✅ **Rotate/Block IDs** - Nếu bị abuse

---

## ⚙️ Cách Hoạt Động

### Priority System (3 Layers):

```
┌─────────────────────────────────────┐
│ 1️⃣ Firebase Remote Config (HIGHEST) │  ← Production IDs (Secure)
│    🔐 IDs stored on Firebase        │
│    ✅ Can change without app update │
└─────────────────────────────────────┘
              ↓ (if empty)
┌─────────────────────────────────────┐
│ 2️⃣ Environment Variables (MEDIUM)   │  ← Build-time IDs
│    ⚙️ --dart-define at build time   │
│    ⚠️ Still in APK (less secure)    │
└─────────────────────────────────────┘
              ↓ (if empty)
┌─────────────────────────────────────┐
│ 3️⃣ Test IDs (FALLBACK)              │  ← Development Only
│    🧪 Google/AppLovin test ads      │
│    ✅ Safe for testing              │
└─────────────────────────────────────┘
```

### Flow Diagram:

```
App Start
    ↓
Firebase Remote Config Initialize
    ↓
Fetch Ad IDs from Remote Config
    ↓
┌───────────────────────────────┐
│ Remote Config has Ad IDs?     │
└───────────────────────────────┘
    ↓ YES                ↓ NO
Use Remote IDs     Check Env Vars
    ↓                     ↓
                  ┌──────────────────┐
                  │ Env Vars exist?  │
                  └──────────────────┘
                    ↓ YES      ↓ NO
                Use Env IDs  Use Test IDs
                    ↓            ↓
                  ┌────────────────┐
                  │   Show Ads     │
                  └────────────────┘
```

---

## 🚀 Setup Guide

### BƯỚC 1: Lấy Production Ad Unit IDs

#### 1.1. AdMob IDs:
1. Vào [AdMob Console](https://apps.admob.com/)
2. **Apps** → Chọn app của bạn
3. Copy **App ID** (Settings → App settings)
4. **Ad units** → Copy các **Ad Unit IDs**:

```
📱 Android:
  App ID: ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY (với dấu ~)
  Banner: ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY (với dấu /)
  App Open: ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY
  Rewarded: ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY
  Interstitial: ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY
  Native: ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY

🍎 iOS:
  App ID: ca-app-pub-XXXXXXXXXXXXXXXX~ZZZZZZZZZZ (với dấu ~)
  Banner: ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ (với dấu /)
  App Open: ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ
  Rewarded: ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ
  Interstitial: ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ
  Native: ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ
```

#### 1.2. AppLovin IDs:
1. Vào [AppLovin MAX Dashboard](https://dash.applovin.com/)
2. **MAX** → **Mediation** → **Manage** → **Ad Units**
3. Copy các IDs:

```
SDK Key: abc123def456... (từ Settings → Keys)

Ad Unit IDs:
  Banner: xxxxxxxxxxxxxxxx
  App Open: xxxxxxxxxxxxxxxx
  Rewarded: xxxxxxxxxxxxxxxx
  Interstitial: xxxxxxxxxxxxxxxx
  Native: xxxxxxxxxxxxxxxx
```

---

### BƯỚC 2: Thêm Parameters vào Firebase Remote Config

1. **Vào Firebase Console:**
   - [Firebase Console](https://console.firebase.google.com/)
   - Chọn project của bạn
   - **Engage** → **Remote Config**

2. **Click "Add parameter"** cho TỪNG parameter dưới đây:

#### 2.1. AdMob Parameters (12 parameters):

| Parameter Key | Data Type | Default Value | Description |
|--------------|-----------|---------------|-------------|
| `admob_app_android_id` | String | `""` (empty) | AdMob App ID cho Android |
| `admob_app_ios_id` | String | `""` (empty) | AdMob App ID cho iOS |
| `admob_banner_android_id` | String | `""` (empty) | AdMob Banner Ad Unit ID cho Android |
| `admob_banner_ios_id` | String | `""` (empty) | AdMob Banner Ad Unit ID cho iOS |
| `admob_app_open_android_id` | String | `""` (empty) | AdMob App Open Ad Unit ID cho Android |
| `admob_app_open_ios_id` | String | `""` (empty) | AdMob App Open Ad Unit ID cho iOS |
| `admob_rewarded_android_id` | String | `""` (empty) | AdMob Rewarded Ad Unit ID cho Android |
| `admob_rewarded_ios_id` | String | `""` (empty) | AdMob Rewarded Ad Unit ID cho iOS |
| `admob_interstitial_android_id` | String | `""` (empty) | AdMob Interstitial Ad Unit ID cho Android |
| `admob_interstitial_ios_id` | String | `""` (empty) | AdMob Interstitial Ad Unit ID cho iOS |
| `admob_native_android_id` | String | `""` (empty) | AdMob Native Ad Unit ID cho Android |
| `admob_native_ios_id` | String | `""` (empty) | AdMob Native Ad Unit ID cho iOS |

**Example:**
```
Parameter key: admob_banner_android_id
Data type: String
Default value: ca-app-pub-1234567890123456/1234567890
Description: AdMob Banner Ad Unit ID for Android (production)
```

#### 2.2. AppLovin Parameters (11 parameters):

| Parameter Key | Data Type | Default Value | Description |
|--------------|-----------|---------------|-------------|
| `applovin_sdk_key` | String | `""` (empty) | AppLovin SDK Key (chung cho cả Android & iOS) |
| `applovin_banner_android_id` | String | `""` (empty) | AppLovin Banner Ad Unit ID cho Android |
| `applovin_banner_ios_id` | String | `""` (empty) | AppLovin Banner Ad Unit ID cho iOS |
| `applovin_app_open_android_id` | String | `""` (empty) | AppLovin App Open Ad Unit ID cho Android |
| `applovin_app_open_ios_id` | String | `""` (empty) | AppLovin App Open Ad Unit ID cho iOS |
| `applovin_rewarded_android_id` | String | `""` (empty) | AppLovin Rewarded Ad Unit ID cho Android |
| `applovin_rewarded_ios_id` | String | `""` (empty) | AppLovin Rewarded Ad Unit ID cho iOS |
| `applovin_interstitial_android_id` | String | `""` (empty) | AppLovin Interstitial Ad Unit ID cho Android |
| `applovin_interstitial_ios_id` | String | `""` (empty) | AppLovin Interstitial Ad Unit ID cho iOS |
| `applovin_native_android_id` | String | `""` (empty) | AppLovin Native Ad Unit ID cho Android |
| `applovin_native_ios_id` | String | `""` (empty) | AppLovin Native Ad Unit ID cho iOS |

**Example:**
```
Parameter key: applovin_sdk_key
Data type: String
Default value: abc123def456ghi789jkl...
Description: AppLovin MAX SDK Key (chung cho cả 2 platform)

Parameter key: applovin_banner_android_id
Data type: String
Default value: xxxxxxxxxxxxxxxx
Description: AppLovin Banner Ad Unit ID for Android
```

3. **Click "Publish changes"** để áp dụng!

---

### BƯỚC 3: Verify Setup

#### 3.1. Check Firebase Console:
```
Remote Config → Parameters (Tất cả là String type)

AdMob (12 parameters):
  ✅ admob_app_android_id: ca-app-pub-xxxxx~xxxxx
  ✅ admob_app_ios_id: ca-app-pub-xxxxx~xxxxx
  ✅ admob_banner_android_id: ca-app-pub-xxxxx/xxxxx
  ✅ admob_banner_ios_id: ca-app-pub-xxxxx/xxxxx
  ✅ admob_app_open_android_id: ca-app-pub-xxxxx/xxxxx
  ✅ admob_app_open_ios_id: ca-app-pub-xxxxx/xxxxx
  ✅ admob_rewarded_android_id: ca-app-pub-xxxxx/xxxxx
  ✅ admob_rewarded_ios_id: ca-app-pub-xxxxx/xxxxx
  ✅ admob_interstitial_android_id: ca-app-pub-xxxxx/xxxxx
  ✅ admob_interstitial_ios_id: ca-app-pub-xxxxx/xxxxx
  ✅ admob_native_android_id: ca-app-pub-xxxxx/xxxxx
  ✅ admob_native_ios_id: ca-app-pub-xxxxx/xxxxx

AppLovin (11 parameters):
  ✅ applovin_sdk_key: abc123...
  ✅ applovin_banner_android_id: xxxxx
  ✅ applovin_banner_ios_id: xxxxx
  ✅ applovin_app_open_android_id: xxxxx
  ✅ applovin_app_open_ios_id: xxxxx
  ✅ applovin_rewarded_android_id: xxxxx
  ✅ applovin_rewarded_ios_id: xxxxx
  ✅ applovin_interstitial_android_id: xxxxx
  ✅ applovin_interstitial_ios_id: xxxxx
  ✅ applovin_native_android_id: xxxxx
  ✅ applovin_native_ios_id: xxxxx
```

#### 3.2. Build & Test APK:

**Step 1: Build APK (WITHOUT hardcoded IDs)**
```bash
# Build clean APK - no environment variables
flutter build apk --release
```

**Step 2: Install & Check Logs**
```bash
# Install APK
adb install build/app/outputs/flutter-apk/app-release.apk

# Watch logs
adb logcat | grep -E "AdMob|AppLovin|Remote Config"
```

**Expected Logs (SUCCESS):**
```
✅ Remote Config initialized
🔐 Using AdMob Banner ID from Remote Config (Android)
🔐 Using AppLovin SDK Key from Remote Config
✅ AdMob Banner service initialized
✅ AppLovin MAX initialized successfully
```

**If Remote Config FAILS (Fallback):**
```
⚠️ Remote Config error: ...
⚙️ Using AdMob Banner ID from Environment (Android)  ← Layer 2
🧪 Using AdMob Banner Test ID (Android)             ← Layer 3 (last resort)
```

---

## 🧪 Testing & Verification

### Test Scenarios:

#### ✅ Scenario 1: Production IDs (Remote Config)
```
Remote Config: ✅ Has production IDs
Environment Vars: ❌ None
Expected: 🔐 Use Remote Config IDs
```

#### ✅ Scenario 2: Build-time IDs (Env Vars)
```
Remote Config: ❌ Empty/Failed
Environment Vars: ✅ Has IDs
Expected: ⚙️ Use Environment IDs
```

#### ✅ Scenario 3: Test Mode (Development)

**AdMob:**
```
Remote Config: ❌ Empty/Failed
Environment Vars: ❌ None
Expected: 🧪 Use Google Test IDs (safe for dev)
```

**AppLovin:**
```
Remote Config: ❌ Empty/Failed
Environment Vars: ❌ None
Expected: ⚠️ Ads disabled (AppLovin has no public test IDs)
Note: AppLovin requires SDK Key + Ad Unit setup in dashboard
      Use test device IDs for testing: AppLovinMAX.setTestDeviceAdvertisingIds()
```

### Verify Ad Display:

1. **Banner Ads:**
   - Open any page với bottom navigation
   - Banner ad should appear above nav bar

2. **App Open Ads:**
   - Close app
   - Open app again
   - Ad should show on app resume

3. **Rewarded Ads:**
   - Go to Swapface page
   - Click "Swap Face"
   - Watch rewarded ad

---

## 🔄 Update Ad IDs (No App Update Needed!)

### Khi Nào Cần Update?

1. **Ad Unit IDs bị ban/suspended**
2. **Muốn rotate IDs định kỳ (security)**
3. **A/B test different networks**
4. **Phát hiện abuse/fraud**

### Cách Update:

1. **Firebase Console** → **Remote Config**
2. **Edit parameter** (ví dụ: `admob_banner_android_id`)
3. **Change value** → Paste new Ad Unit ID
4. **Publish changes**
5. **DONE!** App sẽ fetch ID mới trong 1 giờ (hoặc ngay khi restart)

**🎉 Không cần build lại APK!**

---

## 🛡️ Security Best Practices

### ✅ DO:
- ✅ Store production IDs **ONLY** in Firebase Remote Config
- ✅ Keep test IDs in code (safe, public test IDs)
- ✅ Use environment variables for CI/CD builds only
- ✅ Rotate IDs định kỳ (mỗi 3-6 tháng)
- ✅ Monitor Firebase Analytics for suspicious activity

### ❌ DON'T:
- ❌ Commit production IDs to Git/GitHub
- ❌ Share Ad Unit IDs publicly
- ❌ Hardcode production IDs trong code
- ❌ Use same IDs across multiple apps

---

## ⚠️ Troubleshooting

### Issue 1: "App vẫn dùng Test IDs"

**Nguyên nhân:**
- Remote Config chưa publish
- Fetch interval chưa hết
- Network error

**Fix:**
```dart
// Force immediate fetch (debug only)
await RemoteConfigService().refresh();
// hoặc
// Restart app
```

### Issue 2: "Ads không hiển thị"

**Check:**
1. **Firebase Console** → Verify IDs đúng format
2. **AdMob/AppLovin Dashboard** → Verify IDs active
3. **Logs:** `adb logcat | grep -E "AdMob|AppLovin"`
4. **Remote Config:** `ads_enabled = true`

### Issue 3: "Remote Config fetch failed"

**Possible causes:**
- No internet connection
- Firebase not initialized
- Quota exceeded (100 fetch/hour limit)

**Fix:**
```dart
// Check default values exist
await _remoteConfig.setDefaults({
  'admob_banner_android_id': '',  // Ensure defaults
  ...
});
```

---

## 📊 A/B Testing (Advanced)

### Test Different Ad Networks:

1. **Firebase Console** → **A/B Testing**
2. **Create experiment:**
   - **Name:** "AdMob vs AppLovin - Banner Ads"
   - **Goal:** Optimize ad revenue
   - **Variants:**
     - **Variant A (50%):** `banner_ad_network = admob`
     - **Variant B (50%):** `banner_ad_network = applovin`
3. **Metrics to track:**
   - Revenue per user (RPU)
   - Ad fill rate
   - eCPM (effective cost per mille)
   - User retention

---

## 🎯 Summary

| Feature | Benefit |
|---------|---------|
| 🔐 **Remote Config** | Ad IDs không trong APK → bảo mật |
| 🔄 **Real-time Update** | Thay IDs không cần update app |
| 🧪 **Test Mode** | Development an toàn với test IDs |
| 📊 **A/B Testing** | Tối ưu revenue với experiments |
| ⚙️ **3-Layer Fallback** | Remote → Env Vars → Test IDs |

---

## 📝 Quick Reference

### Test với Test IDs (Development):
```bash
# Build APK - sẽ dùng test IDs
flutter build apk --release
```

### Build với Environment IDs (CI/CD):
```bash
# Build với env vars (Layer 2)
flutter build apk --release \
  --dart-define=ADMOB_BANNER_AD_UNIT_ID=ca-app-pub-xxx/yyy
```

### Production (Remote Config):
```
1. Add production IDs vào Firebase Remote Config
2. Publish changes
3. Build APK clean (no env vars)
4. App tự động fetch IDs từ Remote Config ✅
```

---

## 🔗 Resources

- [Firebase Remote Config Docs](https://firebase.google.com/docs/remote-config)
- [AdMob Ad Units](https://support.google.com/admob/answer/7356431)
- [AppLovin MAX Integration](https://dash.applovin.com/documentation/mediation/flutter/getting-started/integration)
- [A/B Testing Guide](https://firebase.google.com/docs/ab-testing)

---

**🎉 Setup Complete!** Ad IDs của bạn giờ đã được bảo mật và có thể quản lý từ xa! 🔐
