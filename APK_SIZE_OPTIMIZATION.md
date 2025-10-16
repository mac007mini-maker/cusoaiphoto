# 📦 Hướng Dẫn Giảm Kích Thước APK Flutter

## ⚠️ Vấn Đề Hiện Tại

APK của bạn nặng hơn 200MB vì:
1. **Flutter engine binaries** (~40-60MB)
2. **Assets/images lớn** (108 images, một số file 1.5MB)
3. **Multiple ABIs** (ARM, ARM64, x86 trong 1 APK)
4. **Dependencies** (AdMob, AppLovin, RevenueCat, Supabase)

## 🎯 Mục Tiêu

Giảm từ **200MB → 40-60MB** cho mỗi APK

---

## 🚀 Giải Pháp Ngay Lập Tức

### 1. Build APK theo từng ABI (Quan trọng nhất!)

Thay vì 1 APK chứa tất cả (200MB), tạo 3 APK riêng:

```bash
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/debug-info --tree-shake-icons
```

**Kết quả:**
- `app-armeabi-v7a-release.apk` (~40-50MB) - Máy Android cũ
- `app-arm64-v8a-release.apk` (~50-60MB) - Máy Android mới  
- `app-x86_64-release.apk` (~5-10MB) - Emulator

**Giảm ngay 60-70% so với fat APK!**

### 2. Dùng App Bundle thay vì APK

Google Play tự động chọn APK phù hợp cho từng máy:

```bash
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info --tree-shake-icons
```

Upload file `.aab` lên Google Play → User download chỉ 40-60MB!

---

## 🖼️ Tối Ưu Assets (Giảm thêm 10-20MB)

### Bước 1: Nén lại images

```bash
# Cài công cụ nén ảnh
npm install -g @squoosh/cli

# Nén tất cả PNG/JPG
squoosh-cli --webp auto assets/images/*.{png,jpg,jpeg}
```

### Bước 2: Xóa ảnh không dùng

Kiểm tra `pubspec.yaml` và xóa assets không cần thiết:

```yaml
flutter:
  assets:
    - assets/images/  # ← Chỉ giữ thư mục đang dùng
```

### Bước 3: Resize icons quá lớn

Icons hiện tại: **1.5MB** (quá lớn!)
```bash
# Giảm kích thước icons
convert assets/images/viso-ai.png -resize 512x512 -quality 85 assets/images/viso-ai-optimized.png
```

**Mục tiêu:** Icons nên < 200KB

---

## ⚙️ Cấu Hình Build.gradle (Đã enable)

File `android/app/build.gradle` đã được cập nhật:

```gradle
buildTypes {
    release {
        minifyEnabled true          // Xóa code Java/Kotlin không dùng
        shrinkResources true        // Xóa resources không dùng
        proguardFiles ...          // Optimization
    }
}
```

**Lưu ý:** Cái này chỉ giảm vài MB cho Java/Kotlin, không ảnh hưởng nhiều đến Flutter.

---

## 📊 Phân Tích Chi Tiết APK Size

### Kiểm tra APK hiện tại

```bash
flutter build apk --analyze-size
```

Hoặc dùng Android Studio:
1. Build → Analyze APK
2. Xem breakdown theo thành phần

### Typical breakdown cho Flutter app:

| Component | Size | Giải pháp |
|-----------|------|-----------|
| Flutter engine | 40-60MB | Split ABI |
| Assets/Images | 10-30MB | Nén/WebP |
| Native libs | 5-15MB | Split ABI |
| Code (Dart) | 5-10MB | Obfuscate |

---

## 🔥 Build Script Tối Ưu

Tạo file `build_optimized.sh`:

```bash
#!/bin/bash

echo "🚀 Building optimized APKs..."

# Clean old builds
flutter clean
flutter pub get

# Build with all optimizations
flutter build apk \
  --release \
  --split-per-abi \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --tree-shake-icons

echo "✅ Done! Check build/app/outputs/flutter-apk/"
echo ""
echo "📦 APK files:"
ls -lh build/app/outputs/flutter-apk/*.apk
```

Chạy:
```bash
chmod +x build_optimized.sh
./build_optimized.sh
```

---

## 📱 Upload Lên Google Play

### Option 1: Upload APKs riêng lẻ

1. Vào Google Play Console
2. Release → Production → Create Release
3. Upload cả 3 APKs:
   - `app-armeabi-v7a-release.apk`
   - `app-arm64-v8a-release.apk`
   - `app-x86_64-release.apk`

Google Play tự chọn APK đúng cho từng máy.

### Option 2: Upload App Bundle (Khuyến nghị)

```bash
flutter build appbundle --release
```

Upload file `.aab` → Google tự động optimize!

---

## 🎯 Checklist Tối Ưu

- [x] Enable ProGuard + shrinkResources
- [ ] Build với `--split-per-abi`
- [ ] Nén lại tất cả images (WebP/optimized PNG)
- [ ] Resize icons > 500KB xuống < 200KB
- [ ] Xóa assets không dùng trong `pubspec.yaml`
- [ ] Build với `--obfuscate --split-debug-info`
- [ ] Tree-shake icons với `--tree-shake-icons`
- [ ] Dùng App Bundle thay vì APK

---

## 📈 Kết Quả Kỳ Vọng

| Trước | Sau |
|-------|-----|
| 1 APK × 200MB | 3 APKs × 40-60MB mỗi cái |
| Assets: 22MB | Assets: 5-10MB (sau nén) |
| **Total: 200MB** | **Download: 40-60MB** |

**Giảm 60-70% kích thước!** 🎉

---

## 🆘 Troubleshooting

### APK vẫn lớn sau khi split ABI?

1. Kiểm tra assets folder:
   ```bash
   du -sh assets/
   ```

2. Tìm files lớn nhất:
   ```bash
   find assets -type f -exec du -h {} \; | sort -rh | head -20
   ```

3. Nén hoặc xóa files không cần

### Build bị lỗi với ProGuard?

Thêm vào `android/app/proguard-rules.pro`:
```
-keep class io.flutter.** { *; }
-keep class com.google.firebase.** { *; }
```

---

## 💡 Tips Thêm

1. **Lazy load images** - Download images khi cần thay vì bundle
2. **CDN for templates** - Lưu face swap templates trên Supabase Storage
3. **Dynamic Feature Modules** - Tách features thành modules riêng
4. **Remove unused fonts** - Chỉ include font weights đang dùng

---

**Tóm lại:** Split ABI là cách nhanh nhất giảm size. Kết hợp với nén assets có thể đạt 40-60MB/APK! 🚀
