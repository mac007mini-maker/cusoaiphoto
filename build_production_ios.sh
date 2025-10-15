#!/bin/zsh

# Production iOS IPA Build Script for Apple App Store
# This script builds a release IPA with obfuscation for App Store submission

echo "🍎 Building Production iOS IPA for Apple App Store..."

# Check if prod.json exists
if [ ! -f prod.json ]; then
    echo "❌ Error: prod.json not found!"
    echo "Please create prod.json with your production API keys"
    echo "Use .env.example as template"
    exit 1
fi

# Check Xcode version
XCODE_VERSION=$(xcodebuild -version | head -n 1 | awk '{print $2}')
XCODE_MAJOR=$(echo $XCODE_VERSION | cut -d. -f1)

if [ "$XCODE_MAJOR" -lt 16 ]; then
    echo "⚠️  Warning: Xcode version $XCODE_VERSION detected"
    echo "Apple requires Xcode 16+ for App Store submissions in 2025"
    echo "Please update Xcode from Mac App Store"
    echo ""
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Clean previous build
echo "🧹 Cleaning previous build..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Install CocoaPods
echo "📱 Installing CocoaPods dependencies..."
cd ios
pod install
cd ..

# Build production IPA
echo "🔨 Building release IPA with obfuscation..."
flutter build ipa \
  --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --dart-define-from-file=prod.json

# Check if build succeeded
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "📦 Archive location:"
    ls -d build/ios/archive/*.xcarchive
    echo ""
    echo "📤 Next steps:"
    echo "1. Open Xcode: Window → Organizer"
    echo "2. Select the latest archive (Runner)"
    echo "3. Click 'Validate App' to check for issues"
    echo "4. Click 'Distribute App' to upload to App Store Connect"
    echo "5. Monitor upload status in App Store Connect → Activities"
    echo ""
    echo "Alternative - Open archive in Xcode:"
    echo "  open build/ios/archive/Runner.xcarchive"
    echo ""
else
    echo ""
    echo "❌ Build failed! Check errors above."
    exit 1
fi
