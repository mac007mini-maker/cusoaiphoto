# 🚨 QUICK FIX: Indentation Error

## Vấn đề:
File `homepage_widget.dart` có **lỗi indentation structural** từ FlutterFlow generation. LSP không phát hiện vì chỉ check syntax, không check formatting.

## ✅ GIẢI PHÁP NHANH NHẤT (2 phút):

### **Android Studio / IntelliJ IDEA** ⭐
1. Mở project trong Android Studio/IntelliJ
2. Mở file `lib/pages/homepage/homepage_widget.dart`
3. **Right-click** trong editor → **Reformat Code with dartfmt**
4. Hoặc phím tắt: **Ctrl+Alt+L** (Windows) / **Cmd+Option+L** (Mac)
5. Save file → Build lại

```bash
flutter build apk --debug
```

### **VS Code + Dart Extension**
1. Install Dart extension (nếu chưa có)
2. Mở file `lib/pages/homepage/homepage_widget.dart`
3. **Right-click** → **Format Document**
4. Hoặc phím tắt: **Shift+Alt+F**
5. Save file → Build lại

### **Command Line (Flutter SDK)**
```bash
cd C:\7code\aihubtech12tp\aihubtech

# Format single file
flutter format lib/pages/homepage/homepage_widget.dart

# Or format entire project
flutter format .

# Then rebuild
flutter build apk --debug
```

---

## 📋 Nếu vẫn lỗi:

### Manual Fix Line Endings:
1. VS Code → Open file
2. Góc dưới phải: click **CRLF**
3. Chọn **LF**
4. Save → Rebuild

### Nuclear Option - Clone Fresh:
```bash
cd C:\7code
git clone <REPLIT_GIT_URL> aihubtech_fixed
cd aihubtech_fixed
flutter format .
flutter build apk --debug
```

---

## ⚠️ Root Cause:
FlutterFlow generated code với inconsistent indentation. Dart compiler OK với điều này, nhưng khi copy file giữa systems, indentation mismatch gây lỗi parse.

**Solution: Always auto-format before build!** 🚀
