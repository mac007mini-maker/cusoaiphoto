# iOS Simulator Build Guide - Viso AI

Complete guide for building and running Viso AI on iOS Simulator (macOS).

## Table of Contents
- [Prerequisites](#prerequisites)
- [Environment Setup](#environment-setup)
- [Build Instructions](#build-instructions)
- [Running the App](#running-the-app)
- [Troubleshooting](#troubleshooting)
- [Quick Commands Reference](#quick-commands-reference)

---

## Prerequisites

### Required Software

1. **macOS** (Big Sur 11.0 or later)
   - Apple Silicon (M1/M2/M3) or Intel Mac

2. **Xcode** (14.0 or later)
   ```bash
   # Check Xcode version
   xcodebuild -version
   
   # If not installed, download from App Store or:
   # https://developer.apple.com/xcode/
   ```

3. **Xcode Command Line Tools**
   ```bash
   xcode-select --install
   ```

4. **Flutter SDK** (3.35.6 or later)
   ```bash
   # Check Flutter version
   flutter --version
   
   # If not installed, follow:
   # https://docs.flutter.dev/get-started/install/macos
   ```

5. **CocoaPods** (1.11.0 or later)
   ```bash
   # Check CocoaPods version
   pod --version
   
   # Install if needed
   sudo gem install cocoapods
   
   # Update if needed
   sudo gem update cocoapods
   ```

### Verify Installation

Run Flutter doctor to check your setup:

```bash
flutter doctor -v
```

Expected output should show:
- ✅ Flutter (Channel stable)
- ✅ Xcode - develop for iOS and macOS
- ✅ Chrome - develop for the web
- ✅ VS Code or Android Studio (optional)

---

## Environment Setup

### 1. Create Environment Configuration

Copy the template file:

```bash
cp secrets.env.template secrets.env
```

### 2. Configure API Keys

Edit `secrets.env` and add your API keys:

```bash
# Required - Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key

# Required - AI Services
REPLICATE_API_TOKEN=your-replicate-token
HUGGINGFACE_TOKEN=your-huggingface-token

# Optional - Ads (test keys provided)
ADMOB_APP_ID_IOS=ca-app-pub-3940256099942544~1458002511
ADMOB_REWARDED_AD_UNIT_ID=ca-app-pub-3940256099942544/1712485313
APPLOVIN_SDK_KEY=test_key

# Optional - Support
SUPPORT_EMAIL=your-email@example.com
```

**Important:** Never commit `secrets.env` to version control!

### 3. Configure iOS Simulators

List available simulators:

```bash
xcrun simctl list devices
```

Create new simulator if needed:

```bash
# Create iPhone 16 simulator (recommended)
xcrun simctl create "iPhone 16" "iPhone 16"

# Or create iPhone 15
xcrun simctl create "iPhone 15" "iPhone 15"
```

Boot simulator:

```bash
# Open Simulator app
open -a Simulator

# Or boot specific device
xcrun simctl boot "iPhone 16"
```

---

## Build Instructions

### Method 1: Using Build Script (Recommended)

The automated script handles everything:

```bash
chmod +x build_ios_simulator.sh
./build_ios_simulator.sh
```

The script will:
1. ✅ Validate prerequisites (Flutter, CocoaPods)
2. ✅ Load environment variables
3. ✅ Clean previous builds
4. ✅ Download Flutter dependencies
5. ✅ Install CocoaPods dependencies
6. ✅ Build iOS simulator binary

**Build time:** ~3-5 minutes (first build), ~1-2 minutes (subsequent builds)

### Method 2: Manual Build

If you prefer manual control:

```bash
# 1. Load environment variables
source secrets.env

# 2. Clean previous build
flutter clean
rm -rf ios/Pods ios/.symlinks ios/Podfile.lock

# 3. Get dependencies
flutter pub get

# 4. Install pods
cd ios && pod install && cd ..

# 5. Build for simulator
flutter build ios \
  --simulator \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=REPLICATE_API_TOKEN=$REPLICATE_API_TOKEN \
  --dart-define=HUGGINGFACE_TOKEN=$HUGGINGFACE_TOKEN
```

---

## Running the App

### Method 1: Using Run Script (Recommended)

The automated script handles simulator selection:

```bash
chmod +x run_ios_simulator.sh
./run_ios_simulator.sh
```

The script will:
1. ✅ Detect available simulators
2. ✅ Auto-select best simulator (iPhone 16 → 15 → 14 → first available)
3. ✅ Start app with hot reload enabled

### Method 2: Manual Run

```bash
# List available devices
flutter devices

# Run on specific simulator
flutter run -d "iPhone 16"

# Or let Flutter choose
flutter run
```

### Hot Reload Tips

When the app is running:
- Press `r` - Hot reload (fast, preserves state)
- Press `R` - Hot restart (slower, resets state)
- Press `p` - Toggle performance overlay
- Press `q` - Quit

---

## Troubleshooting

### Problem 1: Pod Install Fails

**Error:**
```
[!] Unable to find a specification for...
```

**Solutions:**

```bash
# Update CocoaPods repo
pod repo update

# Clean and reinstall
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
```

### Problem 2: Code Signing Errors

**Error:**
```
Code signing is required for product type 'Application'
```

**Solution:**

For iOS Simulator, code signing is not required. Make sure you're building with `--simulator` flag:

```bash
flutter build ios --simulator
```

If still failing, check Xcode settings:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner project → Signing & Capabilities
3. Uncheck "Automatically manage signing" for Debug configuration
4. Clean build: Product → Clean Build Folder

### Problem 3: Missing Permissions

**Error:**
```
This app has crashed because it attempted to access privacy-sensitive data...
```

**Solution:**

Permissions are already configured in `ios/Runner/Info.plist`:
- ✅ Camera: `NSCameraUsageDescription`
- ✅ Photo Library: `NSPhotoLibraryUsageDescription`
- ✅ Photo Library Add: `NSPhotoLibraryAddUsageDescription`

If issues persist, check Info.plist has these entries.

### Problem 4: Simulator Not Found

**Error:**
```
No devices found
```

**Solution:**

```bash
# List all simulators
xcrun simctl list devices

# Boot a simulator
open -a Simulator

# Or boot specific device
xcrun simctl boot "iPhone 16"

# Then run app
flutter run
```

### Problem 5: Build Errors After Git Pull

**Solution:**

Clean everything and rebuild:

```bash
# Full clean
flutter clean
rm -rf ios/Pods ios/.symlinks ios/Podfile.lock
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Rebuild
./build_ios_simulator.sh
```

### Problem 6: Flutter Not Found

**Error:**
```
flutter: command not found
```

**Solution:**

Add Flutter to PATH in `~/.zshrc`:

```bash
# Edit ~/.zshrc
export PATH="$PATH:/path/to/flutter/bin"

# Reload
source ~/.zshrc

# Verify
flutter --version
```

### Problem 7: Ads Not Showing (Development)

**Explanation:**

During development, test ad IDs are used. Real ads won't show until:
1. App is released to App Store
2. AdMob account is fully approved
3. Production ad unit IDs are configured

**For Testing:**

Test ads should appear with current configuration. If not:
1. Check AdMob test IDs in `secrets.env`
2. Verify Info.plist has `GADApplicationIdentifier`
3. Check console for ad load errors

### Problem 8: Firebase/RevenueCat Issues

**Symptom:**
```
No active offerings found
```

**Solution for iOS Simulator:**

1. Open Xcode → `ios/Runner.xcworkspace`
2. Product → Scheme → Edit Scheme
3. Run → Options → StoreKit Configuration
4. Select `Configuration.storekit`
5. Clean and rebuild

### Problem 9: Slow Build Times

**Optimization tips:**

```bash
# Use build cache
flutter build ios --simulator --build-number=1

# Skip unnecessary checks
flutter build ios --simulator --no-pub

# Parallel compilation (add to ~/.zshrc)
export FLUTTER_BUILD_CONCURRENCY=8
```

### Problem 10: Memory Issues on Simulator

**Solution:**

1. Quit other apps to free RAM
2. Restart simulator: `killall Simulator`
3. Increase simulator RAM in Xcode settings
4. Use newer simulator (iPhone 16 vs older models)

---

## Quick Commands Reference

### Build Commands

```bash
# Full clean build
./build_ios_simulator.sh

# Quick rebuild (no clean)
flutter build ios --simulator

# Verbose build (for debugging)
flutter build ios --simulator --verbose
```

### Run Commands

```bash
# Auto-select simulator and run
./run_ios_simulator.sh

# Run on specific device
flutter run -d "iPhone 16"

# Run in release mode (faster, no hot reload)
flutter run --release -d "iPhone 16"

# Run with verbose logging
flutter run -v -d "iPhone 16"
```

### Debugging Commands

```bash
# View Flutter logs
flutter logs

# View app logs in real-time
flutter logs --clear

# Check device connectivity
flutter devices

# Analyze app size
flutter build ios --analyze-size
```

### Simulator Commands

```bash
# List all simulators
xcrun simctl list devices

# Boot simulator
xcrun simctl boot "iPhone 16"

# Shutdown simulator
xcrun simctl shutdown "iPhone 16"

# Erase simulator data
xcrun simctl erase "iPhone 16"

# Take screenshot
xcrun simctl io booted screenshot screenshot.png
```

### Maintenance Commands

```bash
# Update Flutter
flutter upgrade

# Update dependencies
flutter pub upgrade

# Update CocoaPods
pod repo update
cd ios && pod update && cd ..

# Clean all caches
flutter clean
pod cache clean --all
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

---

## Build Time Expectations

### First Build
- Clean + Dependencies: ~2-3 minutes
- Pod Install: ~1-2 minutes  
- Flutter Build: ~3-5 minutes
- **Total: ~6-10 minutes**

### Subsequent Builds
- Incremental Build: ~30-60 seconds
- With Clean: ~2-3 minutes

### Hot Reload
- Code changes: ~1-3 seconds ⚡️

---

## Performance Tips

1. **Use Release Mode for Performance Testing**
   ```bash
   flutter run --release -d "iPhone 16"
   ```

2. **Enable Performance Overlay**
   - Press `p` while app is running
   - Or add to code: `showPerformanceOverlay: true`

3. **Profile Build**
   ```bash
   flutter run --profile -d "iPhone 16"
   ```

4. **Check App Size**
   ```bash
   flutter build ios --analyze-size --simulator
   ```

---

## Additional Resources

- [Flutter iOS Documentation](https://docs.flutter.dev/deployment/ios)
- [Xcode Simulator Guide](https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device)
- [CocoaPods Documentation](https://guides.cocoapods.org/)
- [Firebase iOS Setup](https://firebase.google.com/docs/ios/setup)
- [RevenueCat iOS Guide](https://www.revenuecat.com/docs/ios)

---

## Support

If you encounter issues not covered in this guide:

1. Check Flutter doctor: `flutter doctor -v`
2. View build logs: `flutter build ios --verbose`
3. Check GitHub Issues
4. Contact: ${SUPPORT_EMAIL:-support@visoai.com}

---

**Last Updated:** October 2025  
**Flutter Version:** 3.35.6  
**Minimum iOS:** 14.0  
**Recommended Xcode:** 16.0+




