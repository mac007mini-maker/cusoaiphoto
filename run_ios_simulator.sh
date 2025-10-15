#!/bin/zsh

echo "🚀 Running Viso AI on iOS Simulator..."

# Load secrets từ file
if [ ! -f secrets.env ]; then
    echo "❌ Error: secrets.env not found! Please create it from secrets.env.template"
    exit 1
fi

source secrets.env

# List available simulators
echo "📱 Available simulators:"
xcrun simctl list devices | grep "iPhone"

# Run với hot reload enabled
echo ""
echo "🔥 Starting app with hot reload..."
flutter run \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=HUGGINGFACE_TOKEN=$HUGGINGFACE_TOKEN \
  --dart-define=REPLICATE_API_TOKEN=$REPLICATE_API_TOKEN \
  --dart-define=ADMOB_APP_ID_IOS=${ADMOB_APP_ID_IOS:-ca-app-pub-3940256099942544~1458002511} \
  --dart-define=ADMOB_REWARDED_AD_UNIT_ID=${ADMOB_REWARDED_AD_UNIT_ID:-ca-app-pub-3940256099942544/1712485313} \
  --dart-define=APPLOVIN_SDK_KEY=${APPLOVIN_SDK_KEY:-test_key} \
  --dart-define=SUPPORT_EMAIL=${SUPPORT_EMAIL:-jokerlin135@gmail.com} \
  -d 'iPhone 16'
