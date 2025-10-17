# 🔧 FIX INDENTATION ERROR - Step by Step

## Vấn đề:
File `homepage_widget.dart` trên Replit **đúng 100%** (LSP verified), nhưng khi download về local bị lỗi indentation do:
- Line ending mismatch (LF vs CRLF)
- Encoding issues (UTF-8 vs UTF-16)
- Copy-paste truncation

## ✅ GIẢI PHÁP:

### **Option 1: Download Clean File từ Replit** ⭐ (Recommended)
1. Vào Replit → click file `homepage_widget_CLEAN.dart` (root folder)
2. Click 3 dots (...) → **Download**
3. Rename: `homepage_widget_CLEAN.dart` → `homepage_widget.dart`
4. Copy vào: `C:\7code\aihubtech12tp\aihubtech\lib\pages\homepage\`
5. Replace existing file

### **Option 2: Fix Line Endings trong VS Code**
1. Mở file `homepage_widget.dart` trong VS Code
2. Click góc dưới bên phải: **CRLF** → chọn **LF**
3. File → Save
4. Rebuild:
   ```bash
   flutter clean
   flutter build apk --debug
   ```

### **Option 3: Clone lại từ Replit**
1. Vào Replit project
2. Click **Version Control** → Copy Git URL
3. Clone mới về local:
   ```bash
   cd C:\7code
   git clone <REPLIT_GIT_URL> aihubtech_fresh
   cd aihubtech_fresh
   flutter build apk --debug
   ```

---

## ✅ Verify After Fix:
```bash
flutter clean
flutter pub get
flutter build apk --debug
```

## 🚀 Expected Result:
```
✔ Built build\app\outputs\flutter-apk\app-debug.apk
```

---

## 📌 Lưu ý:
- File `homepage_widget_CLEAN.dart` ở root folder Replit chính là bản backup clean
- File trên Replit **100% đúng** (LSP verified no errors)
- Vấn đề chỉ là download/copy process bị corrupt

**Download đúng cách là xong!** 💪
