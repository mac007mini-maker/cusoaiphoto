#!/bin/zsh

set -e  # Exit on error

echo "🍎 Building Viso AI for iOS Simulator (macOS M1)..."
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter not found! Please install Flutter SDK."
    exit 1
fi

# Check if pod is installed
if ! command -v pod &> /dev/null; then
    echo "❌ Error: CocoaPods not found! Please install: sudo gem install cocoapods"
    exit 1
fi

# Load secrets từ file
if [ ! -f secrets.env ]; then
    echo "❌ Error: secrets.env not found! Please create it from secrets.env.template"
    echo "💡 Tip: cp secrets.env.template secrets.env && nano secrets.env"
    exit 1
fi

echo "✅ Loading environment variables from secrets.env"
source secrets.env

# Clean previous build
echo ""
echo "🧹 Cleaning previous build..."
flutter clean || { echo "❌ Flutter clean failed"; exit 1; }
rm -rf ios/Pods ios/.symlinks ios/Podfile.lock
echo "✅ Clean complete"

# Get dependencies
echo ""
echo "📦 Getting Flutter dependencies..."
flutter pub get || { echo "❌ Flutter pub get failed"; exit 1; }
echo "✅ Dependencies downloaded"

# Install iOS pods
echo ""
echo "📱 Installing CocoaPods dependencies..."
cd ios || { echo "❌ ios/ directory not found"; exit 1; }
pod install || { echo "❌ Pod install failed. Try: pod repo update"; cd ..; exit 1; }
cd ..
echo "✅ Pods installed"

# Build for iOS Simulator with dart-define
echo ""
echo "🔨 Building for iOS Simulator..."
flutter build ios \
  --simulator \
  --dart-define=API_DOMAIN=${API_DOMAIN:-web-production-a7698.up.railway.app} \
  --dart-define=DISABLE_APPLOVIN=true \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=HUGGINGFACE_TOKEN=$HUGGINGFACE_TOKEN \
  --dart-define=REPLICATE_API_TOKEN=$REPLICATE_API_TOKEN \
  --dart-define=ADMOB_APP_ID_IOS=${ADMOB_APP_ID_IOS:-ca-app-pub-3940256099942544~1458002511} \
  --dart-define=ADMOB_REWARDED_AD_UNIT_ID=${ADMOB_REWARDED_AD_UNIT_ID:-ca-app-pub-3940256099942544/1712485313} \
  --dart-define=APPLOVIN_SDK_KEY=${APPLOVIN_SDK_KEY:-test_key} \
  --dart-define=SUPPORT_EMAIL=${SUPPORT_EMAIL:-jokerlin135@gmail.com} \
  || { echo "❌ Build failed! Check errors above."; exit 1; }

echo ""
echo "✅ Build complete!"
echo ""
echo "📱 Available simulators:"
xcrun simctl list devices | grep "iPhone" | grep "(Booted)\|(Shutdown)" || echo "   No simulators found"
echo ""
echo "🚀 To run on simulator:"
echo "   ./run_ios_simulator.sh"
echo "   OR manually: flutter run -d 'iPhone 16'"
