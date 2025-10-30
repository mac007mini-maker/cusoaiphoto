# Multi-Config Build Guide - One Codebase, Multiple Environments
**Strategy:** One codebase → Multiple configurations (dev/staging/prod, iOS/Android)

---

## Table of Contents
1. [Configuration Hierarchy](#configuration-hierarchy)
2. [Environment Variables Management](#environment-variables-management)
3. [Platform-Specific Configs (iOS vs Android)](#platform-specific-configs)
4. [Build Scripts for Each Environment](#build-scripts-for-each-environment)
5. [Remote Config Strategy](#remote-config-strategy)
6. [Testing Configurations](#testing-configurations)

---

## Configuration Hierarchy

**Priority (Highest to Lowest):**
```
1. dart-define (compile-time) - Can't be changed after build
2. Remote Config (runtime) - Can be updated without rebuild
3. Hardcoded Defaults (fallback) - Last resort only
```

### When to Use Each Method

| Config Type | Use dart-define | Use Remote Config | Use Hardcoded |
|------------|----------------|-------------------|---------------|
| API Domain | ✅ Primary | ✅ Emergency fallback | ✅ Local dev default |
| API Keys (RevenueCat, Replicate) | ✅ Yes | ❌ No (security) | ❌ Never in prod |
| Ad IDs | ✅ Fallback | ✅ Primary | ⚠️ Test IDs only |
| Feature Flags | ❌ No | ✅ Yes | ✅ Safe defaults |
| App Environment | ✅ Yes (dev/staging/prod) | ❌ No | ❌ No |

---

## Environment Variables Management

### Step 1: Update `secrets.env` Template

Create `secrets.env` from template (already exists):
```bash
cp secrets.env.template secrets.env
```

**Edit `secrets.env` with your values:**
```bash
# ============================================
# ENVIRONMENT SELECTION
# ============================================
export APP_ENV="dev"  # dev | staging | prod

# ============================================
# BACKEND API
# ============================================
export API_DOMAIN="web-production-a7698.up.railway.app"
export API_KEY="your-secure-api-key-here"  # Generate: openssl rand -hex 32

# ============================================
# FIREBASE
# ============================================
# (Firebase configs already in firebase_options.dart)

# ============================================
# SUPABASE
# ============================================
export SUPABASE_URL="https://your-project.supabase.co"
export SUPABASE_ANON_KEY="your-anon-key"

# ============================================
# AI SERVICES
# ============================================
export HUGGINGFACE_TOKEN="hf_xxxxxxxxxxxx"
export REPLICATE_API_TOKEN="r8_xxxxxxxxxxxx"
export KIE_API_KEY="kie_xxxxxxxxxxxx"  # ← NEW: Nano Banana diffusion model

# ============================================
# ADS - ADMOB (Platform-specific)
# ============================================
export ADMOB_APP_ID_ANDROID="ca-app-pub-xxxxx~xxxxx"
export ADMOB_APP_ID_IOS="ca-app-pub-xxxxx~xxxxx"
export ADMOB_BANNER_ANDROID_ID="ca-app-pub-xxxxx/xxxxx"
export ADMOB_BANNER_IOS_ID="ca-app-pub-xxxxx/xxxxx"
export ADMOB_REWARDED_AD_UNIT_ID="ca-app-pub-xxxxx/xxxxx"
export ADMOB_APP_OPEN_ANDROID_ID="ca-app-pub-xxxxx/xxxxx"
export ADMOB_APP_OPEN_IOS_ID="ca-app-pub-xxxxx/xxxxx"

# ============================================
# ADS - APPLOVIN
# ============================================
export APPLOVIN_SDK_KEY="your-sdk-key"

# ============================================
# IN-APP PURCHASES - REVENUECAT
# ============================================
export REVENUECAT_ANDROID_KEY="proj_xxxxxxxx"
export REVENUECAT_IOS_KEY="appl_xxxxxxxx"

# ============================================
# SUPPORT
# ============================================
export SUPPORT_EMAIL="your-email@example.com"

# ============================================
# OPTIONAL: Kill-switches for debugging
# ============================================
export DISABLE_APPLOVIN="false"  # Set to "true" for iOS simulator
```

### Step 2: Load Environment Variables

**Before any build command:**
```bash
source secrets.env
```

Or integrate into build scripts (see below).

---

## Platform-Specific Configs

### iOS vs Android Differences

**Must be different:**
- AdMob App IDs (Android uses `~`, iOS uses different ID)
- AdMob Ad Unit IDs (Banner, Rewarded, App Open, Interstitial)
- AppLovin Ad Unit IDs
- RevenueCat API Keys (one for Android, one for iOS)
- Bundle ID / Package Name

**Can be same:**
- API Domain
- Supabase URL/Key
- Huggingface/Replicate Tokens
- KIE Nano Banana API Key (new Nano Banana prompt studio)
- Support Email

### How to Pass Platform-Specific Configs

**In Build Scripts:**
```bash
# iOS Build
flutter build ios \
  --dart-define=APP_ENV=${APP_ENV:-prod} \
  --dart-define=API_DOMAIN=${API_DOMAIN} \
  --dart-define=ADMOB_APP_ID_IOS=${ADMOB_APP_ID_IOS} \
  --dart-define=ADMOB_BANNER_AD_UNIT_ID=${ADMOB_BANNER_IOS_ID} \
  --dart-define=REVENUECAT_IOS_KEY=${REVENUECAT_IOS_KEY} \
  ...

# Android Build
flutter build apk \
  --dart-define=APP_ENV=${APP_ENV:-prod} \
  --dart-define=API_DOMAIN=${API_DOMAIN} \
  --dart-define=ADMOB_APP_ID_ANDROID=${ADMOB_APP_ID_ANDROID} \
  --dart-define=ADMOB_BANNER_AD_UNIT_ID=${ADMOB_BANNER_ANDROID_ID} \
  --dart-define=REVENUECAT_ANDROID_KEY=${REVENUECAT_ANDROID_KEY} \
  ...
```

**In Code (lib/services/xxx_service.dart):**
```dart
import 'dart:io';

class AdConfig {
  static String get appId {
    if (Platform.isIOS) {
      return const String.fromEnvironment(
        'ADMOB_APP_ID_IOS',
        defaultValue: 'ca-app-pub-3940256099942544~1458002511', // Test ID
      );
    } else if (Platform.isAndroid) {
      return const String.fromEnvironment(
        'ADMOB_APP_ID_ANDROID',
        defaultValue: 'ca-app-pub-3940256099942544~3347511713', // Test ID
      );
    }
    return '';
  }
}
```

---

## Build Scripts for Each Environment

### Environment-Specific Build Scripts

Create these scripts in project root:

#### `build_dev_android.sh`
```bash
#!/bin/bash
set -e

echo "🔧 Building Android APK for DEVELOPMENT..."

source secrets.env
export APP_ENV="dev"

flutter clean
flutter pub get

flutter build apk \
  --dart-define=APP_ENV=dev \
  --dart-define=API_DOMAIN=${API_DOMAIN_DEV:-localhost:5000} \
  --dart-define=SUPABASE_URL=${SUPABASE_URL} \
  --dart-define=SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY} \
  --dart-define=HUGGINGFACE_TOKEN=${HUGGINGFACE_TOKEN} \
  --dart-define=REPLICATE_API_TOKEN=${REPLICATE_API_TOKEN} \
  --dart-define=ADMOB_APP_ID_ANDROID=${ADMOB_APP_ID_ANDROID:-ca-app-pub-3940256099942544~3347511713} \
  --dart-define=ADMOB_BANNER_AD_UNIT_ID=${ADMOB_BANNER_ANDROID_ID:-ca-app-pub-3940256099942544/6300978111} \
  --dart-define=ADMOB_REWARDED_AD_UNIT_ID=${ADMOB_REWARDED_AD_UNIT_ID:-ca-app-pub-3940256099942544/5224354917} \
  --dart-define=APPLOVIN_SDK_KEY=${APPLOVIN_SDK_KEY:-test_key} \
  --dart-define=REVENUECAT_ANDROID_KEY=${REVENUECAT_ANDROID_KEY} \
  --dart-define=SUPPORT_EMAIL=${SUPPORT_EMAIL} \
  --debug

echo "✅ Dev APK built: build/app/outputs/flutter-apk/app-debug.apk"
```

#### `build_prod_android.sh`
```bash
#!/bin/bash
set -e

echo "🚀 Building Android APK for PRODUCTION..."

source secrets.env
export APP_ENV="prod"

# Validate required vars
if [ -z "$API_DOMAIN" ] || [ -z "$REVENUECAT_ANDROID_KEY" ]; then
  echo "❌ Missing required environment variables!"
  exit 1
fi

flutter clean
flutter pub get

flutter build apk \
  --release \
  --dart-define=APP_ENV=prod \
  --dart-define=API_DOMAIN=${API_DOMAIN} \
  --dart-define=SUPABASE_URL=${SUPABASE_URL} \
  --dart-define=SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY} \
  --dart-define=HUGGINGFACE_TOKEN=${HUGGINGFACE_TOKEN} \
  --dart-define=REPLICATE_API_TOKEN=${REPLICATE_API_TOKEN} \
  --dart-define=ADMOB_APP_ID_ANDROID=${ADMOB_APP_ID_ANDROID} \
  --dart-define=ADMOB_BANNER_AD_UNIT_ID=${ADMOB_BANNER_ANDROID_ID} \
  --dart-define=ADMOB_REWARDED_AD_UNIT_ID=${ADMOB_REWARDED_AD_UNIT_ID} \
  --dart-define=ADMOB_APP_OPEN_AD_UNIT_ID=${ADMOB_APP_OPEN_ANDROID_ID} \
  --dart-define=APPLOVIN_SDK_KEY=${APPLOVIN_SDK_KEY} \
  --dart-define=REVENUECAT_ANDROID_KEY=${REVENUECAT_ANDROID_KEY} \
  --dart-define=SUPPORT_EMAIL=${SUPPORT_EMAIL}

echo "✅ Production APK built: build/app/outputs/flutter-apk/app-release.apk"
```

#### `build_prod_ios.sh`
```bash
#!/bin/bash
set -e

echo "🚀 Building iOS for PRODUCTION..."

source secrets.env
export APP_ENV="prod"

# Validate required vars
if [ -z "$API_DOMAIN" ] || [ -z "$REVENUECAT_IOS_KEY" ]; then
  echo "❌ Missing required environment variables!"
  exit 1
fi

flutter clean
flutter pub get

cd ios
pod install
cd ..

flutter build ios \
  --release \
  --dart-define=APP_ENV=prod \
  --dart-define=API_DOMAIN=${API_DOMAIN} \
  --dart-define=SUPABASE_URL=${SUPABASE_URL} \
  --dart-define=SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY} \
  --dart-define=HUGGINGFACE_TOKEN=${HUGGINGFACE_TOKEN} \
  --dart-define=REPLICATE_API_TOKEN=${REPLICATE_API_TOKEN} \
  --dart-define=ADMOB_APP_ID_IOS=${ADMOB_APP_ID_IOS} \
  --dart-define=ADMOB_BANNER_AD_UNIT_ID=${ADMOB_BANNER_IOS_ID} \
  --dart-define=ADMOB_REWARDED_AD_UNIT_ID=${ADMOB_REWARDED_AD_UNIT_ID} \
  --dart-define=ADMOB_APP_OPEN_AD_UNIT_ID=${ADMOB_APP_OPEN_IOS_ID} \
  --dart-define=APPLOVIN_SDK_KEY=${APPLOVIN_SDK_KEY} \
  --dart-define=REVENUECAT_IOS_KEY=${REVENUECAT_IOS_KEY} \
  --dart-define=SUPPORT_EMAIL=${SUPPORT_EMAIL}

echo "✅ Production iOS built. Open ios/Runner.xcworkspace in Xcode to archive."
```

**Make scripts executable:**
```bash
chmod +x build_dev_android.sh build_prod_android.sh build_prod_ios.sh
```

---

## Remote Config Strategy

### Firebase Remote Config Setup

**Purpose:** Control features, A/B test, emergency toggles WITHOUT rebuilding app.

### Key Parameters to Add

```json
{
  "ads_enabled": true,
  "banner_ads_enabled": true,
  "rewarded_ads_enabled": true,
  "app_open_ads_enabled": true,
  "banner_ad_network": "auto",
  "rewarded_ad_network": "auto",
  "app_open_ad_network": "auto",
  
  "api_domain_fallback": "backup-api.railway.app",
  "splash_duration_ms": 1000,
  
  "feature_nano_banana_enabled": false,
  "feature_new_ai_model_enabled": false,
  
  "min_app_version_android": "1.0.0",
  "min_app_version_ios": "1.0.0",
  "force_update_enabled": false
}
```

### Conditional Values (Platform-Specific)

In Firebase Console → Remote Config → Add Condition:
- **Condition:** `Platform == iOS`
- **Value:** Different ad IDs for iOS

Example:
```
Parameter: admob_banner_id
Default: ca-app-pub-xxxxx/android-banner
Condition (iOS): ca-app-pub-xxxxx/ios-banner
```

### How to Use in Code

```dart
class RemoteConfigService {
  // Emergency API domain override
  String get apiDomainFallback => _remoteConfig.getString('api_domain_fallback');
  
  // Feature flags
  bool get isNanoBananaEnabled => _remoteConfig.getBool('feature_nano_banana_enabled');
  
  // Force update
  bool get forceUpdateEnabled => _remoteConfig.getBool('force_update_enabled');
  String get minAppVersion {
    return Platform.isIOS
        ? _remoteConfig.getString('min_app_version_ios')
        : _remoteConfig.getString('min_app_version_android');
  }
}
```

### Best Practices
1. **Always have safe defaults** in `setDefaults()` - app must work offline
2. **Use Remote Config for:**
   - Feature flags (enable/disable new features)
   - Ad network selection (AdMob/AppLovin/auto)
   - Emergency switches (disable broken features)
   - A/B testing (variant selection)
3. **Do NOT use Remote Config for:**
   - API keys (security risk)
   - Secrets (use dart-define instead)

---

## Testing Configurations

### Test Matrix

| Environment | Platform | Config File | Notes |
|------------|----------|-------------|-------|
| Dev | Android | `build_dev_android.sh` | Local API, test ads |
| Dev | iOS Simulator | `run_ios_simulator.sh` | AppLovin disabled |
| Staging | Android | `build_staging_android.sh` | Railway staging, test ads |
| Staging | iOS | `build_staging_ios.sh` | Railway staging, test ads |
| Prod | Android | `build_prod_android.sh` | Real ads, real IAP |
| Prod | iOS | `build_prod_ios.sh` | Real ads, real IAP |

### Quick Test Commands

**Test Remote Config:**
```bash
# Force fetch fresh config
flutter run --dart-define=FORCE_REMOTE_CONFIG_FETCH=true
```

**Test with Different API Domain:**
```bash
flutter run --dart-define=API_DOMAIN=localhost:5000
```

**Test without Ads:**
```bash
flutter run --dart-define=DISABLE_ADS=true
```

**Test Different Environment:**
```bash
flutter run --dart-define=APP_ENV=dev
```

---

## Centralizing Config Access

### Create `lib/app_config.dart`

To avoid repeating `String.fromEnvironment` everywhere:

```dart
import 'dart:io';

class AppConfig {
  // Environment
  static const String environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'prod',
  );
  
  static bool get isDev => environment == 'dev';
  static bool get isStaging => environment == 'staging';
  static bool get isProd => environment == 'prod';
  
  // API
  static const String apiDomain = String.fromEnvironment(
    'API_DOMAIN',
    defaultValue: 'web-production-a7698.up.railway.app',
  );
  
  static String get apiBaseUrl => 'https://$apiDomain';
  
  // Supabase
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  
  // RevenueCat
  static String get revenueCatApiKey {
    return Platform.isIOS
        ? const String.fromEnvironment('REVENUECAT_IOS_KEY', defaultValue: '')
        : const String.fromEnvironment('REVENUECAT_ANDROID_KEY', defaultValue: '');
  }
  
  // AdMob
  static String get admobAppId {
    return Platform.isIOS
        ? const String.fromEnvironment('ADMOB_APP_ID_IOS', defaultValue: '')
        : const String.fromEnvironment('ADMOB_APP_ID_ANDROID', defaultValue: '');
  }
  
  // Debug flags
  static const bool disableAppLovin = bool.fromEnvironment(
    'DISABLE_APPLOVIN',
    defaultValue: false,
  );
}
```

**Usage:**
```dart
import 'package:viso_ai/app_config.dart';

void main() {
  print('🚀 Running in ${AppConfig.environment} mode');
  print('📡 API: ${AppConfig.apiBaseUrl}');
  
  if (AppConfig.isDev) {
    // Enable debug features
  }
}
```

---

## Summary: Multi-Config Checklist

✅ **Environment Variables:**
- [ ] `secrets.env` created and populated with real values
- [ ] `secrets.env` added to `.gitignore` (DO NOT commit secrets!)
- [ ] Team members have their own `secrets.env` (shared securely via 1Password/Vault)

✅ **Build Scripts:**
- [ ] `build_dev_android.sh` - Development builds
- [ ] `build_prod_android.sh` - Production Android
- [ ] `build_prod_ios.sh` - Production iOS
- [ ] All scripts executable (`chmod +x`)

✅ **Remote Config:**
- [ ] Firebase Remote Config enabled
- [ ] All ad flags configured
- [ ] Feature flags added for new features
- [ ] Conditional values set for iOS vs Android

✅ **Code:**
- [ ] `lib/app_config.dart` created (centralized config access)
- [ ] All hardcoded API domains replaced with `AppConfig.apiDomain`
- [ ] All services use `AppConfig` instead of `String.fromEnvironment`

✅ **Testing:**
- [ ] Test dev build on both platforms
- [ ] Test prod build on both platforms
- [ ] Verify Remote Config values load correctly
- [ ] Verify ads show with correct IDs
- [ ] Verify IAP works with correct RevenueCat keys

---

**Next:** See `GIT_RAILWAY_DEPLOYMENT_GUIDE.md` for deployment workflow.

