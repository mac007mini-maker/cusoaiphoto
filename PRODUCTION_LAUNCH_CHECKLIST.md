# 🚀 Production Launch Checklist - Ready to Use
**Last Updated:** October 30, 2025  
**For:** Viso AI - Flutter App + Railway Backend

---

## 📋 How to Use This Checklist

1. **Print this checklist** hoặc mở trên iPad/second screen khi làm
2. **Tick off từng checkbox** ✅ khi hoàn thành
3. **Không skip bước nào** - tất cả đều quan trọng!
4. **Test sau mỗi phần** trước khi tiếp tục

---

## ⏰ Timeline Overview

```
Week 1: Security & Config        [Days 1-3]
Week 2: Store Setup & Build      [Days 4-7]
Week 3: Testing & Submission    [Days 8-14]
Week 4: Launch & Monitor        [Days 15-21]
```

---

## 🔐 Phase 1: Security & Configuration (CRITICAL - Days 1-3)

### ✅ Backend Security

- [ ] **Add API Authentication to Backend**
  - [ ] Edit `api/index.py` - Add `require_api_key` decorator to all AI endpoints
  - [ ] Generate API key: `openssl rand -hex 32`
  - [ ] Add `API_KEY` to Railway Variables
  - [ ] Test: `curl -H "X-API-Key: YOUR_KEY" https://your-domain/api/ai/face-swap-v2`
  - [ ] Verify: Request without key returns 401

- [ ] **Add Rate Limiting**
  - [ ] Install Flask-Limiter: `pip install flask-limiter`
  - [ ] Add to `api/index.py`: `limiter = Limiter(...)`
  - [ ] Apply `@limiter.limit("10 per minute")` to expensive endpoints
  - [ ] Test: Spam requests → should get 429 after 10 requests

- [ ] **Add Health Check Endpoint**
  - [ ] Add `/health` route in `api/index.py`
  - [ ] Returns `{"status": "healthy", "timestamp": ...}`
  - [ ] Test: `curl https://your-domain/health`
  - [ ] Configure Railway health check path: `/health`

- [ ] **Verify Environment Variables on Railway**
  - [ ] `HUGGINGFACE_TOKEN` ✅
  - [ ] `REPLICATE_API_TOKEN` ✅
  - [ ] `PIAPI_API_KEY` ✅ (if using)
  - [ ] `SUPABASE_URL` ✅
  - [ ] `SUPABASE_ANON_KEY` ✅
  - [ ] `API_KEY` ✅ (NEW - backend auth)
  - [ ] `KIE_API_KEY` ✅ (if using Nano Banana)

---

### ✅ Flutter App Security

- [ ] **Fix Premium Status Validation**
  - [ ] Edit `lib/services/user_service.dart`
  - [ ] Change `isPremiumUser` to async, call `RevenueCatService().isPremiumUser()`
  - [ ] Test: Purchase premium → verify status syncs immediately

- [ ] **Remove Test RevenueCat Key Fallback**
  - [ ] Edit `lib/services/revenue_cat_service.dart`
  - [ ] Change `defaultValue: _testApiKey` → `defaultValue: ''`
  - [ ] Add check: `if (apiKey.isEmpty) throw Exception(...)`
  - [ ] Verify: App fails fast if key not configured

- [ ] **Verify `.gitignore`**
  - [ ] `secrets.env` is in `.gitignore` ✅
  - [ ] `*.env` is in `.gitignore` ✅
  - [ ] Test: `git status` → should NOT show `secrets.env`

- [ ] **Add Timeout to Service Initialization**
  - [ ] Edit `lib/main.dart`
  - [ ] Add `.timeout(Duration(seconds: 15))` to `Future.wait([...])`
  - [ ] Test: Disconnect internet → app should still load (use defaults)

- [ ] **Add Error Handling to Ad Initialization**
  - [ ] Edit `lib/main.dart` → `_initializeAdsInBackground()`
  - [ ] Wrap in `try-catch` block
  - [ ] Log errors to Crashlytics/Firebase
  - [ ] Test: App should not crash if ads fail to init

---

## 🏗️ Phase 2: Store Accounts & Setup (Days 4-7)

### ✅ Apple App Store Connect

- [ ] **Create Apple Developer Account**
  - [ ] Paid membership ($99/year) ✅
  - [ ] Verify email & complete setup ✅

- [ ] **Create App in App Store Connect**
  - [ ] Login: https://appstoreconnect.apple.com/
  - [ ] My Apps → + → New App
  - [ ] Bundle ID: `com.yourcompany.visoai` (match Xcode)
  - [ ] Name: "Viso AI"
  - [ ] Primary Language: English
  - [ ] SKU: `visoai-ios-001`
  - [ ] User Access: Full Access

- [ ] **App Information**
  - [ ] Category: Photo & Video
  - [ ] Subcategory: (optional)
  - [ ] Content Rights: No third-party content
  - [ ] Age Rating: Complete questionnaire → 4+ or appropriate

- [ ] **Pricing & Availability**
  - [ ] Price: Free (with in-app purchases)
  - [ ] Available in: All countries (or selected)

- [ ] **In-App Purchases**
  - [ ] Create Subscription Products:
    - [ ] Weekly Subscription ($4.99/week)
    - [ ] Yearly Subscription ($49.99/year)
    - [ ] Lifetime Purchase ($99.99 one-time)
  - [ ] Set prices for all regions
  - [ ] Submit for review
  - [ ] Wait for approval (usually instant for IAP)

- [ ] **Privacy Policy**
  - [ ] Create privacy policy page: `https://your-website.com/privacy`
  - [ ] Add URL to App Store Connect
  - [ ] Declare data collection:
    - [ ] Photos (for AI processing)
    - [ ] Email (for account)
    - [ ] Purchase history
    - [ ] Usage data (analytics)

- [ ] **App Preview & Screenshots**
  - [ ] 6.7" Display (iPhone 15 Pro Max):
    - [ ] Screenshot 1: Home screen
    - [ ] Screenshot 2: Template selection
    - [ ] Screenshot 3: Result preview
    - [ ] Screenshot 4: Paywall
    - [ ] Screenshot 5: (optional) Settings
  - [ ] 5.5" Display (iPhone 8 Plus):
    - [ ] Same screenshots as above
  - [ ] App Preview Video (optional but recommended)

- [ ] **App Store Listing**
  - [ ] Description (max 4000 chars):
    ```
    Transform your photos with AI magic!

    Viso AI uses cutting-edge artificial intelligence to:
    • Swap faces seamlessly
    • Enhance images to HD quality
    • Create stunning avatars and headshots
    • Apply cartoon & art style filters
    • Generate professional portraits

    Features:
    ✓ 50+ AI-powered templates
    ✓ One-tap face swap
    ✓ HD image enhancement
    ✓ Video face swap
    ✓ Ad-free premium experience

    Perfect for:
    • Social media profile pictures
    • Professional headshots
    • Creative photo editing
    • Fun with friends and family

    Download now and unlock your creativity!
    ```
  - [ ] Keywords: `ai, photo, avatar, headshot, face swap, editor, transform`
  - [ ] Support URL: `https://your-website.com/support`
  - [ ] Marketing URL: `https://your-website.com`

---

### ✅ Google Play Console

- [ ] **Create Google Play Developer Account**
  - [ ] One-time fee: $25 ✅
  - [ ] Verify email & complete setup ✅

- [ ] **Create App in Play Console**
  - [ ] Login: https://play.google.com/console/
  - [ ] All apps → Create app
  - [ ] App name: "Viso AI"
  - [ ] Default language: English (US)
  - [ ] App or game: App
  - [ ] Free or paid: Free
  - [ ] Declarations: Accept terms

- [ ] **Store Listing**
  - [ ] Short description (max 80 chars):
    ```
    AI-powered photo editor: face swap, HD enhance, avatars & more!
    ```
  - [ ] Full description (max 4000 chars): (Same as iOS)
  - [ ] App icon: 512x512 PNG (no transparency)
  - [ ] Feature graphic: 1024x500 PNG
  - [ ] Screenshots:
    - [ ] Phone: Min 2, max 8 (1080x1920 or 1080x2340)
    - [ ] Tablet: Optional (min 2 if providing)
  - [ ] Category: Photography
  - [ ] Tags: Photo editor, AI, Face swap, Avatar
  - [ ] Contact email: your-email@example.com
  - [ ] Privacy policy: URL

- [ ] **App Content**
  - [ ] Privacy Policy: URL provided ✅
  - [ ] App access: Public (no login required) or Requires account
  - [ ] Ads: Contains ads? Yes ✅
  - [ ] Target audience: Age 13+ (or appropriate)
  - [ ] Data safety:
    - [ ] What data collected: Photos, Email, Usage data
    - [ ] How data used: App functionality, Analytics
    - [ ] Data shared: No (or Yes if using third-party analytics)
    - [ ] Data security: Encrypted in transit, Can request deletion

- [ ] **Pricing & Distribution**
  - [ ] Free ✅
  - [ ] Countries: Select all (or specific)
  - [ ] Content rating: Complete IARC questionnaire
  - [ ] Government apps: No

- [ ] **In-App Products**
  - [ ] Create subscriptions:
    - [ ] Weekly Subscription (Base plan)
    - [ ] Yearly Subscription (Base plan)
    - [ ] Lifetime Purchase (One-time product)
  - [ ] Set prices for each country
  - [ ] Link to RevenueCat (if using)

---

### ✅ RevenueCat Production Setup

- [ ] **Create Production Project**
  - [ ] Login: https://app.revenuecat.com/
  - [ ] Create new project OR use existing
  - [ ] Name: "Viso AI Production"

- [ ] **Add Apps**
  - [ ] iOS App:
    - [ ] Bundle ID: `com.yourcompany.visoai`
    - [ ] App Store Connect API Key (or manual)
    - [ ] Copy iOS API Key → Save to `secrets.env` as `REVENUECAT_IOS_KEY`
  - [ ] Android App:
    - [ ] Package name: `com.yourcompany.visoai`
    - [ ] Google Play API access
    - [ ] Copy Android API Key → Save to `secrets.env` as `REVENUECAT_ANDROID_KEY`

- [ ] **Configure Products**
  - [ ] Create Entitlement: "pro"
  - [ ] Add Products:
    - [ ] Weekly Subscription → Link to App Store/Play Store product ID
    - [ ] Yearly Subscription → Link to App Store/Play Store product ID
    - [ ] Lifetime Purchase → Link to App Store/Play Store product ID
  - [ ] Set all products to "pro" entitlement

- [ ] **Create Offerings**
  - [ ] Create Offering: "default"
  - [ ] Add all packages (Weekly, Yearly, Lifetime)
  - [ ] Set as current offering

- [ ] **Verify Setup**
  - [ ] Test on TestFlight (iOS) / Internal Test (Android)
  - [ ] Purchase should work → Verify entitlement active
  - [ ] Restore purchases should work

---

## 🔨 Phase 3: Build & Test (Days 8-10)

### ✅ Production Build Preparation

- [ ] **Update `secrets.env` with Production Values**
  ```bash
  export APP_ENV="prod"
  export API_DOMAIN="web-production-a7698.up.railway.app"
  export REVENUECAT_IOS_KEY="appl_xxxxxxxx"  # REAL production key
  export REVENUECAT_ANDROID_KEY="proj_xxxxxxxx"  # REAL production key
  export ADMOB_APP_ID_IOS="ca-app-pub-xxxxx~xxxxx"  # REAL ad IDs
  export ADMOB_APP_ID_ANDROID="ca-app-pub-xxxxx~xxxxx"
  # ... all other REAL values
  ```

- [ ] **Update Code for Production**
  - [ ] Remove all `print()` debug statements OR wrap in `if (kDebugMode)`
  - [ ] Set `APP_ENV` to `prod` in build scripts
  - [ ] Verify no test keys hardcoded
  - [ ] Review all `String.fromEnvironment` defaults → should be safe/empty

- [ ] **iOS Build**
  - [ ] Run: `./build_prod_ios.sh` (or manually)
  - [ ] Verify: Build succeeds ✅
  - [ ] Open Xcode: `open ios/Runner.xcworkspace`
  - [ ] Select "Any iOS Device" target
  - [ ] Product → Archive
  - [ ] Wait for archive to complete
  - [ ] Window → Organizer → Distribute App
  - [ ] Method: App Store Connect
  - [ ] Upload → Wait for processing

- [ ] **Android Build**
  - [ ] Run: `./build_prod_android.sh`
  - [ ] Verify: Build succeeds ✅
  - [ ] Output: `build/app/outputs/bundle/release/app-release.aab`
  - [ ] Sign AAB with production keystore ✅
  - [ ] Upload to Play Console → Production → Create new release

---

### ✅ Testing Checklist

- [ ] **Test on Real Devices**
  - [ ] iOS (iPhone, iOS 15+):
    - [ ] App launches successfully
    - [ ] All screens load
    - [ ] Face swap works
    - [ ] HD enhance works
    - [ ] Templates load from Supabase
    - [ ] Ads show (if free user)
    - [ ] IAP purchase flow works
    - [ ] Restore purchases works
    - [ ] No crashes
  - [ ] Android (various devices):
    - [ ] Same tests as iOS

- [ ] **Test Backend API**
  - [ ] Health check: `curl https://your-domain/health` → 200 OK
  - [ ] Face swap endpoint: Works with API key ✅
  - [ ] Rate limiting: Blocked after 10 requests ✅
  - [ ] All endpoints respond correctly

- [ ] **Test IAP Flow**
  - [ ] TestFlight (iOS):
    - [ ] Install app from TestFlight
    - [ ] Click "Subscribe" → Paywall shows
    - [ ] Purchase weekly subscription → Success ✅
    - [ ] Verify premium features unlocked
    - [ ] Cancel subscription (in App Store Settings)
    - [ ] Restore purchases → Should restore
  - [ ] Internal Test (Android):
    - [ ] Same tests as iOS

- [ ] **Test Error Scenarios**
  - [ ] No internet → App shows offline message
  - [ ] Backend down → Health check fails, app handles gracefully
  - [ ] Invalid API response → No crash, shows error message
  - [ ] Large image upload → Compressed or rejected properly

- [ ] **Performance Test**
  - [ ] App startup < 3 seconds ✅
  - [ ] Templates load < 2 seconds ✅
  - [ ] AI processing shows progress ✅
  - [ ] No memory leaks (use DevTools Memory Profiler)

---

## 📤 Phase 4: Store Submission (Days 11-14)

### ✅ iOS App Store Submission

- [ ] **Final Checks Before Submit**
  - [ ] All screenshots uploaded ✅
  - [ ] Description complete ✅
  - [ ] Privacy policy URL working ✅
  - [ ] Support URL working ✅
  - [ ] App version: 1.0.0 ✅
  - [ ] Build number: 1 ✅
  - [ ] IAP products approved ✅

- [ ] **Submit for Review**
  - [ ] App Store Connect → App → Version
  - [ ] Select build (uploaded from Xcode)
  - [ ] Review all information
  - [ ] Click "Submit for Review"
  - [ ] Wait for review (24-48 hours typical)

- [ ] **Handle Review Feedback**
  - [ ] Check email for review status
  - [ ] If rejected:
    - [ ] Read rejection reason carefully
    - [ ] Fix issues
    - [ ] Resubmit
  - [ ] If approved:
    - [ ] App appears in App Store
    - [ ] Set release date (immediate or scheduled)

---

### ✅ Google Play Submission

- [ ] **Final Checks Before Submit**
  - [ ] All screenshots uploaded ✅
  - [ ] Description complete ✅
  - [ ] Privacy policy URL working ✅
  - [ ] Data safety form complete ✅
  - [ ] Content rating approved ✅
  - [ ] App version: 1.0.0 ✅
  - [ ] Version code: 1 ✅
  - [ ] IAP products configured ✅

- [ ] **Create Production Release**
  - [ ] Play Console → App → Production
  - [ ] Create new release
  - [ ] Upload AAB file
  - [ ] Release name: "1.0.0"
  - [ ] Release notes:
    ```
    Initial release of Viso AI!

    ✨ Features:
    • 50+ AI-powered templates
    • Face swap
    • HD image enhancement
    • Video face swap
    • Premium subscription

    🎨 Transform your photos with AI magic!
    ```
  - [ ] Review release
  - [ ] Start rollout to Production (100% or gradual)

- [ ] **Handle Review Feedback**
  - [ ] Play Console → Policy status
  - [ ] If rejected:
    - [ ] Read rejection reason
    - [ ] Fix issues
    - [ ] Resubmit
  - [ ] If approved:
    - [ ] App appears in Play Store
    - [ ] Monitor for crashes/errors

---

## 🚀 Phase 5: Launch Day (Day 15)

### ✅ Pre-Launch Checklist (Morning of Launch)

- [ ] **Backend Health Check**
  - [ ] `curl https://your-domain/health` → 200 OK ✅
  - [ ] Check Railway logs → No errors ✅
  - [ ] Verify all environment variables set ✅
  - [ ] Test one AI endpoint manually ✅

- [ ] **Remote Config**
  - [ ] Login Firebase Console
  - [ ] Verify all ad flags correct ✅
  - [ ] Publish config if changes made ✅
  - [ ] Test: App fetches config correctly ✅

- [ ] **Monitor Setup**
  - [ ] Crashlytics enabled ✅
  - [ ] Firebase Analytics enabled ✅
  - [ ] Alert emails configured ✅
  - [ ] Railway alerts configured ✅

- [ ] **Team Ready**
  - [ ] Support email monitored ✅
  - [ ] On-call person assigned ✅
  - [ ] Rollback procedure documented ✅

---

### ✅ Launch (Afternoon)

- [ ] **Release Apps**
  - [ ] iOS: App Store Connect → Release to App Store ✅
  - [ ] Android: Play Console → Release (if not auto) ✅

- [ ] **Monitor First Hour**
  - [ ] Check Crashlytics every 5 minutes
  - [ ] Check Railway logs for errors
  - [ ] Check Analytics for user activity
  - [ ] Response time for any issues

---

### ✅ Post-Launch (First Day)

- [ ] **Monitor Metrics**
  - [ ] Crash-free rate: Should be >99.9% ✅
  - [ ] Backend uptime: Should be >99% ✅
  - [ ] API response times: <30s average ✅
  - [ ] User installs: Track numbers

- [ ] **Check Reviews**
  - [ ] iOS: App Store Connect → Reviews
  - [ ] Android: Play Console → Reviews
  - [ ] Respond to negative reviews quickly
  - [ ] Thank positive reviews

- [ ] **Monitor Revenue**
  - [ ] RevenueCat dashboard → Check purchases
  - [ ] AdMob dashboard → Check ad revenue
  - [ ] Verify IAP working correctly

- [ ] **Monitor Costs**
  - [ ] Railway dashboard → Check API usage
  - [ ] Replicate dashboard → Check API costs
  - [ ] PiAPI dashboard → Check costs
  - [ ] Verify costs within budget

---

## 📊 Phase 6: Post-Launch Monitoring (Days 16-21)

### ✅ Week 1 Monitoring

- [ ] **Daily Checks**
  - [ ] Crash rate < 0.1% ✅
  - [ ] Backend uptime > 99.5% ✅
  - [ ] Response to user reviews
  - [ ] Monitor API costs

- [ ] **Weekly Report**
  - [ ] Total installs
  - [ ] Daily Active Users
  - [ ] IAP conversion rate
  - [ ] Ad revenue
  - [ ] API costs
  - [ ] Top crashes (if any)
  - [ ] User feedback summary

---

### ✅ Metrics to Track

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Daily Active Users | Growing | ___ | ⬜ |
| Crash-free rate | >99.9% | ___% | ⬜ |
| Average session duration | >5 min | ___ min | ⬜ |
| IAP conversion rate | >2% | ___% | ⬜ |
| Ad revenue per user | $0.05-0.10 | $___ | ⬜ |
| API cost per user | <$0.02 | $___ | ⬜ |
| Backend uptime | >99.9% | ___% | ⬜ |

---

## 🛟 Emergency Rollback Plan

### If Critical Bug Found

1. **Immediate Action (5 minutes)**
   - [ ] Railway Dashboard → Deployments → Find last stable version
   - [ ] Click "Redeploy" → Wait 1-2 minutes
   - [ ] Verify: Backend working again ✅

2. **Fix Bug (1-2 hours)**
   - [ ] Create hotfix branch: `git checkout -b hotfix/critical-bug`
   - [ ] Fix bug
   - [ ] Test locally
   - [ ] Commit: `git commit -m "hotfix: Fix critical bug"`
   - [ ] Push: `git push origin hotfix/critical-bug`
   - [ ] Create PR → Merge immediately

3. **Deploy Fix**
   - [ ] Railway auto-deploys from `main` branch
   - [ ] Verify fix working ✅

4. **App Update (if needed)**
   - [ ] If bug in app code:
     - [ ] Build new version
     - [ ] Submit expedited review (Apple: 24h, Google: 2-4h)
     - [ ] Or use hotfix via Remote Config (if possible)

---

## ✅ Final Checklist Before Launch

- [ ] All Phase 1 items completed ✅
- [ ] All Phase 2 items completed ✅
- [ ] All Phase 3 items completed ✅
- [ ] All Phase 4 items completed ✅
- [ ] Apps submitted and approved ✅
- [ ] Launch day checklist ready ✅
- [ ] Rollback plan ready ✅
- [ ] Monitoring setup complete ✅

---

## 📝 Notes Section

**Use this space to jot down important notes during preparation:**

- 
- 
- 
- 

---

**Good luck with your launch! 🚀**

*Remember: Launch day is just the beginning. Monitor closely, iterate based on user feedback, and improve continuously.*

