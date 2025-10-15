#!/bin/bash

# Production Android AAB Build Script for Google Play Store
# This script builds a release AAB with obfuscation and proper signing

echo "🤖 Building Production Android AAB for Google Play Store..."

# Check if prod.json exists
if [ ! -f prod.json ]; then
    echo "❌ Error: prod.json not found!"
    echo "Please create prod.json with your production API keys"
    echo "Use .env.example as template"
    exit 1
fi

# Check if keystore exists
if [ ! -f android/key.properties ]; then
    echo "❌ Error: android/key.properties not found!"
    echo ""
    echo "Please create upload keystore first:"
    echo "  keytool -genkey -v -keystore upload-keystore.jks \\"
    echo "    -keyalg RSA -keysize 2048 -validity 10000 \\"
    echo "    -alias upload"
    echo ""
    echo "Then create android/key.properties with:"
    echo "  storePassword=YOUR_PASSWORD"
    echo "  keyPassword=YOUR_PASSWORD"
    echo "  keyAlias=upload"
    echo "  storeFile=../upload-keystore.jks"
    exit 1
fi

# Clean previous build
echo "🧹 Cleaning previous build..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build production AAB
echo "🔨 Building release AAB with obfuscation..."
flutter build appbundle \
  --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --dart-define-from-file=prod.json

# Check if build succeeded
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "📦 AAB file location:"
    ls -lh build/app/outputs/bundle/release/app-release.aab
    echo ""
    echo "📤 Next steps:"
    echo "1. Go to Google Play Console: https://play.google.com/console"
    echo "2. Select your app"
    echo "3. Go to Release → Testing → Internal testing (or Production)"
    echo "4. Upload: build/app/outputs/bundle/release/app-release.aab"
    echo ""
else
    echo ""
    echo "❌ Build failed! Check errors above."
    exit 1
fi
