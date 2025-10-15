#!/bin/bash

# Build APK/AAB with all AdMob and AppLovin secrets for fallback ads
# Usage: 
#   ./build_with_all_ads.sh apk      # Build APK
#   ./build_with_all_ads.sh appbundle # Build AAB
#   ./build_with_all_ads.sh web      # Build Web

BUILD_TYPE="${1:-apk}"

flutter build $BUILD_TYPE --release \
  --dart-define=SUPPORT_EMAIL="${SUPPORT_EMAIL:-jokerlin135@gmail.com}" \
  --dart-define=ADMOB_APP_ID="$ADMOB_APP_ID" \
  --dart-define=ADMOB_BANNER_AD_UNIT_ID="$ADMOB_BANNER_AD_UNIT_ID" \
  --dart-define=ADMOB_INTERSTITIAL_AD_UNIT_ID="$ADMOB_INTERSTITIAL_AD_UNIT_ID" \
  --dart-define=ADMOB_NATIVE_AD_UNIT_ID="$ADMOB_NATIVE_AD_UNIT_ID" \
  --dart-define=ADMOB_APP_OPEN_AD_UNIT_ID="$ADMOB_APP_OPEN_AD_UNIT_ID" \
  --dart-define=ADMOB_REWARDED_AD_UNIT_ID="$ADMOB_REWARDED_AD_UNIT_ID" \
  --dart-define=APPLOVIN_SDK_KEY="$APPLOVIN_SDK_KEY" \
  --dart-define=APPLOVIN_BANNER_AD_UNIT_ID="$APPLOVIN_BANNER_AD_UNIT_ID" \
  --dart-define=APPLOVIN_INTERSTITIAL_AD_UNIT_ID="$APPLOVIN_INTERSTITIAL_AD_UNIT_ID" \
  --dart-define=APPLOVIN_APP_OPEN_AD_UNIT_ID="$APPLOVIN_APP_OPEN_AD_UNIT_ID" \
  --dart-define=APPLOVIN_REWARDED_AD_UNIT_ID="$APPLOVIN_REWARDED_AD_UNIT_ID" \
  --dart-define=APPLOVIN_NATIVE_AD_UNIT_ID="$APPLOVIN_NATIVE_AD_UNIT_ID"
