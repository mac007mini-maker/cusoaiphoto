# 🛒 Pro Page Integration - RevenueCat Dynamic Subscription Cards

## 📋 TL;DR

Pro widget hiện tại có **1127 dòng** code (99% là UI styling từ FlutterFlow). Anh chỉ cần:
1. ✅ Add 2 imports
2. ✅ Update initState (add 1 method call)
3. ✅ Update Restore button handler
4. ✅ Update Continue button handler  
5. ✅ Replace 3 hardcoded subscription cards với dynamic rendering

**Estimated time:** 10-15 phút

---

## ✅ ĐÃ HOÀN THÀNH

- [x] `RevenueCatService` created và tested
- [x] `ProModel` updated với fields: `isLoading`, `errorMessage`, `availablePackages`, `selectedPackageIndex`
- [x] RevenueCat initialized trong `main.dart`

---

## 🔧 CÁC BƯỚC INTEGRATE

### **Bước 1: Add Imports** (Line 1-10)

**File:** `lib/pro/pro_widget.dart`

**Add these imports:**
```dart
import '/services/revenue_cat_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
```

**Result:**
```dart
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/services/revenue_cat_service.dart';  // ✅ NEW
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';  // ✅ NEW
import 'pro_model.dart';
export 'pro_model.dart';
```

---

### **Bước 2: Update initState** (Line ~28-32)

**BEFORE:**
```dart
@override
void initState() {
  super.initState();
  _model = createModel(context, () => ProModel());
}
```

**AFTER:**
```dart
@override
void initState() {
  super.initState();
  _model = createModel(context, () => ProModel());
  
  // Load RevenueCat subscription packages
  _loadSubscriptionPackages();
}

/// Load subscription packages from RevenueCat
Future<void> _loadSubscriptionPackages() async {
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
      _model.errorMessage = 'Failed to load subscription plans. Please try again.';
    });
    
    debugPrint('❌ Error loading packages: $e');
  }
}
```

---

### **Bước 3: Update Restore Button** (Line ~100-140)

**Find this:**
```dart
FFButtonWidget(
  onPressed: () {
    print('Button pressed ...');
  },
  text: FFLocalizations.of(context).getText(
    '8de8u8eh' /* Restore */,
  ),
```

**Replace with:**
```dart
FFButtonWidget(
  onPressed: () async {
    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Restoring purchases...'),
        duration: Duration(seconds: 2),
      ),
    );
    
    // Restore purchases
    try {
      final result = await RevenueCatService().restorePurchases();
      
      if (result.success && result.isPremium) {
        // Success
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Purchases restored! You are now premium.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          
          // Navigate back to homepage
          context.pushNamed(HomepageWidget.routeName);
        }
      } else {
        // No purchases found
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'No active purchases found'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error restoring purchases: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  },
  text: FFLocalizations.of(context).getText(
    '8de8u8eh' /* Restore */,
  ),
```

---

### **Bước 4: Update Continue Button** (Line ~945-980)

**Find this:**
```dart
FFButtonWidget(
  onPressed: () {
    print('Button pressed ...');
  },
  text: FFLocalizations.of(context).getText(
    '6qgq3qxc' /* Continue */,
  ),
```

**Replace with:**
```dart
FFButtonWidget(
  onPressed: _model.isLoading || 
             _model.selectedPackageIndex == null ||
             _model.availablePackages.isEmpty
      ? null
      : () async {
    // Get selected package
    final package = _model.availablePackages[_model.selectedPackageIndex!];
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Processing purchase...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
    
    try {
      // Purchase package
      final result = await RevenueCatService().purchasePackage(package);
      
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      if (result.success && result.isPremium) {
        // Success!
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎉 Welcome to Premium! All features unlocked.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          
          // Navigate back to homepage
          await Future.delayed(Duration(seconds: 1));
          if (context.mounted) {
            context.pushNamed(HomepageWidget.routeName);
          }
        }
      } else if (result.userCancelled) {
        // User cancelled - no message needed
        debugPrint('User cancelled purchase');
      } else {
        // Error
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Purchase failed. Please try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  },
  text: FFLocalizations.of(context).getText(
    '6qgq3qxc' /* Continue */,
  ),
```

---

### **Bước 5: Replace Hardcoded Subscription Cards** (Line ~504-1027)

Đây là phần **phức tạp nhất** vì có **500+ dòng code styling** cho 3 cards.

#### **Option A: Keep Hardcoded UI + Update Prices Only (SIMPLEST)**

Giữ nguyên UI structure, chỉ replace 3 hardcoded prices với dynamic prices:

**Find these 3 prices và replace:**

1. **Lifetime price** (Line ~570):
   ```dart
   // BEFORE
   Text(
     FFLocalizations.of(context).getText(
       'b1j0s4jo' /* ₫2,050,000 */,
     ),
   
   // AFTER
   Text(
     _model.availablePackages.isNotEmpty && _model.availablePackages.length > 0
         ? _model.availablePackages[0].storeProduct.priceString
         : '₫2,050,000',  // Fallback
   ```

2. **Yearly price** (Line ~743):
   ```dart
   // BEFORE
   Text(
     FFLocalizations.of(context).getText(
       'hsgsqr0o' /* ₫944,000 */,
     ),
   
   // AFTER
   Text(
     _model.availablePackages.length > 1
         ? _model.availablePackages[1].storeProduct.priceString
         : '₫944,000',  // Fallback
   ```

3. **Weekly price** (Line ~915):
   ```dart
   // BEFORE
   Text(
     FFLocalizations.of(context).getText(
       'uxqsw0x2' /* ₫165,000 */,
     ),
   
   // AFTER
   Text(
     _model.availablePackages.length > 2
         ? _model.availablePackages[2].storeProduct.priceString
         : '₫165,000',  // Fallback
   ```

**Pros:** Simplest, keeps existing UI  
**Cons:** Prices won't match if RevenueCat products order changes

---

#### **Option B: Full Dynamic Rendering (RECOMMENDED)**

Replace toàn bộ 3 cards section với dynamic rendering từ packages.

**Find this Row (Line ~504):**
```dart
Row(
  mainAxisSize: MainAxisSize.max,
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    Container(  // First card (Lifetime)
      width: 110.0,
      ...
    ),
    Container(  // Second card (Year)
      ...
    ),
    Container(  // Third card (Week)
      ...
    ),
  ].divide(SizedBox(width: 8.0)),
),
```

**Replace entire Row với:**
```dart
// Dynamic subscription cards from RevenueCat
_model.isLoading
    ? Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      )
    : _model.errorMessage != null
        ? Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                _model.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _model.availablePackages.asMap().entries.map((entry) {
              final index = entry.key;
              final package = entry.value;
              final product = package.storeProduct;
              final isSelected = _model.selectedPackageIndex == index;
              
              // Package metadata
              final isLifetime = package.packageType == PackageType.lifetime;
              final isAnnual = package.packageType == PackageType.annual;
              final isWeekly = package.packageType == PackageType.weekly;
              
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
                    color: isSelected 
                        ? Color(0xFF9810FA) 
                        : FlutterFlowTheme.of(context).accent1,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Badge (BEST VALUE, SAVE 89%, etc.)
                        if (isLifetime)
                          Container(
                            width: double.infinity,
                            height: 24.0,
                            decoration: BoxDecoration(
                              color: Color(0xFF1E2939),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Text(
                                'BEST VALUE',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                        else if (isAnnual)
                          Container(
                            width: double.infinity,
                            height: 24.0,
                            decoration: BoxDecoration(
                              color: Color(0xFF00C950),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Text(
                                'SAVE 89%',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                        else
                          SizedBox(height: 24.0), // Placeholder for alignment
                        
                        // Icon
                        Column(
                          children: [
                            Text(
                              isLifetime ? '∞' : isAnnual ? '📅' : '🗓️',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 30.0,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              isLifetime 
                                  ? 'Lifetime\n1 purchase' 
                                  : isAnnual 
                                      ? 'Year\nBest value' 
                                      : 'Week\n₫23,571/day',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                        
                        // Price (DYNAMIC from RevenueCat!)
                        Text(
                          product.priceString,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
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

**Pros:** Fully dynamic, adapts to any products in RevenueCat  
**Cons:** More code to replace

---

## 🧪 TESTING

### Test 1: Load Products
1. Open Pro page
2. **Expected:** Loading spinner → 3 cards appear với real prices từ RevenueCat

### Test 2: Select Package
1. Tap on a package card
2. **Expected:** Card highlights (purple background, thicker border)

### Test 3: Purchase
1. Select package
2. Click "Continue"
3. **Expected:** Loading dialog → Success message → Navigate to homepage → Ads disabled

### Test 4: Restore
1. Click "Restore"
2. **Expected:** "Restoring..." → Success/No purchases message

---

## 🎯 SUMMARY

**Integration complexity:**
- **Option A** (Update prices only): ⭐⭐☆☆☆ (5 phút - Easiest)
- **Option B** (Full dynamic rendering): ⭐⭐⭐⭐☆ (15 phút - Recommended)

**Recommended: Option B** - Fully dynamic, production-ready

---

**Questions? Let me know! 😊**
