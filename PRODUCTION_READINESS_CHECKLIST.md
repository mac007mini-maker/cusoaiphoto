# Production Readiness Checklist - Viso AI
**Before launching to App Store & Google Play**

---

## Table of Contents
1. [Security Checklist](#security-checklist)
2. [Performance & Optimization](#performance--optimization)
3. [Monitoring & Error Tracking](#monitoring--error-tracking)
4. [Backend Production Setup](#backend-production-setup)
5. [App Store Submission (iOS)](#app-store-submission-ios)
6. [Google Play Submission (Android)](#google-play-submission-android)
7. [Launch Day Runbook](#launch-day-runbook)
8. [Post-Launch Monitoring](#post-launch-monitoring)

---

## Security Checklist

### 🔐 Critical Security Items

#### ✅ API Authentication
- [ ] **Backend API requires authentication** (API key hoặc JWT token)
- [ ] API key được lưu trong biến môi trường, KHÔNG hardcode
- [ ] Flutter app gửi API key trong header `X-API-Key`
- [ ] Implement rate limiting (Flask-Limiter) trên tất cả AI endpoints
  - Max 10 requests/minute per IP
  - Max 100 requests/hour per user

**Implementation:**
```python
# api/index.py
from functools import wraps

API_KEY = os.getenv('API_KEY')  # Set on Railway

def require_api_key(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        key = request.headers.get('X-API-Key')
        if not API_KEY or key != API_KEY:
            return jsonify({'error': 'Unauthorized'}), 401
        return f(*args, **kwargs)
    return decorated

@app.route('/api/ai/face-swap-v2', methods=['POST'])
@require_api_key  # Add this decorator
def face_swap_v2():
    ...
```

```dart
// lib/services/huggingface_service.dart
static Future<String> faceSwap(...) async {
  final response = await http.post(
    Uri.parse('$aiBaseUrl/face-swap'),
    headers: {
      'Content-Type': 'application/json',
      'X-API-Key': const String.fromEnvironment('API_KEY'),  // Add this
    },
    body: jsonEncode({...}),
  );
}
```

---

#### ✅ Premium Status Validation
- [ ] **RevenueCat entitlement check** on app launch
- [ ] Premium status synced with server (không chỉ client-side)
- [ ] UserService.isPremiumUser gọi RevenueCat API, không chỉ đọc SharedPreferences

**Fix:**
```dart
// lib/services/user_service.dart
Future<bool> get isPremiumUser async {
  // Always validate with RevenueCat
  return await RevenueCatService().isPremiumUser();
}
```

---

#### ✅ Secrets Management
- [ ] **secrets.env KHÔNG được commit** lên GitHub (check `.gitignore`)
- [ ] Test RevenueCat key KHÔNG còn trong code
- [ ] Supabase Anon Key có Row-Level Security (RLS) enabled
- [ ] Railway environment variables được set đầy đủ

**Verify `.gitignore`:**
```bash
grep -E "(secrets\.env|\.env)" .gitignore
# Phải thấy: secrets.env, *.env
```

---

#### ✅ Input Validation
- [ ] **Validate image size** (max 10MB) trước khi upload
- [ ] Validate base64 format
- [ ] Sanitize user prompts (nếu có text input)
- [ ] Backend validate tất cả input parameters

**Backend validation:**
```python
def validate_image_base64(image_data: str) -> bool:
    if len(image_data) > 14_000_000:  # ~10MB
        raise ValueError('Image too large (max 10MB)')
    
    if not re.match(r'^data:image/(jpeg|png|webp);base64,', image_data):
        raise ValueError('Invalid image format')
    
    return True
```

---

#### ✅ HTTPS Only
- [ ] Railway domain uses HTTPS (mặc định có)
- [ ] CORS configured correctly cho mobile app
- [ ] No mixed content warnings

---

### 🔒 Additional Security Measures

- [ ] **Code obfuscation** khi build release:
```bash
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
```

- [ ] **Proguard enabled** cho Android (đã có trong `android/app/proguard-rules.pro`)
- [ ] **SSL Pinning** (optional, advanced) để prevent man-in-the-middle attacks
- [ ] **Jailbreak/Root detection** (optional) để protect IAP

---

## Performance & Optimization

### 🚀 App Performance

#### ✅ Startup Time
- [ ] App launch < 3 seconds (cold start)
- [ ] Splash screen không quá lâu (1-2s)
- [ ] Core services initialize trong < 5 seconds
- [ ] Timeout added to all service init calls

**Test:**
```bash
flutter run --release --profile
# Use DevTools timeline to measure startup
```

---

#### ✅ Image Processing
- [ ] **Base64 encoding** chạy trên Isolate (không block UI)
- [ ] Image compression trước khi upload (giảm từ 4K → 2K nếu cần)
- [ ] Loading indicators khi xử lý image
- [ ] Cancel button cho long-running operations

**Implement Isolate encoding:**
```dart
import 'dart:isolate';

Future<String> encodeImageAsync(Uint8List bytes) async {
  return await Isolate.run(() => base64Encode(bytes));
}
```

---

#### ✅ Network Optimization
- [ ] Request timeouts configured (30s-120s tùy operation)
- [ ] Retry logic with exponential backoff
- [ ] Caching for templates/images (avoid re-download)
- [ ] Offline mode fallback (show cached content)

---

#### ✅ Memory Management
- [ ] Dispose controllers, listeners properly
- [ ] Image cache size limited
- [ ] No memory leaks (test with DevTools memory profiler)

---

### 🌐 Backend Performance

#### ✅ API Response Times
- [ ] `/health` endpoint < 100ms
- [ ] Template endpoints < 500ms
- [ ] AI endpoints < 60s (with timeout)
- [ ] CDN for static assets (Supabase Storage)

#### ✅ Caching Strategy
- [ ] **Redis or in-memory cache** cho AI results (same image hash → cached result)
- [ ] Template lists cached for 1 hour
- [ ] HTTP caching headers set correctly

**Basic caching:**
```python
from functools import lru_cache
import hashlib

@lru_cache(maxsize=100)
def cache_result(image_hash: str):
    # Cache last 100 AI results
    pass
```

---

#### ✅ Scaling
- [ ] Railway set to auto-scale (multiple instances)
- [ ] Database connection pooling (if using Postgres)
- [ ] Stateless design (no session storage on server)

---

## Monitoring & Error Tracking

### 📊 Crash Reporting

#### ✅ Setup Sentry hoặc Firebase Crashlytics

**Firebase Crashlytics (recommended, free):**
```dart
// pubspec.yaml
dependencies:
  firebase_crashlytics: ^4.1.3

// lib/main.dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Pass all uncaught errors to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  
  await runZonedGuarded(() async {
    await Firebase.initializeApp();
    runApp(MyApp());
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack);
  });
}
```

- [ ] Crashlytics initialized
- [ ] Test crash reporting (force crash in debug mode)
- [ ] Setup alerts for new crashes (email/Slack)

---

### 📈 Analytics

#### ✅ Firebase Analytics (or Mixpanel)

**Track key events:**
- [ ] App launches
- [ ] Screen views (Home, Explore, Pro page, etc.)
- [ ] AI feature usage (face swap, HD enhance, cartoon, etc.)
- [ ] Purchase flow:
  - `paywall_view`
  - `package_selected`
  - `purchase_initiated`
  - `purchase_success` / `purchase_failed`
  - `restore_purchases`
- [ ] Ad impressions/clicks
- [ ] Errors (API failures, timeouts)

**Example:**
```dart
import 'package:firebase_analytics/firebase_analytics.dart';

FirebaseAnalytics.instance.logEvent(
  name: 'ai_feature_used',
  parameters: {
    'feature_type': 'face_swap',
    'provider': 'replicate',
    'success': true,
    'duration_seconds': 12,
  },
);
```

---

### 🔍 Backend Monitoring

#### ✅ Railway Metrics
- [ ] Enable Railway metrics dashboard
- [ ] Monitor CPU/Memory usage
- [ ] Monitor request count, error rate
- [ ] Setup alerts for high error rate (>5%)

#### ✅ Health Checks
- [ ] `/health` endpoint implemented
- [ ] Railway health check configured
- [ ] Health check validates critical dependencies (Supabase, Replicate token)

**Comprehensive health check:**
```python
@app.route('/health', methods=['GET'])
def health_check():
    checks = {
        'api': True,
        'supabase': bool(os.getenv('SUPABASE_URL')),
        'replicate': bool(os.getenv('REPLICATE_API_TOKEN')),
        'huggingface': bool(os.getenv('HUGGINGFACE_TOKEN')),
    }
    
    all_healthy = all(checks.values())
    
    return jsonify({
        'status': 'healthy' if all_healthy else 'degraded',
        'checks': checks,
        'timestamp': time.time(),
        'version': '1.0.0'
    }), 200 if all_healthy else 503
```

---

### 🪵 Logging

- [ ] **Structured logging** (JSON format) for easy parsing
- [ ] Log levels: DEBUG (dev), INFO (prod), ERROR (always)
- [ ] Sensitive data (API keys, user data) KHÔNG được log
- [ ] Railway logs retention configured (7-30 days)

**Python logging:**
```python
import logging

logging.basicConfig(
    level=logging.INFO if os.getenv('APP_ENV') == 'prod' else logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
```

---

## Backend Production Setup

### ✅ Railway Configuration

#### Environment Variables
- [ ] All secrets set in Railway Variables tab:
  - `HUGGINGFACE_TOKEN`
  - `REPLICATE_API_TOKEN`
  - `PIAPI_API_KEY`
  - `KIE_API_KEY` (if using Kie Nano Banana)
  - `SUPABASE_URL`
  - `SUPABASE_ANON_KEY`
  - `API_KEY` (backend auth key)
  - `APP_ENV=prod`

#### Deploy Settings
- [ ] **Branch:** `main`
- [ ] **Auto-deploy:** Enabled
- [ ] **Health check path:** `/health`
- [ ] **Health check timeout:** 300s
- [ ] **Restart policy:** On failure, max 10 retries

#### Domains
- [ ] Custom domain configured (optional): `api.visoai.com`
- [ ] HTTPS enabled (mặc định)
- [ ] CORS configured:
```python
from flask_cors import CORS

CORS(app, origins=[
    'https://your-app-domain.com',
    'http://localhost:*',  # Only for dev
])
```

---

### ✅ Database (Supabase)

- [ ] **Row-Level Security (RLS)** enabled on all tables
- [ ] Anon key chỉ có quyền read public data
- [ ] Service role key KHÔNG bao giờ gửi cho client
- [ ] Backups enabled (Supabase tự động backup)

**Verify RLS:**
```sql
-- Run in Supabase SQL editor
SELECT tablename, rowsecurity FROM pg_tables 
WHERE schemaname = 'public';
```

---

### ✅ Storage (Supabase Storage)

- [ ] Buckets configured: `face-swap-templates`, `video-swap-templates`, `story-templates`
- [ ] Public access cho templates
- [ ] File size limits set (max 10MB per upload)
- [ ] CDN enabled for fast delivery

---

## App Store Submission (iOS)

### ✅ Pre-Submission

#### App Configuration
- [ ] **App name:** Viso AI - Photo Avatar Headshot
- [ ] **Bundle ID:** `com.yourcompany.visoai` (unique)
- [ ] **Version:** `1.0.0` (semantic versioning)
- [ ] **Build number:** Auto-increment mỗi build

#### Xcode Project
- [ ] Signing & Capabilities configured
  - Development team selected
  - Provisioning profile active
  - Push notifications enabled (if needed)
  - In-App Purchase capability enabled
- [ ] `Info.plist` permissions complete:
  - `NSPhotoLibraryUsageDescription`
  - `NSPhotoLibraryAddUsageDescription`
  - `NSCameraUsageDescription`
- [ ] Icons (all sizes) added to `Assets.xcassets`
- [ ] Launch screen configured

---

#### Build & Archive
```bash
# 1. Clean
flutter clean

# 2. Get dependencies
flutter pub get

# 3. Build release
./build_prod_ios.sh

# 4. Open Xcode
open ios/Runner.xcworkspace

# 5. In Xcode:
#    - Select "Any iOS Device" target
#    - Product → Archive
#    - Wait for archive to complete
#    - Window → Organizer → Distribute App
```

---

#### App Store Connect

1. **Create App:**
   - Login: https://appstoreconnect.apple.com/
   - My Apps → + → New App
   - Platform: iOS
   - Name: Viso AI
   - Bundle ID: (select from dropdown)
   - SKU: `visoai-ios`
   - User Access: Full Access

2. **App Information:**
   - [ ] Category: Photo & Video
   - [ ] Subcategory: (optional)
   - [ ] Content Rights: Không chứa third-party content
   - [ ] Age Rating: 4+ (hoặc tùy theo content)

3. **Pricing:**
   - [ ] Free (with in-app purchases)
   - [ ] Available in all countries (hoặc chọn specific)

4. **In-App Purchases:**
   - [ ] Create IAP products (Weekly, Yearly, Lifetime)
   - [ ] Prices set for each region
   - [ ] Reviewed and approved by Apple

5. **Privacy:**
   - [ ] Privacy Policy URL: `https://your-website.com/privacy`
   - [ ] Data collection practices declared:
     - Email (for user account)
     - Photos (for AI processing)
     - Purchase history
     - Usage data (analytics)

6. **App Review Information:**
   - [ ] Demo account (if required): username/password
   - [ ] Notes for reviewer: Explain how to test app
   - [ ] Contact info: Your email, phone

7. **Version Information:**
   - [ ] Screenshots (required):
     - 6.7" Display (iPhone 15 Pro Max): 5-10 screenshots
     - 5.5" Display (iPhone 8 Plus): 5-10 screenshots
   - [ ] App Preview Videos (optional, but recommended)
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
   - [ ] Keywords: `ai, photo, avatar, headshot, face swap, editor`
   - [ ] Support URL: `https://your-website.com/support`
   - [ ] Marketing URL: `https://your-website.com`

8. **Submit for Review:**
   - [ ] Upload build from Xcode Organizer
   - [ ] Select build in App Store Connect
   - [ ] Click "Submit for Review"
   - [ ] Wait 24-48 hours for review

---

## Google Play Submission (Android)

### ✅ Pre-Submission

#### App Configuration
- [ ] **App name:** Viso AI - Photo Avatar Headshot
- [ ] **Package name:** `com.yourcompany.visoai` (must match iOS)
- [ ] **Version name:** `1.0.0`
- [ ] **Version code:** `1` (increment mỗi release)

#### Build Release APK/AAB
```bash
# Build App Bundle (recommended)
./build_prod_android.sh

# Or manual:
flutter build appbundle --release \
  --dart-define=APP_ENV=prod \
  (... other dart-defines ...)

# Output: build/app/outputs/bundle/release/app-release.aab
```

#### Sign APK/AAB
- [ ] **Keystore** đã tạo và lưu an toàn
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
- [ ] `android/key.properties` configured:
```properties
storePassword=your-password
keyPassword=your-password
keyAlias=upload
storeFile=/path/to/upload-keystore.jks
```
- [ ] Keystore backup lưu ở nơi an toàn (mất keystore = không update app được!)

---

#### Google Play Console

1. **Create App:**
   - Login: https://play.google.com/console/
   - All apps → Create app
   - App name: Viso AI
   - Default language: English (US)
   - App or game: App
   - Free or paid: Free
   - Declarations: Accept terms

2. **Store Listing:**
   - [ ] Short description (max 80 chars):
```
AI-powered photo editor: face swap, HD enhance, avatars & more!
```
   - [ ] Full description (max 4000 chars): (Same as iOS)
   - [ ] App icon: 512x512 PNG
   - [ ] Feature graphic: 1024x500 PNG
   - [ ] Screenshots:
     - Phone: Min 2, max 8 (1080x1920 or 1080x2340)
     - Tablet: Optional (min 2)
   - [ ] Category: Photography
   - [ ] Tags: Photo editor, AI, Face swap, Avatar
   - [ ] Contact email: your-email@example.com
   - [ ] Privacy policy: URL

3. **App Content:**
   - [ ] **Privacy Policy:** URL provided
   - [ ] **App access:** Public (no login required) or Requires account
   - [ ] **Ads:** Contains ads? Yes
   - [ ] **Target audience:** Age 13+ (or appropriate)
   - [ ] **Data safety:**
     - What data collected: Photos, Email, Usage data
     - How data used: App functionality, Analytics
     - Data shared: No (or Yes if using third-party analytics)
     - Data security: Encrypted in transit, Can request deletion

4. **Pricing & Distribution:**
   - [ ] Free
   - [ ] Countries: Select all (or specific)
   - [ ] Content rating: Apply for rating (IARC questionnaire)
   - [ ] Government apps: No

5. **In-App Products:**
   - [ ] Create subscriptions (Weekly, Yearly, Lifetime)
   - [ ] Prices set for each country
   - [ ] Base plans configured

6. **Release:**
   - [ ] Production → Create new release
   - [ ] Upload app-release.aab
   - [ ] Release name: `1.0.0`
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
   - [ ] Save → Review release
   - [ ] Start rollout to Production (hoặc beta test first)

---

## Launch Day Runbook

### 🚀 Pre-Launch (Day -1)

- [ ] **Final smoke test:**
  - [ ] Test on real devices (iOS & Android)
  - [ ] Test all AI features (face swap, HD, cartoon, etc.)
  - [ ] Test Nano Banana prompt studio (new KIE integration)
  - [ ] Test IAP purchase flow (sandbox mode)
  - [ ] Test ads (test ads showing correctly)
  - [ ] Test restore purchases

- [ ] **Monitoring setup:**
  - [ ] Crashlytics enabled and tested
  - [ ] Analytics tracking verified
  - [ ] Railway logs accessible
  - [ ] Alert emails/Slack configured

- [ ] **Backend health check:**
  - [ ] All environment variables set
  - [ ] API endpoints responding
  - [ ] `POST /api/kie/nano-banana` returns JSON (200/400) with valid KIE API key
  - [ ] Supabase templates loading
  - [ ] Replicate/PiAPI quotas checked (sufficient credits)

- [ ] **Team readiness:**
  - [ ] Support email monitored (SUPPORT_EMAIL)
  - [ ] On-call person assigned
  - [ ] Rollback procedure documented (see GIT_RAILWAY_DEPLOYMENT_GUIDE.md)

---

### 🎯 Launch Day (Day 0)

#### Morning (Before Release)
- [ ] **Check backend status:**
```bash
curl https://your-railway-domain.up.railway.app/health
# Should return: {"status": "healthy"}
```

- [ ] **Verify Remote Config:**
  - Login Firebase Console
  - Check all ad flags are correct
  - Publish config if needed

#### Release
- [ ] **iOS:** Approved by Apple? Check App Store Connect
- [ ] **Android:** Release rolled out to 100%? Check Play Console

#### Post-Release (First Hour)
- [ ] **Monitor Crashlytics** for crashes (refresh every 5 minutes)
- [ ] **Monitor Railway logs** for backend errors
- [ ] **Monitor Analytics** for user activity:
  - App installs
  - Screen views
  - Feature usage

#### Post-Release (First Day)
- [ ] Check user reviews (respond to negative reviews quickly)
- [ ] Monitor IAP conversion rate
- [ ] Monitor ad revenue (AdMob/AppLovin dashboards)
- [ ] Monitor API costs (Replicate/PiAPI usage)

---

### 🐛 Emergency Procedures

**If critical bug found:**
1. **Hotfix branch:**
```bash
git checkout main
git pull
git checkout -b hotfix/critical-bug-fix
# Fix bug
git commit -m "hotfix: Fix critical crash on startup"
git push origin hotfix/critical-bug-fix
```

2. **Emergency deploy:**
   - Create PR: `hotfix/*` → `main`
   - Merge immediately (skip normal review if critical)
   - Railway auto-deploys
   - Monitor logs

3. **Mobile app hotfix:**
   - If backend only: No action needed (Railway deployed)
   - If app code: Build new version, submit expedited review to Apple (24h), Google (2-4h)

**If backend down:**
1. Check Railway status
2. Check logs for errors
3. Rollback to previous deployment (Railway Deployments → Redeploy)
4. Fix issue on feature branch, test, then deploy

---

## Post-Launch Monitoring

### Week 1
- [ ] Daily crash rate < 0.1%
- [ ] Backend uptime > 99.5%
- [ ] Average API response time < 30s
- [ ] User reviews mostly positive (>4.0 stars)
- [ ] IAP working correctly (no failed purchases)

### Month 1
- [ ] Setup weekly reports (analytics, revenue, crashes)
- [ ] Plan feature updates based on user feedback
- [ ] Optimize costs (Replicate/PiAPI usage)
- [ ] A/B test new features via Remote Config

### Metrics to Track
| Metric | Target | Tools |
|--------|--------|-------|
| Daily Active Users | Growing | Firebase Analytics |
| Crash-free rate | >99.9% | Crashlytics |
| Average session duration | >5 min | Analytics |
| IAP conversion rate | >2% | RevenueCat, Analytics |
| Ad revenue per user | $0.05-0.10 | AdMob, AppLovin |
| API cost per user | <$0.02 | Replicate, PiAPI dashboards |
| Backend uptime | >99.9% | Railway metrics |

---

## Summary Checklist

### Critical (Blocker)
- [ ] API authentication enabled
- [ ] Rate limiting configured
- [ ] Premium status validated via RevenueCat
- [ ] No test keys in production code
- [ ] Health check endpoint working
- [ ] Crashlytics enabled
- [ ] All secrets in Railway Variables, not in code

### High Priority
- [ ] Analytics tracking implemented
- [ ] Base64 encoding on Isolate
- [ ] Input validation on all endpoints
- [ ] Caching implemented for AI results
- [ ] Railway auto-deploy configured
- [ ] Nano Banana prompt studio verified with live KIE API key
- [ ] Store listings complete (screenshots, descriptions)

### Nice to Have
- [ ] A/B testing framework ready
- [ ] CI/CD pipeline (GitHub Actions)
- [ ] Custom domain for API
- [ ] App preview videos
- [ ] Beta testing program

---

**Estimated Timeline:**
- Security fixes: 2-3 days
- Performance optimizations: 2-3 days
- Monitoring setup: 1 day
- Store submission prep: 2-3 days
- Review time: iOS (1-2 days), Android (few hours)

**Total: 1-2 weeks to production-ready**

---

**Next:** `AB_TESTING_UIUX_RECOMMENDATIONS.md`

