# Build Manual cho Windows (Không dùng script)

Nếu PowerShell script không chạy được, bạn có thể build thủ công:

## Cách 1: Build với AdMob Test Ads (Đơn giản nhất)

```powershell
flutter build apk --release --dart-define=ADMOB_REWARDED_AD_UNIT_ID="ca-app-pub-3940256099942544/5224354917" --dart-define=ADMOB_BANNER_AD_UNIT_ID="ca-app-pub-3940256099942544/6300978111" --dart-define=ADMOB_INTERSTITIAL_AD_UNIT_ID="ca-app-pub-3940256099942544/1033173712"
```

**Lưu ý:** Bạn vẫn cần SUPABASE_URL và các API keys khác. Xem cách 2.

---

## Cách 2: Build với tất cả secrets (Copy/Paste từ Replit)

### Bước 1: Lấy secrets từ Replit

Vào Replit project → Tools → Secrets, copy các giá trị:
- SUPABASE_URL
- SUPABASE_ANON_KEY
- HUGGINGFACE_TOKEN
- REPLICATE_API_TOKEN

### Bước 2: Set environment variables trong PowerShell

```powershell
# Set từng biến (thay YOUR_VALUE bằng giá trị thật)
$env:SUPABASE_URL = "https://your-project.supabase.co"
$env:SUPABASE_ANON_KEY = "your_anon_key"
$env:HUGGINGFACE_TOKEN = "hf_xxxxx"
$env:REPLICATE_API_TOKEN = "r8_xxxxx"

# Ad IDs (dùng test ads)
$env:ADMOB_REWARDED_AD_UNIT_ID = "ca-app-pub-3940256099942544/5224354917"
$env:ADMOB_BANNER_AD_UNIT_ID = "ca-app-pub-3940256099942544/6300978111"
```

### Bước 3: Build APK

```powershell
flutter build apk --release --dart-define=SUPABASE_URL="$env:SUPABASE_URL" --dart-define=SUPABASE_ANON_KEY="$env:SUPABASE_ANON_KEY" --dart-define=HUGGINGFACE_TOKEN="$env:HUGGINGFACE_TOKEN" --dart-define=REPLICATE_API_TOKEN="$env:REPLICATE_API_TOKEN" --dart-define=ADMOB_REWARDED_AD_UNIT_ID="$env:ADMOB_REWARDED_AD_UNIT_ID" --dart-define=ADMOB_BANNER_AD_UNIT_ID="$env:ADMOB_BANNER_AD_UNIT_ID"
```

---

## Cách 3: Build command một dòng (All-in-one)

**Thay thế YOUR_XXX bằng giá trị thật:**

```powershell
flutter build apk --release --dart-define=SUPABASE_URL="https://YOUR_PROJECT.supabase.co" --dart-define=SUPABASE_ANON_KEY="YOUR_ANON_KEY" --dart-define=HUGGINGFACE_TOKEN="YOUR_HF_TOKEN" --dart-define=REPLICATE_API_TOKEN="YOUR_REPLICATE_TOKEN" --dart-define=ADMOB_REWARDED_AD_UNIT_ID="ca-app-pub-3940256099942544/5224354917"
```

---

## Install APK

```powershell
adb install build\app\outputs\flutter-apk\app-release.apk
```

---

## Xem logs

```powershell
# Xem ads logs
adb logcat | Select-String "AppLovin|AdMob|Rewarded"

# Hoặc tất cả logs
adb logcat
```

---

## Troubleshooting

### "flutter: command not found"

**Giải pháp:**
```powershell
# Kiểm tra Flutter có trong PATH không
flutter --version

# Nếu không có, add Flutter vào PATH hoặc dùng full path
C:\path\to\flutter\bin\flutter build apk --release ...
```

### "Unable to locate Android SDK"

**Giải pháp:**
```powershell
# Chạy flutter doctor
flutter doctor

# Cài Android Studio để có SDK
# https://developer.android.com/studio
```

### Build thành công nhưng ads không hiển thị

**Kiểm tra:**
1. App có được build với `--dart-define` không?
2. Xem logcat khi app khởi động:
   ```powershell
   adb logcat | Select-String "AppLovin|AdMob"
   ```
3. Tìm dòng: "[OK] ADMOB_REWARDED_AD_UNIT_ID: Found"

---

## Test Ads IDs (Google AdMob - Luôn hoạt động)

**Android:**
- Rewarded: `ca-app-pub-3940256099942544/5224354917`
- Banner: `ca-app-pub-3940256099942544/6300978111`
- Interstitial: `ca-app-pub-3940256099942544/1033173712`

**iOS:**
- Rewarded: `ca-app-pub-3940256099942544/1712485313`
- Banner: `ca-app-pub-3940256099942544/2934735716`
- Interstitial: `ca-app-pub-3940256099942544/4411468910`

---

## TL;DR - Quickest way

```powershell
# 1. Set minimal secrets
$env:SUPABASE_URL = "https://your-project.supabase.co"
$env:SUPABASE_ANON_KEY = "your_key"

# 2. Build
flutter build apk --release --dart-define=SUPABASE_URL="$env:SUPABASE_URL" --dart-define=SUPABASE_ANON_KEY="$env:SUPABASE_ANON_KEY" --dart-define=ADMOB_REWARDED_AD_UNIT_ID="ca-app-pub-3940256099942544/5224354917"

# 3. Install
adb install build\app\outputs\flutter-apk\app-release.apk
```
