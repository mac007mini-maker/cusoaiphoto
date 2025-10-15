# Debug Viso AI App với Logcat

## Bước 1: Filter logs theo package name

Thay vì filter theo keyword, filter theo **package name** của app:

```powershell
# Clear logs
adb logcat -c

# Xem ONLY Viso AI app logs
adb logcat | Select-String "com.visoai.photoheadshot"
```

---

## Bước 2: Mở app và xem logs NGAY LẬP TỨC

### Trong PowerShell Window 1:

```powershell
# Start logcat TRƯỚC KHI mở app
adb logcat -c
adb logcat | Select-String "com.visoai.photoheadshot|AppLovin|AdMob|Flutter"
```

### Trên điện thoại:

1. **Tắt app Viso AI** (nếu đang mở)
2. **Force stop:** Settings → Apps → Viso AI → Force Stop
3. **Mở app lại** từ launcher
4. **ĐỢI 10 GIÂY** để ads load
5. Click **Ghostface** → Add photo → **"Watch Ad"**

### Xem Window 1:

Bạn sẽ thấy logs từ app!

---

## Bước 3: Nếu vẫn không thấy logs gì

### Check app có crash không:

```powershell
# Xem tất cả logs liên quan đến crashes
adb logcat | Select-String "FATAL|AndroidRuntime|crash"
```

### Hoặc xem logs của Flutter engine:

```powershell
# Flutter apps dùng Flutter tag
adb logcat | Select-String "flutter|Flutter"
```

### Hoặc filter theo process ID:

```powershell
# 1. Tìm process ID của app
adb shell ps | Select-String "visoai"

# Output sẽ có dạng:
# u0_a123      12345  1234  ... com.visoai.photoheadshot

# 2. Filter logs theo PID (thay 12345 bằng PID thật)
adb logcat | Select-String "12345"
```

---

## Bước 4: Xem ALL logs (No filter)

Nếu các cách trên không được, xem tất cả logs:

```powershell
# Lưu tất cả logs vào file
adb logcat > all_logs.txt

# Trong điện thoại: Mở app → Click "Watch Ad"

# Sau 30 giây, dừng logcat (Ctrl+C)

# Search trong file
Select-String -Path all_logs.txt -Pattern "AppLovin|AdMob|Rewarded|visoai"
```

---

## Expected Logs (Nếu app hoạt động đúng)

### Khi app khởi động:

```
I/flutter: [OK] Loading secrets from secrets.env...
I/flutter: [OK] AppLovin SDK Key: Found
I/flutter: [OK] AdMob Rewarded Ad Unit: Found
I/flutter: Initializing AppLovin MAX...
I/AppLovinSdk: Initializing SDK with key: xxx
I/flutter: AppLovin MAX initialized successfully
```

### Khi click "Watch Ad":

```
I/flutter: Loading rewarded ad...
I/AppLovinSdk: Loading rewarded ad for unit: xxx
I/AppLovinSdk: Rewarded ad loaded successfully
I/flutter: Showing rewarded ad
```

### Nếu ad failed:

```
E/flutter: AppLovin failed to load: Invalid SDK Key
E/flutter: Falling back to AdMob...
I/flutter: AdMob rewarded ad loaded
```

---

## Quick Debug Commands

```powershell
# 1. Force stop app
adb shell am force-stop com.visoai.photoheadshot

# 2. Clear logs
adb logcat -c

# 3. Start logcat với multiple filters
adb logcat | Select-String "visoai|AppLovin|AdMob|Flutter|FATAL"

# 4. Launch app
adb shell am start -n com.visoai.photoheadshot/.MainActivity

# 5. Xem logs realtime
```

---

## Alternative: Logcat với Colors (Dễ đọc hơn)

```powershell
# Install pidcat (optional)
# https://github.com/JakeWharton/pidcat

# Hoặc dùng Android Studio Logcat viewer
```

---

## TL;DR - Chạy ngay:

```powershell
# Window 1: Logcat
adb logcat -c
adb logcat | Select-String "visoai|AppLovin|AdMob|Flutter|ERROR"

# Window 2: Launch app
adb shell am force-stop com.visoai.photoheadshot
adb shell am start -n com.visoai.photoheadshot/.MainActivity

# Đợi 10 giây → Click "Watch Ad" → Xem Window 1
```
