# RevenueCat Setup Guide for Viso AI

## Overview
Viso AI uses RevenueCat for in-app purchase management. This guide helps you set up RevenueCat for testing and production.

## Current Status
✅ RevenueCat SDK integrated in code  
✅ Pro page UI connected to RevenueCat  
❌ Products not configured (causing CONFIGURATION_ERROR)

## Quick Fix for Testing

### Option 1: iOS Testing with StoreKit Configuration (Recommended)

**File Already Created:** `Configuration.storekit` in project root

**Setup Steps:**

1. **Open Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Configure StoreKit:**
   - Click on scheme dropdown (top-left, near "Runner" button)
   - Select "Edit Scheme..."
   - Go to "Run" → "Options" tab
   - Under "StoreKit Configuration", click dropdown
   - Select "Configuration.storekit"
   - Click "Close"

3. **Clean and Rebuild:**
   ```bash
   flutter clean
   flutter build ios
   ```

4. **Run on Simulator:**
   - Products will now load from local StoreKit file
   - No need for App Store Connect setup

**Products in StoreKit:**
- ✅ Lifetime Premium: ₫2,050,000 (visoai_lifetime)
- ✅ Yearly Premium: ₫944,000/year (visoai_yearly)
- ✅ Weekly Premium: ₫165,000/week (visoai_weekly)

### Option 2: Android Testing (Requires Google Play Setup)

**Current Issue:** Products must be configured in Google Play Console first.

**Steps:**
1. Upload APK to Google Play Console (Internal Testing track)
2. Create in-app products:
   - `visoai_lifetime` - Non-consumable - ₫2,050,000
   - `visoai_yearly` - Subscription - ₫944,000/year
   - `visoai_weekly` - Subscription - ₫165,000/week
3. Link RevenueCat to Google Play (RevenueCat Dashboard → App Settings → Google Play)
4. Add tester email to Internal Testing track
5. Wait 2-4 hours for products to sync

## Production Setup

### Step 1: RevenueCat Dashboard Configuration

1. **Go to RevenueCat Dashboard:**
   - URL: https://app.revenuecat.com
   - Current Project: `projb4face67`
   - Offering ID: `ofrng1c5b1a3712`

2. **Configure Products:**
   - Go to "Products" section
   - Add Product IDs:
     - `visoai_lifetime` (iOS/Android)
     - `visoai_yearly` (iOS/Android)
     - `visoai_weekly` (iOS/Android)

3. **Setup Entitlements:**
   - Go to "Entitlements"
   - Create entitlement: `pro`
   - Attach all products to `pro` entitlement

4. **Create Offering:**
   - Go to "Offerings"
   - Create offering: `default` (or use existing `ofrng1c5b1a3712`)
   - Add packages:
     - Package: `$rc_lifetime` → Product: `visoai_lifetime`
     - Package: `$rc_annual` → Product: `visoai_yearly`
     - Package: `$rc_weekly` → Product: `visoai_weekly`

### Step 2: App Store Connect (iOS)

1. **Create In-App Purchases:**
   - Go to App Store Connect → Your App → In-App Purchases
   - Create 3 products matching RevenueCat product IDs

2. **Configure Products:**
   ```
   visoai_lifetime:
   - Type: Non-Consumable
   - Reference Name: Lifetime Premium
   - Product ID: visoai_lifetime
   - Price: ₫2,050,000 (or $99.99 USD)
   
   visoai_yearly:
   - Type: Auto-Renewable Subscription
   - Reference Name: Yearly Premium
   - Product ID: visoai_yearly
   - Subscription Duration: 1 Year
   - Price: ₫944,000 (or $44.99 USD)
   
   visoai_weekly:
   - Type: Auto-Renewable Subscription
   - Reference Name: Weekly Premium
   - Product ID: visoai_weekly
   - Subscription Duration: 1 Week
   - Price: ₫165,000 (or $7.99 USD)
   ```

3. **Submit for Review:** Products must be approved before production use

### Step 3: Google Play Console (Android)

1. **Upload APK/AAB to Internal Testing track first**

2. **Create In-App Products:**
   - Go to Monetize → Products → In-app products
   - Create same products as iOS

3. **Create Subscriptions:**
   - Go to Monetize → Products → Subscriptions
   - Create subscription group: "Viso AI Premium"
   - Add yearly and weekly subscriptions

4. **Link to RevenueCat:**
   - RevenueCat Dashboard → App Settings → Google Play
   - Follow OAuth flow to link accounts

### Step 4: Update API Keys (Production)

**Current:** Using test key for all platforms
```dart
static const String _testApiKey = 'test_OvwtrjRddtWRHgmNdZgxCTiYLYX';
```

**Production:** Set environment variables or update code:
```dart
// In lib/services/revenue_cat_service.dart
static const String _prodApiKeyAndroid = 'YOUR_ANDROID_KEY';
static const String _prodApiKeyIOS = 'YOUR_IOS_KEY';
```

Or use build-time environment variables:
```bash
flutter build apk --dart-define=REVENUECAT_ANDROID_KEY=your_key
flutter build ios --dart-define=REVENUECAT_IOS_KEY=your_key
```

## Troubleshooting

### Error: CONFIGURATION_ERROR
**Cause:** Products not found in App Store Connect or Google Play  
**Fix:** 
- iOS: Use StoreKit Configuration (see Option 1 above)
- Android: Setup products in Google Play Console

### Error: Packages is EMPTY
**Cause:** No offerings configured in RevenueCat  
**Fix:** Create offering in RevenueCat dashboard and attach products

### Error: readableErrorCode: STORE_PROBLEM
**Cause:** App not signed correctly or sandbox environment issues  
**Fix:** 
- iOS: Ensure proper provisioning profile
- Android: Use release signing config for testing IAP

### Testing Tips

1. **Always test on real devices for IAP** (emulators have limitations)
2. **Use sandbox accounts:**
   - iOS: Settings → App Store → Sandbox Account
   - Android: Add tester in Google Play Console → License Testing
3. **Clear app data between tests** to reset purchase state
4. **Monitor RevenueCat Customer view** to see purchase events

## Current Implementation

### Pro Page (`lib/pro/pro_widget.dart`)
- ✅ Loads packages from RevenueCat on init
- ✅ Displays hardcoded UI for Web (RevenueCat not supported on Web)
- ✅ Dynamic pricing from RevenueCat for mobile
- ✅ Auto-selects first package (Lifetime - best value)
- ✅ Purchase and Restore flows integrated

### RevenueCat Service (`lib/services/revenue_cat_service.dart`)
- ✅ Initialize SDK on app start
- ✅ Load offerings and packages
- ✅ Purchase flow with error handling
- ✅ Restore purchases
- ✅ Check premium status
- ✅ Debug logging for troubleshooting

## Next Steps

1. ✅ **For immediate testing:** Use iOS with StoreKit Configuration
2. ⏳ **For production:** Complete App Store Connect and Google Play setup
3. ⏳ **Update API keys:** Replace test key with production keys
4. ⏳ **Submit for review:** Get IAP products approved by Apple/Google

## Support

- **RevenueCat Docs:** https://docs.revenuecat.com
- **RevenueCat Dashboard:** https://app.revenuecat.com
- **Test API Key:** `test_OvwtrjRddtWRHgmNdZgxCTiYLYX`
- **Project ID:** `projb4face67`
- **Offering ID:** `ofrng1c5b1a3712`
