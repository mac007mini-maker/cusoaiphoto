# 📱 Hướng dẫn Setup & Debug Ads

## 🔍 Kiểm tra Ads đã hoạt động chưa

### **Bước 1: Xem Logcat/Console**

Khi app khởi động, bạn sẽ thấy logs sau:

#### **AppLovin Ads:**
```
🔍 AppLovin Configuration Check:
  SDK Key: ✅ Found (hoặc ❌ MISSING)
  Rewarded Ad Unit: ✅ Found (hoặc ❌ MISSING)
  Banner Ad Unit: ✅ Found (hoặc ❌ MISSING)
  Interstitial Ad Unit: ✅ Found (hoặc ❌ MISSING)
```

#### **AdMob Ads:**
```
🔍 AdMob Rewarded Configuration Check:
  Rewarded Ad Unit: ✅ Found (hoặc ❌ MISSING - will use test ads)
```

### **Bước 2: Nếu thấy ❌ MISSING**

**Nguyên nhân:** App không được build với ad configuration

**Giải pháp:**
```bash
# Build với tất cả ad secrets
./build_with_all_ads.sh apk

# Hoặc build App Bundle
./build_with_all_ads.sh appbundle
```

---

## 📦 Package Name

**Đúng:** `com.visoai.photoheadshot`

Kiểm tra trong:
- `android/app/build.gradle` → `applicationId "com.visoai.photoheadshot"`
- `android/app/src/main/AndroidManifest.xml` → `package="com.visoai.photoheadshot"`

---

## 🎯 Test Ads Configuration

### **Option 1: AdMob Test Ads (Khuyên dùng - Đơn giản nhất)**

AdMob tự động dùng test ads nếu không có production ID:

**Android Test IDs (đã có sẵn trong code):**
- Banner: `ca-app-pub-3940256099942544/6300978111`
- Interstitial: `ca-app-pub-3940256099942544/1033173712`
- Rewarded: `ca-app-pub-3940256099942544/5224354917` ✅

**iOS Test IDs (đã có sẵn trong code):**
- Banner: `ca-app-pub-3940256099942544/2934735716`
- Interstitial: `ca-app-pub-3940256099942544/4411468910`
- Rewarded: `ca-app-pub-3940256099942544/1712485313` ✅

**Ưu điểm:**
- ✅ Không cần đăng ký
- ✅ Hoạt động ngay lập tức
- ✅ Không bị banned vì policy violation

### **Option 2: AppLovin Test Mode**

**Setup trong AppLovin Dashboard:**
1. Vào https://dash.applovin.com/
2. Settings → Test Mode → Add Test Device
3. Nhập Package Name: `com.visoai.photoheadshot`
4. Nhập Device ID (xem trong Logcat lúc khởi động)

**Hoặc programmatically:**
```dart
AppLovinMAX.setTestDeviceAdvertisingIds(['YOUR_DEVICE_ID']);
```

---

## 🔧 Debugging Steps

### **1. Build đúng cách:**
```bash
# Đảm bảo secrets đã có trong Replit
echo $APPLOVIN_SDK_KEY
echo $ADMOB_REWARDED_AD_UNIT_ID

# Build APK với ad configuration
./build_with_all_ads.sh apk
```

### **2. Install & Check Logs:**
```bash
# Install APK
adb install build/app/outputs/flutter-apk/app-release.apk

# Xem logs
adb logcat | grep -E "AppLovin|AdMob|Rewarded"
```

### **3. Kiểm tra logs khi app khởi động:**

**Nếu thấy:**
```
✅ AppLovin MAX initialized successfully
✅ AdMob initialized successfully
✅ Rewarded ad loaded
```
→ **Ads hoạt động tốt!**

**Nếu thấy:**
```
❌ AppLovin SDK Key not found
💡 Build with: ./build_with_all_ads.sh apk
```
→ **Bạn chưa build đúng cách**

---

## 🚀 Alternative: Unity Ads (Nếu AppLovin/AdMob không hoạt động)

Unity Ads rất dễ setup và tự động test mode:

### **Setup:**

1. **Add package:**
```yaml
# pubspec.yaml
dependencies:
  unity_ads_plugin: ^0.3.11
```

2. **Initialize:**
```dart
// main.dart
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

await UnityAds.init(
  gameId: Platform.isAndroid ? '4374881' : '4374880', // Test IDs
  testMode: true, // Tự động test ads
);
```

3. **Show Rewarded Ad:**
```dart
UnityAds.load(
  placementId: 'Rewarded_Android',
  onComplete: (placementId) => print('Ad loaded'),
  onFailed: (placementId, error, message) => print('Ad failed'),
);

UnityAds.showVideoAd(
  placementId: 'Rewarded_Android',
  onComplete: (placementId) {
    // User xem xong ad
    _swapFace();
  },
);
```

**Ưu điểm Unity Ads:**
- ✅ Tự động test mode
- ✅ Không cần setup phức tạp
- ✅ Fill rate cao
- ✅ Hỗ trợ Flutter tốt

---

## 📊 Recommended Ad Strategy

### **Best Setup (2025):**

**Primary:** AdMob (Test Ads)
- Dễ setup nhất
- Fill rate cao
- Google test ads luôn hoạt động

**Fallback:** Unity Ads
- Tự động test mode
- Ổn định
- Dễ integrate

**Implementation:**
```dart
// Try AdMob first
await AdMobRewardedService.showRewardedAd(
  onComplete: () => _swapFace(),
  onFailed: () async {
    // Fallback to Unity Ads
    UnityAds.showVideoAd(
      placementId: 'Rewarded_Android',
      onComplete: (placementId) => _swapFace(),
    );
  },
);
```

---

## ❓ FAQ

### **Q: Tại sao ads không hiển thị?**
A: 99% do app không được build với `./build_with_all_ads.sh apk`

### **Q: AdMob test ads có hoạt động mãi không?**
A: Có! Google cho phép dùng test ads vô thời hạn trong development.

### **Q: AppLovin test mode setup như thế nào?**
A: Vào Dashboard → Settings → Test Mode → Add device với package name `com.visoai.photoheadshot`

### **Q: Có cách nào dễ hơn không?**
A: Dùng AdMob test ads (đã có sẵn trong code) - không cần setup gì cả!

---

## 📝 Summary

**Để ads hoạt động:**

1. ✅ Build với: `./build_with_all_ads.sh apk`
2. ✅ Xem logs khi app khởi động
3. ✅ Nếu AppLovin fail → AdMob fallback tự động
4. ✅ Nếu cả 2 fail → Cân nhắc Unity Ads

**AdMob test ads (ca-app-pub-3940256099942544/...) là lựa chọn đơn giản nhất và LUÔN hoạt động!**
