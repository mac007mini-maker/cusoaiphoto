#!/bin/zsh

set -e  # Exit on error

echo "🚀 Running Viso AI on iOS Simulator..."
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter not found! Please install Flutter SDK."
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

# List available simulators
echo ""
echo "📱 Available iOS Simulators:"
xcrun simctl list devices | grep "iPhone" | head -10

# Auto-select simulator (prefer iPhone 16, 15, or any available)
echo ""
echo "🔍 Detecting simulator..."
SIMULATOR=""
if xcrun simctl list devices | grep -q "iPhone 16"; then
    SIMULATOR="iPhone 16"
elif xcrun simctl list devices | grep -q "iPhone 15"; then
    SIMULATOR="iPhone 15"
elif xcrun simctl list devices | grep -q "iPhone 14"; then
    SIMULATOR="iPhone 14"
else
    # Get first available iPhone simulator
    SIMULATOR=$(xcrun simctl list devices | grep "iPhone" | head -1 | sed 's/.*(\([^)]*\)).*/\1/' | xargs)
fi

if [ -z "$SIMULATOR" ]; then
    echo "❌ No iPhone simulator found! Please install Xcode simulators."
    exit 1
fi

echo "✅ Using simulator: $SIMULATOR"

# Run với hot reload enabled
echo ""
echo "🔥 Starting app with hot reload..."
flutter run \
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
  -d "$SIMULATOR" \
  || { echo "❌ Flutter run failed! Check errors above."; exit 1; }
