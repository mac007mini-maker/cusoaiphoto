# 🛒 RevenueCat In-App Purchase - Complete Setup Guide

## 📋 MỤC LỤC

1. [Tổng quan](#tổng-quan)
2. [Setup RevenueCat Dashboard](#setup-revenuecat-dashboard)
3. [Test NGAY không cần Google Play](#test-ngay-không-cần-google-play)
4. [Implement vào Flutter App](#implement-vào-flutter-app)
5. [Testing Guide](#testing-guide)
6. [Troubleshooting](#troubleshooting)

---

## 🎯 TỔNG QUAN

### ✅ Đã Hoàn Thành

- [x] RevenueCat account created
- [x] Android app created trong RevenueCat
- [x] Test API key: `test_OvwtrjRddtWRHgmNdZgxCTiYLYX`
- [x] Project ID: projb4face67
- [x] Offering ID: ofrng1c5b1a3712
- [x] `purchases_flutter` package installed
- [x] `RevenueCatService` created

### 🚀 Tiếp Theo

- [ ] Setup products trong RevenueCat Dashboard
- [ ] Configure entitlements & offerings
- [ ] Integrate vào Pro page
- [ ] Test purchases locally
- [ ] Link Google Play sau khi approved

---

## 📱 SETUP REVENUECAT DASHBOARD

### Bước 1: Tạo Products (Test Mode)

**RevenueCat Dashboard → Products**

Click **"Add Product"** cho mỗi subscription plan:

#### **Product 1: Weekly**
```
Product ID: viso_ai_weekly
Display Name: Weekly Premium
Type: Subscription
Duration: 1 Week
Test Price: $7.99
```

#### **Product 2: Yearly**
```
Product ID: viso_ai_yearly
Display Name: Yearly Premium - Best Value
Type: Subscription
Duration: 1 Year
Test Price: $49.99
```

#### **Product 3: Lifetime**
```
Product ID: viso_ai_lifetime
Display Name: Lifetime Premium
Type: Non-renewing Subscription (or One-time purchase)
Test Price: $99.99
```

> **Lưu ý:** Đây là **test products** - RevenueCat sẽ tự động mock purchases. Không cần Google Play account!

---

### Bước 2: Tạo Entitlements

**RevenueCat Dashboard → Entitlements**

Click **"Add Entitlement"**:

```
Entitlement ID: pro
Display Name: Premium Features
Description: Unlock all premium features, no ads, unlimited creations

Attach Products:
- viso_ai_weekly
- viso_ai_yearly
- viso_ai_lifetime
```

> **Entitlement** = Quyền truy cập premium. Khi user mua bất kỳ product nào → Nhận entitlement "pro" → App unlock features.

---

### Bước 3: Tạo Offerings

**RevenueCat Dashboard → Offerings**

Click **"Create Offering"**:

```
Offering ID: default
Display Name: Premium Plans
Description: Choose your subscription plan
```

**Add Packages:**

1. **Lifetime Package**
   ```
   Package Identifier: $rc_lifetime
   Product: viso_ai_lifetime
   ```

2. **Annual Package**
   ```
   Package Identifier: $rc_annual
   Product: viso_ai_yearly
   ```

3. **Weekly Package**
   ```
   Package Identifier: $rc_weekly
   Product: viso_ai_weekly
   ```

> **Offerings** = Nhóm các gói subscription để hiển thị cho user. App sẽ load "default" offering.

---

### Bước 4: Configure Test Mode

**RevenueCat Dashboard → Settings → Test mode**

- ✅ Enable test mode
- ✅ Test purchases are FREE
- ✅ No Google Play/App Store needed

---

## ✅ TEST NGAY KHÔNG CẦN GOOGLE PLAY

### Option 1: RevenueCat Test Mode (RECOMMEND)

**RevenueCat tự động mock purchases khi dùng test API key!**

```dart
// App tự động dùng test key
RevenueCatService.initialize(); // Uses test_OvwtrjRddtWRHgmNdZgxCTiYLYX

// Load offerings
final packages = await RevenueCatService().getSubscriptionPackages();
// ✅ Returns test products (viso_ai_weekly, yearly, lifetime)

// Purchase
final result = await RevenueCatService().purchasePackage(packages[0]);
// ✅ Mock purchase - MIỄN PHÍ, không cần Google Play!

// Check status
final isPro = await RevenueCatService().isPremiumUser();
// ✅ Returns true nếu mock purchase thành công
```

**Kiểm tra trong RevenueCat Dashboard:**
- **Dashboard → Customers** → Thấy test user với active subscription
- **Dashboard → Events** → Thấy purchase events

---

### Option 2: Google Play Internal Testing (Khi account approved)

**Sau khi Google Play account được approve:**

1. **Upload APK lên Internal Testing**
   ```bash
   flutter build apk --release
   ```

2. **Google Play Console → Internal Testing**
   - Upload APK
   - Add testers (max 100 emails)

3. **Install via Internal Testing link**

4. **Test purchases:**
   - Purchases là **SANDBOX** (miễn phí)
   - RevenueCat auto-detect sandbox mode
   - ✅ Test real purchase flow

---

## 💻 IMPLEMENT VÀO FLUTTER APP

### Bước 1: Initialize RevenueCat trong main.dart

**File: `lib/main.dart`**

```dart
import '/services/revenue_cat_service.dart';

void main() async {
  // ... existing Firebase init ...
  
  await UserService().initialize();
  await RemoteConfigService().initialize();
  
  // Initialize RevenueCat
  await RevenueCatService().initialize();
  
  // ... rest of main ...
}
```

---

### Bước 2: Update Pro Page Model

**File: `lib/pro/pro_model.dart`**

```dart
import '/flutter_flow/flutter_flow_util.dart';
import 'pro_widget.dart' show ProWidget;
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class ProModel extends FlutterFlowModel<ProWidget> {
  // State fields
  int? selectedPackageIndex;
  List<Package> availablePackages = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
```

---

### Bước 3: Update Pro Widget - Load Products

**File: `lib/pro/pro_widget.dart`**

**Add imports:**
```dart
import '/services/revenue_cat_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
```

**Update initState:**
```dart
@override
void initState() {
  super.initState();
  _model = createModel(context, () => ProModel());
  
  // Load RevenueCat products
  _loadProducts();
}

Future<void> _loadProducts() async {
  setState(() {
    _model.isLoading = true;
    _model.errorMessage = null;
  });

  try {
    final packages = await RevenueCatService().getSubscriptionPackages();
    
    setState(() {
      _model.availablePackages = packages;
      _model.isLoading = false;
      
      // Auto-select first package (Lifetime - best value)
      if (packages.isNotEmpty) {
        _model.selectedPackageIndex = 0;
      }
    });
    
    debugPrint('✅ Loaded ${packages.length} subscription packages');
  } catch (e) {
    setState(() {
      _model.isLoading = false;
      _model.errorMessage = 'Failed to load subscription plans: $e';
    });
    
    debugPrint('❌ Error loading products: $e');
  }
}
```

---

### Bước 4: Update Restore Button Handler

**Find "Restore" button (line ~100-140):**

```dart
FFButtonWidget(
  onPressed: () async {
    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Restoring purchases...')),
    );
    
    // Restore purchases
    final result = await RevenueCatService().restorePurchases();
    
    if (result.success && result.isPremium) {
      // Success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Purchases restored! You are now premium.'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate back to homepage
      context.pushNamed(HomepageWidget.routeName);
    } else {
      // No purchases found
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'No active purchases found'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  },
  text: FFLocalizations.of(context).getText('8de8u8eh' /* Restore */),
  // ... existing options ...
),
```

---

### Bước 5: Display Real Product Prices

**Find subscription card section (line ~420-900) - Replace hardcoded prices:**

**Before (hardcoded):**
```dart
Text(
  '₫2,050,000',  // Hardcoded
  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
),
```

**After (dynamic from RevenueCat):**
```dart
// Show loading state
if (_model.isLoading)
  CircularProgressIndicator(color: Colors.white)
else if (_model.errorMessage != null)
  Text(
    'Error loading prices',
    style: TextStyle(color: Colors.red),
  )
else
  // Display packages from RevenueCat
  Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: _model.availablePackages.asMap().entries.map((entry) {
      final index = entry.key;
      final package = entry.value;
      final product = package.storeProduct;
      final isSelected = _model.selectedPackageIndex == index;
      
      return GestureDetector(
        onTap: () {
          setState(() {
            _model.selectedPackageIndex = index;
          });
        },
        child: Container(
          width: 110.0,
          height: 160.0,
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF9810FA) : Colors.transparent,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: Colors.white,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Badge (BEST VALUE, etc.)
                if (package.packageType == PackageType.lifetime)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFF1E2939),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'BEST',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  )
                else if (package.packageType == PackageType.annual)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFF00C950),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'SAVE 89%',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                
                // Icon
                Icon(
                  package.packageType == PackageType.lifetime
                      ? Icons.all_inclusive
                      : package.packageType == PackageType.annual
                          ? Icons.calendar_today
                          : Icons.calendar_view_week,
                  color: Colors.white,
                  size: 32,
                ),
                
                // Package name
                Text(
                  package.packageType == PackageType.lifetime
                      ? 'Lifetime'
                      : package.packageType == PackageType.annual
                          ? 'Year'
                          : 'Week',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                // Price
                Text(
                  product.priceString,  // ✅ Real price from store
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                // Duration
                if (package.packageType != PackageType.lifetime)
                  Text(
                    '1 purchase',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }).toList(),
  ),
```

---

### Bước 6: Update Continue Button

**Find "Continue" button (usually near bottom):**

```dart
FFButtonWidget(
  onPressed: _model.isLoading || _model.selectedPackageIndex == null
      ? null
      : () async {
    // Get selected package
    final package = _model.availablePackages[_model.selectedPackageIndex!];
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      // Purchase
      final result = await RevenueCatService().purchasePackage(package);
      
      // Close loading
      Navigator.of(context).pop();
      
      if (result.success && result.isPremium) {
        // Success!
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Welcome to Premium!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to homepage
        context.pushNamed(HomepageWidget.routeName);
      } else if (result.userCancelled) {
        // User cancelled
        debugPrint('User cancelled purchase');
      } else {
        // Error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Purchase failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
  text: FFLocalizations.of(context).getText('Continue'),
  options: FFButtonOptions(
    width: double.infinity,
    height: 56.0,
    color: Color(0xFF9810FA),
    textStyle: TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    borderRadius: BorderRadius.circular(28),
  ),
),
```

---

## 🧪 TESTING GUIDE

### Test 1: Load Products

**Steps:**
1. Build debug APK:
   ```bash
   flutter build apk --debug
   ```

2. Install trên Android device

3. Open app → Navigate to Pro page

4. **Expected:**
   - ✅ Loading indicator appears
   - ✅ 3 packages load (Lifetime, Year, Week)
   - ✅ Prices display from RevenueCat test products
   - ✅ Console logs: "✅ Loaded 3 subscription packages"

---

### Test 2: Mock Purchase (RevenueCat Test Mode)

**Steps:**
1. Select a package (e.g., Weekly)

2. Click "Continue"

3. **Expected:**
   - ✅ Purchase dialog appears (mock)
   - ✅ Purchase succeeds immediately (no payment)
   - ✅ Snackbar: "🎉 Welcome to Premium!"
   - ✅ Navigate back to homepage
   - ✅ Ads automatically disabled (premium user)

4. **Verify in RevenueCat Dashboard:**
   - Dashboard → Customers → See new test customer
   - Customer has active "pro" entitlement

---

### Test 3: Restore Purchases

**Steps:**
1. Uninstall app

2. Reinstall app

3. Open Pro page

4. Click "Restore"

5. **Expected:**
   - ✅ Snackbar: "Restoring purchases..."
   - ✅ RevenueCat checks previous purchases
   - ✅ If found: "✅ Purchases restored! You are now premium."
   - ✅ Premium status restored → Ads disabled

---

### Test 4: Premium User - Ads Disabled

**Steps:**
1. Complete a purchase

2. Navigate to any page with ads (Homepage, AI Tools, etc.)

3. **Expected:**
   - ❌ NO Banner Ads displayed
   - ❌ NO App Open Ads
   - ❌ NO Rewarded Ads required
   - ✅ UserService().isPremiumUser = true
   - ✅ RemoteConfigService() auto-bypasses ads

---

## 🔧 TROUBLESHOOTING

### Issue 1: "No offerings available"

**Problem:** `_currentOfferings?.current == null`

**Solutions:**
1. Check RevenueCat Dashboard → Products → At least 1 product created
2. Check Entitlements → Products attached
3. Check Offerings → "default" offering exists
4. Wait 5 minutes for RevenueCat sync

---

### Issue 2: "Purchase fails immediately"

**Problem:** PurchasesErrorCode.productNotAvailableForPurchaseError

**Solutions:**
1. **Using test mode:** Products auto-available
2. **Using Google Play:** 
   - App uploaded to Internal Testing
   - Products created in Play Console
   - Products activated
   - RevenueCat linked to Play Console (service account)

---

### Issue 3: "Restore returns no purchases"

**Problem:** No active subscriptions found

**Solutions:**
1. **Test mode:** Make at least 1 mock purchase first
2. **Google Play:** 
   - Purchase made on same Google account
   - Subscription still active (not expired/cancelled)
3. Check RevenueCat Dashboard → Customers → Verify purchase exists

---

### Issue 4: "Prices show $0.00"

**Problem:** Products not loaded from store

**Solutions:**
1. **Test mode:** Check Products in RevenueCat Dashboard have prices
2. **Google Play:** 
   - Products created in Play Console
   - Prices set correctly
   - App uploaded (minimum Internal Testing)

---

## 📝 NEXT STEPS - KHI GOOGLE PLAY APPROVED

### 1. Create Products in Google Play Console

**Google Play Console → Monetize → In-app products**

```
viso_ai_weekly:
- Price: ₫165,000
- Billing: Every 1 week

viso_ai_yearly:
- Price: ₫944,000  
- Billing: Every 1 year

viso_ai_lifetime:
- Price: ₫2,050,000
- Type: Non-renewing subscription
```

---

### 2. Link RevenueCat to Google Play

**RevenueCat Dashboard → Project Settings → Service Credentials**

1. Download `service-account.json` from Google Play Console:
   - **Settings** → **API access** → **Service accounts**
   - Create or use existing service account
   - Grant "View financial data" permission
   - Download JSON key

2. Upload to RevenueCat:
   - Click **"Google Play"**
   - Upload `service-account.json`
   - Click **"Save"**

---

### 3. Import Products

**RevenueCat Dashboard → Products**

Click **"Import from Google Play"**

RevenueCat auto-syncs:
- ✅ Product IDs
- ✅ Prices
- ✅ Subscription durations

---

### 4. Switch to Production API Key

**⚠️ CRITICAL - Security Notice:**

**NEVER ship the test key to production!** Test key = `test_OvwtrjRddtWRHgmNdZgxCTiYLYX` is for local development only.

**When ready for production:**

1. RevenueCat Dashboard → **API Keys**
2. Copy **Public SDK key (Production)** for Android & iOS:
   - Android: `prod_xxxxxxxxxxxxx`
   - iOS: `appl_xxxxxxxxxxxxx`

3. **Option A: Using Replit Secrets (RECOMMENDED)**
   ```
   1. Replit Console → Secrets (Lock icon)
   2. Add secrets:
      - REVENUECAT_ANDROID_KEY=prod_xxxxxxxxxxxxx
      - REVENUECAT_IOS_KEY=appl_xxxxxxxxxxxxx
   3. App auto-loads from environment
   ```

4. **Option B: Build-time configuration**
   ```bash
   # Android
   flutter build apk --release \
     --dart-define=REVENUECAT_ANDROID_KEY=prod_xxxxx

   # iOS
   flutter build ipa --release \
     --dart-define=REVENUECAT_IOS_KEY=appl_xxxxx
   ```

5. **Verify production key loaded:**
   - Check logs: `🛒 Initializing RevenueCat with key: prod_xxxxx...`
   - If logs show `test_uSu...` → **STOP! Still using test key!**

---

## 🎯 SUMMARY

### ✅ Current Status

- [x] RevenueCat SDK integrated
- [x] RevenueCatService created
- [x] Test API key configured
- [x] Can test purchases locally (mock)

### 🚀 Test NOW (Không cần Google Play)

```bash
# Build debug APK
flutter build apk --debug

# Install
adb install build/app/outputs/flutter-apk/app-debug.apk

# Test purchases (FREE, mock mode)
```

### 📱 Production (Sau khi Google Play approved)

1. Create products in Play Console
2. Link RevenueCat ↔ Google Play
3. Import products
4. Switch to production API key
5. Upload release APK
6. Test with real sandbox purchases (still FREE)

---

## 💡 KEY POINTS

**Email khác nhau:** ✅ RevenueCat email A, Play Console email B = OK

**Thanh toán:** 💰 Google Play → Bank anh | RevenueCat không động vào tiền

**Doanh thu >$10k:** 📊 RevenueCat charge 1% tracked revenue ($15k → pay $50/month)

**Test miễn phí:**
- ✅ RevenueCat test mode (ngay bây giờ)
- ✅ Google Play sandbox (sau khi approved)
- ✅ Không mất tiền cho cả 2 options!

---

**Có thắc mắc gì anh inbox em nhé! 😊**
