#!/bin/bash
set -e

echo "🚀 Building iOS for PRODUCTION..."

# Load environment variables
if [ -f secrets.env ]; then
    source secrets.env
else
    echo "⚠️  secrets.env not found. Using defaults..."
fi

export APP_ENV="${APP_ENV:-prod}"

# Validate required vars
if [ -z "$API_DOMAIN" ]; then
    echo "❌ Missing required environment variable: API_DOMAIN"
    echo "   Please set it in secrets.env or export it"
    exit 1
fi

if [ -z "$REVENUECAT_IOS_KEY" ]; then
    echo "⚠️  Warning: REVENUECAT_IOS_KEY not set. Using test key (not for production!)"
fi

echo "📋 Configuration:"
echo "   Environment: $APP_ENV"
echo "   API Domain: $API_DOMAIN"

# Clean
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

# Build iOS
echo "🔨 Building iOS release..."
flutter build ios \
  --release \
  --dart-define=APP_ENV=${APP_ENV} \
  --dart-define=API_DOMAIN=${API_DOMAIN} \
  --dart-define=SUPABASE_URL=${SUPABASE_URL} \
  --dart-define=SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY} \
  --dart-define=HUGGINGFACE_TOKEN=${HUGGINGFACE_TOKEN} \
  --dart-define=REPLICATE_API_TOKEN=${REPLICATE_API_TOKEN} \
  --dart-define=ADMOB_APP_ID_IOS=${ADMOB_APP_ID_IOS:-ca-app-pub-3940256099942544~1458002511} \
  --dart-define=ADMOB_BANNER_AD_UNIT_ID=${ADMOB_BANNER_IOS_ID:-ca-app-pub-3940256099942544/2435281174} \
  --dart-define=ADMOB_REWARDED_AD_UNIT_ID=${ADMOB_REWARDED_AD_UNIT_ID:-ca-app-pub-3940256099942544/1712485313} \
  --dart-define=ADMOB_APP_OPEN_AD_UNIT_ID=${ADMOB_APP_OPEN_IOS_ID:-ca-app-pub-3940256099942544/5575463023} \
  --dart-define=APPLOVIN_SDK_KEY=${APPLOVIN_SDK_KEY:-test_key} \
  --dart-define=REVENUECAT_IOS_KEY=${REVENUECAT_IOS_KEY} \
  --dart-define=SUPPORT_EMAIL=${SUPPORT_EMAIL:-jokerlin135@gmail.com}

echo ""
echo "✅ Production iOS built successfully!"
echo ""
echo "📤 Next steps:"
echo "1. Open Xcode: open ios/Runner.xcworkspace"
echo "2. Select 'Any iOS Device' target"
echo "3. Product → Archive"
echo "4. Window → Organizer → Distribute App"
echo ""

