#!/bin/zsh

echo "🍎 Building Viso AI for iOS Simulator (macOS M1)..."

# Load secrets từ file
if [ ! -f secrets.env ]; then
    echo "❌ Error: secrets.env not found! Please create it from secrets.env.template"
    exit 1
fi

source secrets.env

# Clean previous build
echo "🧹 Cleaning previous build..."
flutter clean
rm -rf ios/Pods ios/.symlinks ios/Podfile.lock

# Get dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Install iOS pods
echo "📱 Installing CocoaPods dependencies..."
cd ios && pod install && cd ..

# Build for iOS Simulator with dart-define
echo "🔨 Building for iOS Simulator..."
flutter build ios \
  --simulator \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=HUGGINGFACE_TOKEN=$HUGGINGFACE_TOKEN \
  --dart-define=REPLICATE_API_TOKEN=$REPLICATE_API_TOKEN \
  --dart-define=ADMOB_APP_ID_IOS=${ADMOB_APP_ID_IOS:-ca-app-pub-3940256099942544~1458002511} \
  --dart-define=ADMOB_REWARDED_AD_UNIT_ID=${ADMOB_REWARDED_AD_UNIT_ID:-ca-app-pub-3940256099942544/1712485313} \
  --dart-define=APPLOVIN_SDK_KEY=${APPLOVIN_SDK_KEY:-test_key} \
  --dart-define=SUPPORT_EMAIL=${SUPPORT_EMAIL:-jokerlin135@gmail.com}

echo ""
echo "✅ Build complete!"
echo "📱 To run on simulator:"
echo "   flutter run -d 'iPhone 16'"
