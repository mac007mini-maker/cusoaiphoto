# ⚡ Quick Production Build Commands

## 📋 Prerequisites

1. **Create prod.json** (REAL API keys):
   ```bash
   cp prod.json.example prod.json
   # Edit prod.json with your production keys
   ```

2. **Android**: Create upload keystore (first time only):
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias upload
   
   # Create android/key.properties with keystore info
   ```

3. **iOS**: Enroll in Apple Developer Program ($99/year)

---

## 🤖 Android Production (Google Play Store)

### Build AAB:
```bash
chmod +x build_production_android.sh
./build_production_android.sh
```

### Manual build:
```bash
flutter build appbundle \
  --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --dart-define-from-file=prod.json
```

**Output:** `build/app/outputs/bundle/release/app-release.aab`

**Upload to:** https://play.google.com/console

---

## 🍎 iOS Production (Apple App Store)

### Build IPA:
```bash
chmod +x build_production_ios.sh
./build_production_ios.sh
```

### Manual build:
```bash
flutter build ipa \
  --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --dart-define-from-file=prod.json
```

**Output:** `build/ios/archive/Runner.xcarchive`

**Upload via Xcode:**
1. Window → Organizer
2. Validate App
3. Distribute App

**Upload to:** https://appstoreconnect.apple.com

---

## 📝 Required Files

### Android:
- ✅ `prod.json` - Production API keys
- ✅ `upload-keystore.jks` - App signing key
- ✅ `android/key.properties` - Keystore config
- ✅ Privacy policy URL (hosted on HTTPS)
- ✅ Data Safety Form (in Play Console)

### iOS:
- ✅ `prod.json` - Production API keys
- ✅ `ios/Runner/PrivacyInfo.xcprivacy` - Privacy manifest
- ✅ Privacy policy URL (hosted on HTTPS)
- ✅ App Store Connect info complete

---

## 🔐 Security Checklist

- [ ] NEVER commit `prod.json` to Git
- [ ] NEVER commit `upload-keystore.jks` to Git
- [ ] NEVER commit `android/key.properties` to Git
- [ ] Always use `--obfuscate` for production
- [ ] Store keystore backup safely (1Password, etc.)
- [ ] Use REAL API keys (not test keys)

---

## 📊 Version Management

Update version before each release:

**Edit `pubspec.yaml`:**
```yaml
version: 1.2.3+4
#       ^^^ Version name (users see)
#           ^ Build number (must increment)
```

---

## 🐛 Common Issues

### Android: "Target SDK version too low"
**Fix:** Set `targetSdkVersion 35` in `android/app/build.gradle`

### iOS: "Missing API declaration"
**Fix:** Add Required Reason APIs to `PrivacyInfo.xcprivacy`

### Both: "Secrets not found"
**Fix:** Ensure `prod.json` exists with all required keys

---

## 📚 Full Documentation

For detailed instructions, see:
- **PRODUCTION_BUILD_GUIDE.md** - Complete build & publish guide
- **PRIVACY_POLICY_TEMPLATE.md** - Privacy policy template
