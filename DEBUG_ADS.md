# Debug "Ads not ready" Issue

## Bước 1: Xem Logcat khi App khởi động

```powershell
# Kết nối điện thoại và xem ads logs
adb logcat -c  # Clear logs cũ
adb logcat | Select-String "AppLovin|AdMob|Rewarded|ERROR|WARN"
```

**Tìm các dòng:**
- `AppLovin MAX initialized` hoặc `AppLovin initialization failed`
- `AdMob Rewarded ad loaded` hoặc `AdMob ad failed to load`
- `ERROR` hoặc `WARN` liên quan đến ads

---

## Bước 2: Test lại với Google Test Ads

Nếu bạn đang dùng **production ad IDs**, chúng có thể chưa được approve hoặc chưa setup đúng.

**Giải pháp: Dùng Google Test Ads (luôn hoạt động)**

### Sửa file `secrets.env`:

```bash
# Thay thế bằng Google Test Ad IDs
export ADMOB_REWARDED_AD_UNIT_ID="ca-app-pub-3940256099942544/5224354917"
export ADMOB_BANNER_AD_UNIT_ID="ca-app-pub-3940256099942544/6300978111"
export ADMOB_INTERSTITIAL_AD_UNIT_ID="ca-app-pub-3940256099942544/1033173712"

# Để trống AppLovin nếu chưa setup test mode
# export APPLOVIN_SDK_KEY=""
# export APPLOVIN_REWARDED_AD_UNIT_ID=""
```

### Build lại:

```powershell
.\build_with_all_ads.ps1 apk
adb install -r build\app\outputs\flutter-apk\app-release.apk
```

---

## Bước 3: Kiểm tra App Logs

Khi app khởi động, tìm dòng:

### ✅ Ads hoạt động tốt:
```
[OK] AppLovin SDK Key: Found
[OK] AppLovin initialized successfully
[OK] Rewarded ad loaded successfully
```

### ❌ Ads không hoạt động:
```
[ERROR] AppLovin initialization failed: Invalid SDK Key
[ERROR] AdMob ad failed to load: AD_UNIT_NOT_READY
[WARN] Using AdMob fallback...
```

---

## Common Issues & Solutions

### Issue 1: "Invalid SDK Key" hoặc "Ad Unit not found"

**Nguyên nhân:** Production ad IDs chưa được setup trong AdMob/AppLovin dashboard

**Giải pháp:** Dùng Google Test Ad IDs (xem Bước 2)

---

### Issue 2: "No fill" hoặc "Network error"

**Nguyên nhân:** Không có internet hoặc ad network không có ads available

**Giải pháp:**
- Kiểm tra internet connection
- Thử lại sau vài phút
- Dùng Test Ad IDs

---

### Issue 3: "App ID not set" (AppLovin)

**Nguyên nhân:** Thiếu APPLOVIN_SDK_KEY hoặc invalid

**Giải pháp:** 
- Để trống AppLovin secrets trong secrets.env
- App sẽ tự động fallback sang AdMob

```bash
# secrets.env - Chỉ dùng AdMob
export ADMOB_REWARDED_AD_UNIT_ID="ca-app-pub-3940256099942544/5224354917"
# Không set APPLOVIN_SDK_KEY
```

---

### Issue 4: Ads cần thời gian load

**Nguyên nhân:** Ads load asynchronously, cần 2-5 giây

**Giải pháp:** Đợi vài giây sau khi app khởi động, rồi click "Watch Ad"

---

## Recommended: Build với CHỈ AdMob Test Ads

Đây là cách **dễ nhất và chắc chắn hoạt động**:

### 1. Sửa secrets.env:

```bash
export SUPABASE_URL="your_url_here"
export SUPABASE_ANON_KEY="your_key_here"
export HUGGINGFACE_TOKEN="your_token_here"
export REPLICATE_API_TOKEN="your_token_here"

# Chỉ dùng Google Test Ads (luôn hoạt động)
export ADMOB_REWARDED_AD_UNIT_ID="ca-app-pub-3940256099942544/5224354917"
export ADMOB_BANNER_AD_UNIT_ID="ca-app-pub-3940256099942544/6300978111"

# KHÔNG set AppLovin (để app dùng AdMob)
# export APPLOVIN_SDK_KEY=""
```

### 2. Build lại:

```powershell
.\build_with_all_ads.ps1 apk
adb install -r build\app\outputs\flutter-apk\app-release.apk
```

### 3. Test:

1. Mở app
2. **Đợi 5 giây** để ads load
3. Click "Swap Face - Watch Ad"
4. AdMob test ad sẽ hiển thị

---

## Debug Commands

```powershell
# Xem tất cả logs
adb logcat

# Chỉ xem ads logs
adb logcat | Select-String "AppLovin|AdMob|Rewarded"

# Xem ERROR logs
adb logcat | Select-String "ERROR"

# Clear logs và start fresh
adb logcat -c
adb logcat | Select-String "AppLovin|AdMob"
```

---

## TL;DR - Quick Fix

```powershell
# 1. Edit secrets.env - Chỉ dùng AdMob Test Ads
notepad secrets.env

# 2. Copy vào secrets.env:
# export ADMOB_REWARDED_AD_UNIT_ID="ca-app-pub-3940256099942544/5224354917"

# 3. Build lại
.\build_with_all_ads.ps1 apk

# 4. Install
adb install -r build\app\outputs\flutter-apk\app-release.apk

# 5. Xem logs
adb logcat | Select-String "AppLovin|AdMob|Rewarded"

# 6. Mở app, đợi 5 giây, click Watch Ad
```

---

## Expected Logcat Output (Success)

```
I/AppLovinService: SDK Key found: xxx
I/AppLovinService: Initializing AppLovin MAX...
I/AppLovinService: AppLovin MAX initialized successfully
I/AppLovinService: Loading rewarded ad...
I/AppLovinService: Rewarded ad loaded successfully

-- OR (if AppLovin fails) --

E/AppLovinService: AppLovin initialization failed
I/AdMobRewardedService: Using AdMob fallback...
I/AdMobRewardedService: AdMob rewarded ad loaded successfully
```
