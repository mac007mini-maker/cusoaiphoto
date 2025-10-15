# 🧪 Build APK để Test Ads + IAP

## 🎯 Mục tiêu
Build APK debug để test **CẢ Ads VÀ IAP** trên device thật.

---

## ✅ Prerequisites (Setup trước khi build)

### **A. Setup Firebase Remote Config (Enable Ads)**

#### **Bước 1: Login Firebase Console**
https://console.firebase.google.com/project/viso-ai-photo-avatar

#### **Bước 2: Vào Remote Config**
```
Firebase Console → Engage → Remote Config
```

#### **Bước 3: Thêm Parameters (6 params)**

Click **"Add parameter"** và tạo từng parameter sau:

| Parameter name | Data type | Default value |
|----------------|-----------|---------------|
| `ads_enabled` | Boolean | `true` |
| `banner_ads_enabled` | Boolean | `true` |
| `rewarded_ads_enabled` | Boolean | `true` |
| `interstitial_ads_enabled` | Boolean | `true` |
| `app_open_ads_enabled` | Boolean | `true` |
| `native_ads_enabled` | Boolean | `false` |

**Lưu ý:**
- ⚠️ **Tên phải CHÍNH XÁC** (trùng với code trong `RemoteConfigService`)
- ⚠️ **Toggle "Use in-app default" = OFF** (để dùng giá trị từ Console)

#### **Bước 4: Publish Changes**
```
Click "Publish changes" button (màu xanh) ở góc trên bên phải
```

**Verify:**
```
✅ 6 parameters hiển thị trong Remote Config dashboard
✅ Status: Published
```

---

### **B. Setup RevenueCat (Enable IAP)**

#### **Bước 1: Login RevenueCat Dashboard**
https://app.revenuecat.com

#### **Bước 2: Create Products**
(Tab "Products" → Click "Add product")

| Product ID | Type | Description |
|-----------|------|-------------|
| `lifetime_2050k` | Non-consumable | Lifetime access |
| `yearly_944k` | Auto-renewable subscription | Yearly subscription |
| `weekly_165k` | Auto-renewable subscription | Weekly subscription |

#### **Bước 3: Create Entitlement**
(Tab "Entitlements" → Click "New entitlement")

- **Identifier:** `premium`
- **Description:** Full access to premium features
- **Attach products:** Select all 3 products above

#### **Bước 4: Create Offering**
(Tab "Offerings" → Click "New offering")

- **Identifier:** `default`
- **Add 3 packages:**
  1. Package type: **Lifetime** → Product: `lifetime_2050k`
  2. Package type: **Annual** → Product: `yearly_944k`
  3. Package type: **Weekly** → Product: `weekly_165k`

**Verify:**
```
✅ 3 products created
✅ 1 entitlement "premium" with 3 attached products
✅ 1 offering "default" with 3 packages
```

---

## 🛠️ Build APK (Trên máy Local)

### **Prerequisites:**
- ✅ Android Studio hoặc Android SDK installed
- ✅ Flutter SDK installed
- ✅ USB Debugging enabled trên Android device

### **Bước 1: Download Project**

**Option A: Download ZIP từ Replit**
1. Click "..." menu → Download as ZIP
2. Extract ZIP file
3. Open terminal tại thư mục project

**Option B: Clone từ GitHub (nếu anh đã push)**
```bash
git clone <your-repo-url>
cd viso-ai-project
```

### **Bước 2: Install Dependencies**

```bash
# Terminal (tại thư mục project)
flutter pub get
```

Expected output:
```
Running "flutter pub get" in viso-ai-project...
Resolving dependencies... (X.Xs)
Got dependencies!
```

### **Bước 3: Verify Firebase Setup**

```bash
flutter doctor
```

Expected:
```
✓ Flutter (Channel stable, 3.32.0)
✓ Android toolchain - develop for Android devices
✓ Connected device (1 available)  ← Cần có dòng này!
```

### **Bước 4: Build APK Debug**

```bash
# Build debug APK (có debug symbols, faster build)
flutter build apk --debug
```

**Build time:** 3-5 phút (lần đầu có thể lâu hơn)

**Output location:**
```
build/app/outputs/flutter-apk/app-debug.apk
```

**File size:** ~50-70MB

---

## 📱 Install & Test APK

### **A. Install APK lên Device**

**Option 1: Via USB (Khuyến nghị)**
```bash
# Connect device via USB → Enable USB debugging

# Install APK
adb install build/app/outputs/flutter-apk/app-debug.apk

# Or use flutter directly
flutter install
```

**Option 2: Transfer APK file**
1. Copy `app-debug.apk` vào device (via USB/cloud)
2. Open file trên device
3. Allow "Install from unknown sources"
4. Install app

---

### **B. Test Ads Flow**

#### **1. Launch App**
```
Open app → Wait for Firebase Remote Config fetch
```

**Check logs** (nếu connected via USB):
```bash
adb logcat | grep RemoteConfig
```

Expected output:
```
✅ Remote Config initialized
   - ads_enabled: true
   - banner_ads_enabled: true
   - rewarded_ads_enabled: true
   - app_open_ads_enabled: true
```

#### **2. Navigate Pages → Verify Ads Display**

| Page | Ad Type | Expected Behavior |
|------|---------|-------------------|
| **Homepage** | Banner Ad | Shows at bottom navigation |
| **AI Tools** | Banner Ad | Shows at bottom navigation |
| **Face Swap** | Rewarded Ad | Button "Watch ad to unlock" |
| **App Open** | App Open Ad | Shows when app opened |

**Screenshots:**
- ✅ Banner ads visible với AdMob/AppLovin ads
- ✅ Rewarded ad button clickable
- ✅ App open ad shows (nếu enabled)

#### **3. Test Premium Bypass**
```
Navigate to Pro page → Complete purchase (test mode)
  → Navigate back to Homepage
  → ✅ Banner ads KHÔNG hiển thị nữa (premium user)
```

---

### **C. Test IAP Flow**

#### **1. Navigate to Pro Page**
```
Open app → Tap profile icon → Pro page
```

#### **2. Verify Subscription Cards Load**

Expected:
```
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│ BEST VALUE  │  │ SAVE 89%    │  │             │
│     ∞       │  │     📅      │  │     🗓️      │
│  Lifetime   │  │    Year     │  │    Week     │
│  $99.99     │  │   $49.99    │  │   $7.99     │
└─────────────┘  └─────────────┘  └─────────────┘
     ^(selected)
```

**Check:**
- ✅ Loading spinner shows briefly
- ✅ 3 cards render với badges
- ✅ Prices load từ RevenueCat (dynamic)
- ✅ First card (Lifetime) auto-selected

#### **3. Test Purchase Flow (Test Mode)**

```bash
# Tap Continue button
→ Loading dialog: "Processing purchase..."
→ RevenueCat test mode: Mock purchase success
→ SnackBar: "Purchase successful!"
→ Navigate back → Ads disabled (premium user)
```

**Check logs:**
```bash
adb logcat | grep RevenueCat
```

Expected:
```
✅ Loaded 3 subscription packages
Package: Lifetime - $99.99
Package: Yearly - $49.99
Package: Weekly - $7.99
✅ Purchase successful (test mode)
```

#### **4. Test Restore Flow**

```bash
# Tap Restore button
→ RevenueCat restore API called
→ SnackBar: "Purchases restored successfully!" (hoặc "No purchases found")
```

---

## 🐛 Troubleshooting

### **Issue 1: "No subscription packages available"**

**Nguyên nhân:** RevenueCat Dashboard chưa setup đúng

**Fix:**
1. Verify offering identifier = `default` (phải trùng với code)
2. Check 3 packages exist trong offering
3. Verify API key trong `lib/services/revenue_cat_service.dart` (test_OvwtrjRddtWRHgmNdZgxCTiYLYX)

**Logs:**
```bash
adb logcat | grep RevenueCat
# ❌ Error loading packages: ...
```

---

### **Issue 2: "Ads not showing"**

**Nguyên nhân:** Remote Config chưa fetch hoặc AdMob test mode

**Fix:**
1. **Check Remote Config:**
   ```bash
   adb logcat | grep "ads_enabled"
   # Expected: ads_enabled: true
   ```

2. **Enable test ads:**
   - AdMob test ads có thể không show ngay
   - Wait 1-2 minutes sau khi install
   - Test với device đã đăng ký test ads trên AdMob

3. **Check Firebase Console:**
   - Remote Config parameters published?
   - Values = true?

---

### **Issue 3: "Flutter build fails"**

**Nguyên nhân:** Android SDK hoặc dependencies issues

**Fix:**
```bash
# Clean build
flutter clean
flutter pub get

# Check dependencies
flutter doctor -v

# Ensure Android SDK installed
# Android Studio → SDK Manager → Install Android SDK
```

---

### **Issue 4: "Cannot install APK"**

**Nguyên nhân:** Device security settings

**Fix:**
```
Settings → Security → Unknown sources → Enable
Settings → Apps → Special access → Install unknown apps → Allow
```

---

## 📊 Expected Behavior Summary

### **Free User (No IAP):**
- ✅ Ads hiển thị (banner, rewarded, app open)
- ✅ Pro page shows subscription options
- ✅ Remote Config: ads_enabled = true

### **Premium User (After IAP purchase):**
- ✅ Ads KHÔNG hiển thị (auto-bypass)
- ✅ Pro page shows "Already premium" or success
- ✅ Remote Config still returns true, but UserService.isPremiumUser overrides

### **Test Mode (RevenueCat):**
- ✅ Purchases are mocked (không charge tiền)
- ✅ Restore works with mock data
- ✅ Premium status persists after restart

---

## 🔄 Update Workflow

Khi anh muốn test lại sau khi update code:

```bash
# 1. Update code trên Replit
# (Edit files, commit changes)

# 2. Download ZIP hoặc pull từ GitHub
git pull origin main

# 3. Rebuild APK
flutter clean
flutter pub get
flutter build apk --debug

# 4. Reinstall
adb install -r build/app/outputs/flutter-apk/app-debug.apk

# 5. Test lại
```

**Lưu ý:** 
- `-r` flag = reinstall (giữ data cũ)
- Nếu muốn clean install: Uninstall app trước → Install mới

---

## ✅ Success Checklist

### **Firebase Remote Config:**
- [ ] 6 parameters created trong Firebase Console
- [ ] All values = true (ads enabled)
- [ ] Changes published
- [ ] App logs show "ads_enabled: true"

### **RevenueCat IAP:**
- [ ] 3 products created
- [ ] 1 entitlement "premium" with 3 products
- [ ] 1 offering "default" with 3 packages
- [ ] Pro page loads 3 subscription cards
- [ ] Purchase flow works (test mode)
- [ ] Restore flow works

### **APK Build & Install:**
- [ ] APK built successfully (~50-70MB)
- [ ] APK installed on device
- [ ] App launches without crashes
- [ ] Ads display correctly
- [ ] IAP Pro page functional

### **Integration Test:**
- [ ] Free user: Ads show
- [ ] Purchase subscription → Ads disappear
- [ ] Restart app → Premium status persists
- [ ] Restore purchases works

---

## 🚀 Next Steps (Production)

Sau khi test OK, để deploy production:

1. **Google Play Console Setup:**
   - Create app listing
   - Add in-app products (same IDs)
   - Submit for review

2. **Replace Test Keys:**
   ```dart
   // main.dart
   await RevenueCat.configure(
     PurchasesConfiguration("appl_xxxxxxxxxxxxx"), // Production key
   );
   ```

3. **Build Release APK:**
   ```bash
   flutter build appbundle --release
   # Output: build/app/outputs/bundle/release/app-release.aab
   ```

4. **Upload to Play Store:**
   - Internal testing → Closed testing → Production

---

## 📚 Resources

- **Firebase Console:** https://console.firebase.google.com/project/viso-ai-photo-avatar
- **RevenueCat Dashboard:** https://app.revenuecat.com
- **AdMob Console:** https://apps.admob.com
- **AppLovin Dashboard:** https://dash.applovin.com

---

## 💡 Pro Tips

✅ **Test với nhiều scenarios:**
- Fresh install (no cache)
- With/without internet
- Free user vs Premium user
- Different device regions

✅ **Monitor logs real-time:**
```bash
adb logcat | grep -E "RemoteConfig|RevenueCat|AdMob|AppLovin"
```

✅ **Test ads cần thời gian:**
- AdMob test ads có thể không show ngay
- Wait 5-10 minutes sau install
- Try navigate nhiều pages để trigger ads

✅ **RevenueCat test mode FREE:**
- Không charge tiền
- Unlimited mock purchases
- Perfect cho development testing
