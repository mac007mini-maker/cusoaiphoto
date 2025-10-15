# Hướng dẫn Test ADB Logcat trên Samsung

## Bước 1: Enable USB Debugging trên Samsung

### Nếu chưa bật Developer Options:

1. Mở **Settings** (Cài đặt)
2. Kéo xuống cuối → **About phone** (Thông tin điện thoại)
3. Tìm **Build number** (Số bản dựng)
4. **Tap 7 lần** vào Build number
5. Nhập mật khẩu/PIN nếu có
6. Thấy thông báo: "You are now a developer!"

### Bật USB Debugging:

1. Quay lại **Settings**
2. **Developer options** (Tùy chọn dành cho nhà phát triển)
3. Bật **USB debugging** (Gỡ lỗi USB)
4. Bật **Install via USB** (Cài đặt qua USB) - nếu có
5. Confirm "Allow USB debugging"

---

## Bước 2: Kiểm tra ADB kết nối

### Trong VSCode PowerShell:

```powershell
# Kiểm tra ADB có hoạt động không
adb version

# Nếu lỗi "adb: command not found", cần add Flutter/Android SDK vào PATH
# Hoặc dùng full path:
C:\Users\YourName\AppData\Local\Android\Sdk\platform-tools\adb.exe version
```

### Kiểm tra devices:

```powershell
# Xem danh sách devices
adb devices

# Nên thấy:
# List of devices attached
# ABC123456789    device    <-- Samsung của bạn
```

**Nếu thấy:**
- `unauthorized` → Mở khoá điện thoại, accept "Allow USB debugging" popup
- `no devices` → Kiểm tra USB cable, thử port USB khác

---

## Bước 3: Chạy Logcat để Debug Ads

### Clear logs cũ:

```powershell
adb logcat -c
```

### Xem realtime ads logs:

```powershell
# Chỉ xem ads-related logs
adb logcat | Select-String "AppLovin|AdMob|Rewarded|VisoAI"
```

### Hoặc lưu logs vào file:

```powershell
# Lưu tất cả logs vào file
adb logcat > logs.txt

# Sau đó search trong file
Select-String -Path logs.txt -Pattern "AppLovin|AdMob|Rewarded"
```

---

## Bước 4: Test Ads Flow

### Mở 2 PowerShell windows:

**Window 1: Run logcat**
```powershell
adb logcat | Select-String "AppLovin|AdMob|Rewarded|ERROR|WARN"
```

**Window 2: Commands**
```powershell
# Uninstall app cũ
adb uninstall com.visoai.photoheadshot

# Install app mới
adb install build\app\outputs\flutter-apk\app-release.apk

# Mở app
adb shell am start -n com.visoai.photoheadshot/.MainActivity
```

**Trong app:**
1. Đợi 5-10 giây
2. Click vào Ghostface
3. Add photo
4. Click "Swap Face - Watch Ad"

**Xem logs trong Window 1** để thấy:
- Ad initialization
- Ad loading status
- Errors (nếu có)

---

## Bước 5: Tìm Lỗi Cụ Thể

### Sau khi click "Watch Ad", tìm dòng:

#### ✅ Success (Ads hoạt động):
```
I/AppLovinService: AppLovin MAX initialized successfully
I/AppLovinService: Rewarded ad loaded successfully
I/AppLovinService: Showing rewarded ad
```

#### ❌ AppLovin Failed:
```
E/AppLovinService: AppLovin initialization failed: Invalid SDK Key
I/AdMobRewardedService: Falling back to AdMob...
```

#### ❌ Both Failed:
```
E/AppLovinService: Failed to load rewarded ad
E/AdMobRewardedService: AdMob ad failed to load: ERROR_CODE_NO_FILL
```

---

## Troubleshooting

### "adb: command not found"

**Giải pháp 1: Add ADB vào PATH**
```powershell
# Tìm adb.exe location (thường trong Flutter SDK hoặc Android SDK)
# C:\Users\YourName\AppData\Local\Android\Sdk\platform-tools\

# Add vào PATH tạm thời:
$env:Path += ";C:\Users\YourName\AppData\Local\Android\Sdk\platform-tools"

# Test lại
adb version
```

**Giải pháp 2: Dùng full path**
```powershell
C:\Users\YourName\AppData\Local\Android\Sdk\platform-tools\adb.exe devices
```

### "unauthorized"

1. Unlock điện thoại
2. Sẽ thấy popup "Allow USB debugging?"
3. Check "Always allow from this computer"
4. Click OK
5. Chạy lại: `adb devices`

### "no devices"

1. Thử USB cable khác (một số cable chỉ charge, không data)
2. Thử USB port khác
3. Tắt/bật USB debugging
4. Chạy: `adb kill-server` rồi `adb start-server`

---

## Quick Test Commands

```powershell
# 1. Check connection
adb devices

# 2. Clear old logs
adb logcat -c

# 3. Start logging
adb logcat | Select-String "AppLovin|AdMob|Rewarded"

# 4. (Trong điện thoại) Mở app và click "Watch Ad"

# 5. Xem logs để tìm error
```

---

## Common Log Patterns

### Pattern 1: Invalid SDK Key
```
E/AppLovinService: SDK Key not found or invalid
E/AppLovinService: Error code: -1
```
→ **Fix:** Dùng test ad IDs trong secrets.env

### Pattern 2: Ad Unit Not Ready
```
W/AdMobRewardedService: Ad unit not ready
W/AdMobRewardedService: Please wait for initialization
```
→ **Fix:** Đợi lâu hơn (5-10 giây)

### Pattern 3: No Fill
```
E/AdMobRewardedService: Ad failed to load
E/AdMobRewardedService: Error code: 3 (NO_FILL)
```
→ **Fix:** Dùng Google test ad IDs (ca-app-pub-3940256099942544/...)

---

## Expected Success Logs

```
I/VisoAI: App started
I/AppLovinService: Checking AppLovin configuration...
I/AppLovinService: SDK Key: Found
I/AppLovinService: Rewarded Ad Unit: Found
I/AppLovinService: Initializing AppLovin MAX...
I/AppLovinService: AppLovin MAX initialized successfully
I/AppLovinService: Loading rewarded ad...
I/AppLovinService: Rewarded ad loaded successfully
I/AppLovinService: Ad is ready to show
-- User clicks "Watch Ad" --
I/AppLovinService: Showing rewarded ad
I/AppLovinService: User completed watching ad
I/AppLovinService: Reward granted
```
