# 🧪 RevenueCat IAP Testing Guide

## ⚠️ Quan trọng
**RevenueCat IAP KHÔNG hoạt động trên Web/Replit!** 
Bắt buộc phải test trên Android device thật hoặc emulator.

---

## 📋 Prerequisites

### 1. Build APK trên máy local
```bash
flutter pub get
flutter build apk --debug
```
Output: `build/app/outputs/flutter-apk/app-debug.apk`

### 2. Setup RevenueCat Dashboard

#### A. Login RevenueCat
https://app.revenuecat.com (dùng test key: `test_OvwtrjRddtWRHgmNdZgxCTiYLYX`)

**Project Info:**
- **Project ID:** projb4face67
- **Offering ID (RevenueCat ID):** ofrng1c5b1a3712

#### B. Create Products (Tab "Products")
Click "Add Product" và tạo 3 products:

| Product ID | Type | Price |
|-----------|------|-------|
| `lifetime_2050k` | Non-consumable | ₫2,050,000 VND |
| `yearly_944k` | Auto-renewable subscription | ₫944,000 VND |
| `weekly_165k` | Auto-renewable subscription | ₫165,000 VND |

**Lưu ý:** Product ID phải trùng với Google Play Console sau này!

#### C. Create Entitlement (Tab "Entitlements")
1. Click "New Entitlement"
2. Identifier: `premium`
3. Description: "Full access to all premium features"
4. Attach all 3 products trên

#### D. Create Offering (Tab "Offerings")
1. Click "New Offering"
2. Identifier: `default` (tên này khớp với code trong `RevenueCatService`)
3. Add 3 packages:
   - Package Type: **Lifetime** → Product: `lifetime_2050k`
   - Package Type: **Annual** → Product: `yearly_944k`
   - Package Type: **Weekly** → Product: `weekly_165k`

---

## 🎯 Testing Scenarios

### Scenario 1: Test Mode (Không cần Google Play setup)

RevenueCat có **Test Mode** cho phép mock purchases!

**Bước thực hiện:**
1. Install APK: `adb install build/app/outputs/flutter-apk/app-debug.apk`
2. Open app → Navigate to Pro page
3. **Quan sát:**
   - Loading spinner hiển thị khi load packages
   - 3 subscription cards render với:
     - ✅ Dynamic prices từ RevenueCat
     - ✅ Badges (BEST VALUE, SAVE 89%)
     - ✅ Selection states (tap để select)
4. Click "Continue" → Purchase flow
   - **Test mode:** Sẽ show mock purchase dialog
   - **Production:** Redirect đến Google Play billing

**Check logs:**
```bash
adb logcat | grep RevenueCat
```

Expected output:
```
✅ Loaded 3 subscription packages
Package: Lifetime - ₫2,050,000
Package: Yearly - ₫944,000
Package: Weekly - ₫165,000
```

---

### Scenario 2: Test Restore Flow

**Bước thực hiện:**
1. Click "Restore" button trên Pro page
2. **Test mode:** Mock restore thành công
3. **Production:** Restore từ Google Play

Expected:
- Success: SnackBar "Purchases restored successfully!"
- No purchases: SnackBar "No previous purchases found"
- Error: SnackBar "Failed to restore purchases"

---

### Scenario 3: Production Testing (Sau khi setup Google Play)

**Prerequisites:**
- Google Play Console account
- App published (internal testing track)
- Products configured trên Play Console

**Steps:**
1. Replace test key với production key:
   ```dart
   // lib/main.dart
   await RevenueCat.configure(
     PurchasesConfiguration("appl_xxxxxxxxxxxxx"), // Production key
   );
   ```

2. Build release APK:
   ```bash
   flutter build apk --release
   ```

3. Upload lên Internal Testing track

4. Test với licensed tester account:
   - Add email vào "License testers" trên Play Console
   - Install app từ Play Store (internal testing link)
   - Navigate to Pro page → See real prices
   - Click Continue → Real Google Play purchase flow

---

## 🐛 Troubleshooting

### Issue 1: "No packages available"
**Nguyên nhân:** RevenueCat Dashboard chưa setup đúng

**Fix:**
1. Check offering identifier = `default`
2. Verify 3 packages exist trong offering
3. Check API key đúng (test/production)

### Issue 2: "Failed to load subscription plans"
**Nguyên nhân:** Network error hoặc API key sai

**Fix:**
1. Check internet connection
2. Verify API key trong `main.dart`
3. Check logs: `adb logcat | grep RevenueCat`

### Issue 3: Purchase không hoạt động
**Nguyên nhân:** 
- Test mode: Normal behavior (mock purchase)
- Production: Chưa setup Google Play products

**Fix:**
1. **Test mode:** Purchases sẽ mock - OK!
2. **Production:** Setup products trên Google Play Console với cùng product IDs

### Issue 4: Web shows hardcoded prices
**Nguyên nhân:** Web bundle chưa rebuild

**Fix:**
```bash
flutter clean
flutter build web --release
```

**Lưu ý:** IAP vẫn không hoạt động trên web (limitation của RevenueCat SDK)

---

## 📊 Expected Pro Page Behavior

### Loading State
```
┌─────────────────────────┐
│   Loading spinner       │
│   (CircularProgressIndicator) │
└─────────────────────────┘
```

### Success State (3 packages loaded)
```
┌───────┐  ┌───────┐  ┌───────┐
│BEST   │  │SAVE   │  │       │
│VALUE  │  │89%    │  │       │
│  ∞    │  │  📅   │  │  🗓️   │
│Lifetime│ │ Year  │  │ Week  │
│₫2,050,│  │₫944,  │  │₫165,  │
│000    │  │000    │  │000    │
└───────┘  └───────┘  └───────┘
   ^(selected)
```

### Error State
```
┌─────────────────────────┐
│ Failed to load          │
│ subscription plans.     │
│ Please try again.       │
└─────────────────────────┘
```

---

## ✅ Success Criteria

### ✓ Dynamic Pricing Works
- [ ] Prices load từ RevenueCat (not hardcoded)
- [ ] 3 cards render correctly
- [ ] Weekly daily cost computed: ₫23,571/day

### ✓ Selection State
- [ ] First package (Lifetime) auto-selected
- [ ] Tap other cards → Selection updates
- [ ] Selected card highlights (border color)

### ✓ Purchase Flow
- [ ] Continue button disabled khi loading
- [ ] Continue button calls RevenueCat purchase
- [ ] Loading dialog shows "Processing purchase..."
- [ ] Success/error snackbar displays

### ✓ Restore Flow
- [ ] Restore button calls RevenueCat restore
- [ ] Snackbar shows restore result

---

## 📝 Next Steps After Testing

1. **Google Play Setup:**
   - Create app listing trên Play Console
   - Add in-app products (same IDs as RevenueCat)
   - Submit for review

2. **Replace Test Key:**
   - Get production API key từ RevenueCat
   - Update `main.dart`

3. **Production Build:**
   ```bash
   flutter build appbundle --release
   ```

4. **Upload to Play Store:**
   - Upload AAB file (not APK)
   - Internal testing → Closed testing → Production

---

## 💡 Tips

- **RevenueCat Test Mode** free testing - no billing!
- **Google Play Internal Testing** - test với real purchases (Google returns money)
- **Licensed Testers** - add team emails để test miễn phí
- **RevenueCat Dashboard** - Monitor all purchases/subscriptions

---

## 🔗 Resources

- RevenueCat Dashboard: https://app.revenuecat.com
- RevenueCat Docs: https://docs.revenuecat.com
- Google Play Console: https://play.google.com/console
- Testing Guide: https://docs.revenuecat.com/docs/google-play-store
