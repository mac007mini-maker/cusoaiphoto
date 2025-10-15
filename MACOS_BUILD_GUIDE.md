# 🍎 Hướng dẫn Build iOS trên macOS M1

## ✅ Prerequisites (Đã có)
- ✅ macOS M1
- ✅ VSCode 
- ✅ Zsh với Flutter SDK đã config
- ✅ iPhone 16 Simulator

## 📋 Bước 1: Kiểm tra môi trường

```zsh
# Kiểm tra Flutter
flutter doctor

# Kiểm tra Xcode
xcodebuild -version

# Kiểm tra simulators
xcrun simctl list devices | grep "iPhone 16"
```

**Nếu thiếu CocoaPods:**
```zsh
sudo gem install cocoapods
```

---

## 🔑 Bước 2: Setup Secrets File

### Tạo `secrets.env` (nếu chưa có)
```zsh
cp secrets.env.template secrets.env
```

### Edit file secrets.env
```zsh
# Mở bằng VSCode
code secrets.env

# HOẶC dùng nano
nano secrets.env
```

### Nội dung `secrets.env`:
```bash
# Required - API Keys
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_supabase_anon_key
HUGGINGFACE_TOKEN=hf_xxxxxxxxxxxxx
REPLICATE_API_TOKEN=r8_xxxxxxxxxxxxx

# Ads (optional - dùng test IDs nếu không có real keys)
ADMOB_APP_ID_IOS=ca-app-pub-3940256099942544~1458002511
ADMOB_REWARDED_AD_UNIT_ID=ca-app-pub-3940256099942544/1712485313
APPLOVIN_SDK_KEY=your_applovin_sdk_key

# Support Email
SUPPORT_EMAIL=jokerlin135@gmail.com
```

**💡 Tip:** Copy keys từ Windows project (secrets.env) sang macOS, chỉ cần đổi `ADMOB_APP_ID_ANDROID` → `ADMOB_APP_ID_IOS`

---

## 🚀 Bước 3: Build & Run (CHỌN 1 TRONG 2 CÁCH)

### **Cách 1: Quick Run (RECOMMENDED) - Hot Reload ⚡**

```zsh
# Cho quyền thực thi script
chmod +x run_ios_simulator.sh

# Run ngay (không cần build riêng)
./run_ios_simulator.sh
```

**✅ Ưu điểm:**
- Nhanh nhất (1-2 phút)
- Hỗ trợ Hot Reload (sửa code không cần restart)
- Tự động load secrets

---

### **Cách 2: Build riêng rồi Run**

```zsh
# Cho quyền thực thi
chmod +x build_ios_simulator.sh

# Build
./build_ios_simulator.sh

# Run
flutter run -d 'iPhone 16'
```

---

## 📱 Bước 4: Test Feedback Dialog

### Sau khi app chạy trên simulator:

1. **Scroll down trang Homepage**
2. **Tìm button "Tell us ✨"** (màu tím, góc phải)
3. **Tap button** → Mở feedback dialog
4. **Nhập feedback:** "Test from iOS simulator"
5. **Tap Submit button**
6. **Kiểm tra:**
   - ✅ Submit button KHÔNG bị che bởi device navigation bar
   - ✅ Mail app mở với email template gửi tới `SUPPORT_EMAIL`
   - ✅ Dialog đóng + hiện thông báo "Thank you for your feedback!"

---

## 🐛 Debug Commands

### Xem logs realtime
```zsh
# Flutter logs
flutter logs

# iOS system logs
xcrun simctl spawn booted log stream --predicate 'process == "Runner"'
```

### Clean build nếu lỗi
```zsh
flutter clean
rm -rf ios/Pods ios/.symlinks ios/Podfile.lock
flutter pub get
cd ios && pod install && cd ..
```

### Restart simulator
```zsh
# Kill simulator
killall Simulator

# Reopen
open -a Simulator
```

---

## ⚡ Quick Commands Cheat Sheet

```zsh
# 1. First time setup
chmod +x *.sh
cp secrets.env.template secrets.env
code secrets.env  # Fill in your keys

# 2. Run app (có hot reload)
./run_ios_simulator.sh

# 3. Xem logs
flutter logs

# 4. Clean nếu lỗi
flutter clean && flutter pub get && cd ios && pod install && cd ..

# 5. List simulators
xcrun simctl list devices | grep iPhone
```

---

## 🎯 So sánh Windows vs macOS

| Feature | Windows (APK) | macOS (iOS Simulator) |
|---------|---------------|----------------------|
| **Build time** | 5-10 phút | 1-2 phút |
| **Hot Reload** | ❌ Cần rebuild APK | ✅ Instant reload |
| **Script** | `.ps1` (PowerShell) | `.sh` (Zsh) |
| **Install** | Copy APK sang phone | Run trực tiếp |
| **Debug** | `adb logcat` | `flutter logs` |

---

## ✅ Expected Output

```
🚀 Running Viso AI on iOS Simulator...
📱 Available simulators:
    iPhone 16 (XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX) (Booted)

🔥 Starting app with hot reload...
Launching lib/main.dart on iPhone 16 in debug mode...
Running pod install...
Running Xcode build...
Xcode build done.                                           15.2s
Syncing files to device iPhone 16...
Flutter run key commands.
r Hot reload. 🔥🔥🔥
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).

💪 Running with sound null safety 💪

An Observatory debugger and profiler on iPhone 16 is available at: http://127.0.0.1:xxxxx/
The Flutter DevTools debugger and profiler on iPhone 16 is available at: http://127.0.0.1:xxxxx/
```

---

## 🎉 Success Checklist

- [ ] Simulator iPhone 16 đã boot
- [ ] App chạy thành công
- [ ] Trang Homepage hiển thị đúng
- [ ] Button "Tell us ✨" xuất hiện
- [ ] Tap button → Dialog mở
- [ ] Submit button KHÔNG bị che
- [ ] Tap Submit → Mail app mở với template
- [ ] Email gửi tới địa chỉ trong `SUPPORT_EMAIL`

---

## 📞 Support

Nếu gặp lỗi:
1. Check `flutter doctor`
2. Clean build: `flutter clean`
3. Reinstall pods: `cd ios && pod install`
4. Xem logs: `flutter logs`
