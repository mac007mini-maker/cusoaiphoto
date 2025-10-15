# 🔐 Bảo Mật Secrets & Remote Control Ads Guide

## ⚠️ SỰ THẬT VỀ BẢO MẬT API KEYS TRONG APP

### 🚨 **CÂU TRẢ LỜI NGẮN GỌN:**

**CÓ, secrets trong `prod.json` vẫn có thể bị extract ra được ngay cả khi dùng `--dart-define` và `--obfuscate`!**

---

## 📱 PHẦN 1: BẢO MẬT SECRETS - SỰ THẬT CẦN BIẾT

### ❌ **Những Gì KHÔNG An Toàn:**

#### 1. **--dart-define KHÔNG bảo mật 100%**
```bash
# Dù build với obfuscate...
flutter build appbundle --obfuscate --dart-define-from-file=prod.json

# Hacker vẫn extract được bằng:
apktool d app-release.apk
strings lib/arm64-v8a/libapp.so | grep -i "api\|token\|key"
```

**Kết quả:** API keys của anh sẽ hiện ra như này:
```
hf_abcdefghijklmnopqrstuvwxyz12345
r8_zyxwvutsrqponmlkjihgfedcba54321
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### 2. **Obfuscation chỉ là "che mờ", không phải "mã hóa"**
- `--obfuscate` chỉ rename class/function names
- String literals (API keys) vẫn nguyên văn trong binary
- Tools như `reFlutter`, `darter` dễ dàng extract

#### 3. **Debug APK nguy hiểm HƠN NỮA**
- File `kernel_blob.bin` chứa source code nguyên bản (kể cả comments!)
- Extract bằng: `strings kernel_blob.bin > code.dart`

---

### ✅ **GiẢI PHÁP AN TOÀN:**

## 🔑 **Phân Loại Secrets:**

### **1. Ad Unit IDs (AdMob, AppLovin) - KHÔNG NGUY HIỂM**
```json
{
  "ADMOB_APP_ID_ANDROID": "ca-app-pub-XXXXXXXX~XXXXXXXXXX",
  "ADMOB_REWARDED_AD_UNIT_ID": "ca-app-pub-XXXXXXXX/XXXXXXXXXX",
  "APPLOVIN_SDK_KEY": "xxxxxxxxxxxxxxxxxxxxxxx"
}
```

**✅ AN TOÀN để embed trong app:**
- Ad IDs được **design để public** (phải khai báo trong AndroidManifest.xml/Info.plist)
- Hacker biết cũng không làm gì được (không charge tiền anh)
- Chỉ hoạt động với package name/bundle ID của app anh

### **2. API Tokens (Replicate, Huggingface) - NGUY HIỂM!!!**
```json
{
  "REPLICATE_API_TOKEN": "r8_xxxxx",  // ❌ NGUY HIỂM
  "HUGGINGFACE_TOKEN": "hf_xxxxx"     // ❌ NGUY HIỂM
}
```

**❌ KHÔNG AN TOÀN vì:**
- Hacker extract được → Dùng API với token của anh
- Replicate charge **$0.0019/lần** → Hacker chạy 10,000 lần = **$19**
- Huggingface Pro **$9/tháng** → Hacker dùng miễn phí

---

## 🛡️ **GIẢI PHÁP BẢO MẬT CHO PRODUCTION:**

### **Option 1: Backend Proxy (KHUYẾN NGHỊ)**

**Architecture:**
```
Flutter App            Backend Server           AI Services
   │                        │                        │
   │  1. Request HD photo   │                        │
   ├──────────────────────>│                        │
   │                        │  2. Call Replicate    │
   │                        │   (with server token)  │
   │                        ├──────────────────────>│
   │                        │<───────────────────────│
   │  3. Return result      │                        │
   │<──────────────────────│                        │
```

**Implementation:**

**Backend (Python Flask - Đã có `api_server.py`):**
```python
# api_server.py (đã có sẵn)
@app.route('/api/ai/hd-image', methods=['POST'])
def handle_hd_image():
    # Token stored on SERVER, not in app
    REPLICATE_TOKEN = os.getenv('REPLICATE_API_TOKEN')
    
    # Process request
    image_data = request.json['image']
    result = replicate_api.upscale(image_data, token=REPLICATE_TOKEN)
    
    return jsonify(result)
```

**Flutter (Không cần Replicate token):**
```dart
// Chỉ cần gọi backend
final response = await http.post(
  Uri.parse('https://your-backend.com/api/ai/hd-image'),
  body: jsonEncode({'image': base64Image}),
);
```

**✅ Ưu điểm:**
- Token KHÔNG bao giờ có trong app
- Hacker decompile cũng vô ích
- Control được rate limiting, usage tracking

---

### **Option 2: Supabase Edge Functions (Alternative)**

```typescript
// Supabase Edge Function
import { serve } from "https://deno.land/std/http/server.ts";

serve(async (req) => {
  const { image } = await req.json();
  
  // Token stored in Supabase secrets
  const REPLICATE_TOKEN = Deno.env.get("REPLICATE_API_TOKEN");
  
  const response = await fetch("https://api.replicate.com/v1/predictions", {
    headers: { Authorization: `Token ${REPLICATE_TOKEN}` },
    body: JSON.stringify({ input: { image } })
  });
  
  return new Response(await response.text());
});
```

---

## 📱 PHẦN 2: REMOTE CONTROL ADS (BẬT/TẮT TỪ XA)

### ✅ **CÂU TRẢ LỜI: HOÀN TOÀN HỢP LỆ!**

**Google AdMob chính thức hỗ trợ và KHUYẾN KHÍCH dùng Firebase Remote Config để control ads!**

---

## 🔥 **Firebase Remote Config Solution (KHUYẾN NGHỊ)**

### **Tại Sao Dùng Firebase Remote Config?**

✅ **Policy-compliant**: Google có tutorial chính thức về việc này  
✅ **Real-time updates**: Thay đổi ngay lập tức, không cần update app  
✅ **Free tier**: 2,000 active users miễn phí  
✅ **A/B testing**: Test revenue với/không ads  
✅ **Targeting**: Bật ads theo country, version, user segment  

**⚠️ Use Case Của Anh:**
- Lúc đầu: `show_ads = false` → 0-5k users không thấy ads
- Sau đó: `show_ads = true` → 5k-10k users bắt đầu thấy ads
- Premium users: `show_ads = false` → Paid users không ads

---

### **🚀 Implementation Chi Tiết:**

#### **Bước 1: Setup Firebase (Nếu chưa có)**

```bash
# Add Firebase dependencies
flutter pub add firebase_core
flutter pub add firebase_remote_config
flutter pub add firebase_analytics  # Cần cho targeting
```

**Setup Firebase:**
1. Vào [Firebase Console](https://console.firebase.google.com)
2. Create project hoặc dùng project hiện tại
3. Add Android app (package: `com.visoai.photoheadshot`)
4. Add iOS app (bundle: `com.visoai.photoheadshot`)
5. Download `google-services.json` (Android) và `GoogleService-Info.plist` (iOS)

#### **Bước 2: Create Remote Config Parameters**

**Firebase Console → Engage → Remote Config:**

Tạo các parameters:
```json
{
  "ads_enabled": true,              // Bật/tắt toàn bộ ads
  "banner_ads_enabled": true,       // Bật/tắt banner ads
  "rewarded_ads_enabled": true,     // Bật/tắt rewarded ads
  "interstitial_ads_enabled": true, // Bật/tắt interstitial ads
  "min_user_count_for_ads": 5000    // Chỉ show ads khi ≥ 5k users
}
```

**Add Conditions (Optional):**
- Country: `ads_enabled = false` cho Vietnam (marketing phase)
- User Property: `ads_enabled = false` cho premium users
- App Version: `ads_enabled = true` chỉ từ version 1.2.0+

#### **Bước 3: Flutter Code Implementation**

**Create `lib/services/remote_config_service.dart`:**

```dart
import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  // Ad control flags
  bool get adsEnabled => _remoteConfig.getBool('ads_enabled');
  bool get bannerAdsEnabled => _remoteConfig.getBool('banner_ads_enabled');
  bool get rewardedAdsEnabled => _remoteConfig.getBool('rewarded_ads_enabled');
  bool get interstitialAdsEnabled => _remoteConfig.getBool('interstitial_ads_enabled');
  int get minUserCountForAds => _remoteConfig.getInt('min_user_count_for_ads');

  Future<void> initialize() async {
    try {
      // Set defaults (khi offline hoặc fetch fail)
      await _remoteConfig.setDefaults({
        'ads_enabled': false,  // Default: KHÔNG show ads (an toàn)
        'banner_ads_enabled': false,
        'rewarded_ads_enabled': false,
        'interstitial_ads_enabled': false,
        'min_user_count_for_ads': 5000,
      });

      // Config settings
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1), // Production: 12 hours
      ));

      // Fetch and activate
      await _remoteConfig.fetchAndActivate();
      
      print('✅ Remote Config initialized');
      print('Ads enabled: $adsEnabled');
    } catch (e) {
      print('❌ Remote Config error: $e');
      // Fallback to defaults
    }
  }

  // Refresh config (gọi khi app resume từ background)
  Future<void> refresh() async {
    await _remoteConfig.fetchAndActivate();
  }
}
```

**Update `main.dart`:**

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Remote Config
  await RemoteConfigService().initialize();
  
  // Initialize ads ONLY if enabled
  if (RemoteConfigService().adsEnabled) {
    await initializeAds();  // Hàm init AdMob/AppLovin
  }
  
  runApp(MyApp());
}
```

**Update Ad Widgets:**

```dart
// lib/components/bottom_navigation_with_ad.dart
Widget build(BuildContext context) {
  final remoteConfig = RemoteConfigService();
  
  return Column(
    children: [
      // Show ad banner ONLY if enabled
      if (remoteConfig.adsEnabled && remoteConfig.bannerAdsEnabled)
        Container(
          height: 50,
          color: Colors.black,
          child: AdWidget(ad: bannerAd),
        )
      else
        SizedBox.shrink(), // Không show gì
      
      // Bottom navigation
      BottomNavigationBar(...),
    ],
  );
}
```

**Rewarded Ads:**

```dart
void showRewardedAd() {
  final remoteConfig = RemoteConfigService();
  
  // Check remote config trước
  if (!remoteConfig.adsEnabled || !remoteConfig.rewardedAdsEnabled) {
    // Không có ads → cho user dùng feature luôn
    proceedWithFeature();
    return;
  }
  
  // Show rewarded ad
  rewardedAd?.show(
    onUserEarnedReward: (ad, reward) {
      proceedWithFeature();
    },
  );
}
```

---

## 🎯 **Use Case Thực Tế Của Anh:**

### **Giai Đoạn 1: Marketing (0-5k users)**

**Firebase Console:**
```json
{
  "ads_enabled": false,
  "min_user_count_for_ads": 5000
}
```

**Kết quả:**
- ✅ User download app → Không thấy ads
- ✅ Trải nghiệm mượt mà → Retention cao
- ✅ Word-of-mouth marketing tốt

### **Giai Đoạn 2: Monetization (5k-10k users)**

**Firebase Console (chỉ cần click toggle):**
```json
{
  "ads_enabled": true,  // ← Chỉ cần đổi true
  "banner_ads_enabled": true,
  "rewarded_ads_enabled": true
}
```

**Kết quả:**
- ✅ Ads bật ngay lập tức (không cần update app)
- ✅ User hiện tại: Bắt đầu thấy ads
- ✅ User mới: Thấy ads ngay từ đầu

### **Giai Đoạn 3: Premium Users**

**Add condition targeting:**
- User Property: `is_premium = true`
- Parameter value: `ads_enabled = false`

**Hoặc dùng code:**
```dart
bool shouldShowAds() {
  final remoteConfig = RemoteConfigService();
  final userService = UserService();
  
  // Premium users: KHÔNG ads
  if (userService.isPremiumUser) return false;
  
  // Check remote config
  return remoteConfig.adsEnabled;
}
```

---

## 📊 **Alternative: Supabase Remote Config (Nếu không muốn dùng Firebase)**

### **Setup Table:**

```sql
CREATE TABLE app_config (
  id INT PRIMARY KEY,
  ads_enabled BOOLEAN DEFAULT false,
  banner_ads_enabled BOOLEAN DEFAULT false,
  rewarded_ads_enabled BOOLEAN DEFAULT false,
  min_user_count INT DEFAULT 5000,
  updated_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO app_config (id, ads_enabled) VALUES (1, false);
```

### **Flutter Code:**

```dart
class SupabaseRemoteConfig {
  Future<Map<String, dynamic>> fetchConfig() async {
    final response = await Supabase.instance.client
        .from('app_config')
        .select()
        .eq('id', 1)
        .single();
    
    return response.data;
  }
  
  bool get adsEnabled => _config['ads_enabled'] ?? false;
}
```

**✅ Ưu điểm Supabase:**
- Đã có sẵn Supabase trong project
- Không cần thêm dependency
- Control đầy đủ qua SQL

**❌ Nhược điểm:**
- Không có A/B testing tự động
- Không có targeting theo country/version
- Phải tự implement caching

---

## ⚖️ **POLICY COMPLIANCE - CÓ VI PHẠM KHÔNG?**

### ✅ **CÂU TRẢ LỜI: HOÀN TOÀN HỢP LỆ!**

#### **Google Play Policy:**
- ✅ **Allowed**: Bật/tắt ads qua code logic
- ✅ **Allowed**: Không show ads cho premium users
- ✅ **Allowed**: A/B testing ad frequency
- ❌ **Not Allowed**: Click fraud, fake impressions, hidden ads

#### **AdMob Policy:**
- ✅ **Allowed**: Remote Config control (có tutorial chính thức)
- ✅ **Allowed**: Conditional ad display
- ✅ **Allowed**: User-triggered ad removal (premium purchase)
- ❌ **Not Allowed**: Manipulate eCPM floors để "tắt" ads

#### **App Store Policy:**
- ✅ **Allowed**: Dynamic ad control
- ✅ **Allowed**: In-app purchase để remove ads
- ✅ **Allowed**: Regional ad restrictions
- ❌ **Not Allowed**: Hidden tracking, deceptive practices

**📚 Official Google Tutorial:**
- [Firebase Remote Config + AdMob](https://firebase.google.com/docs/tutorials/optimize-ad-frequency)
- Case study: MegaJogos tăng 300% revenue bằng Remote Config

---

## 🏗️ **KIẾN TRÚC PRODUCTION KHUYẾN NGHỊ:**

```
┌─────────────────────────────────────────────────┐
│              Flutter App                        │
│                                                 │
│  ┌──────────────────────────────────────────┐  │
│  │  Remote Config Service                   │  │
│  │  - ads_enabled: bool                     │  │
│  │  - banner_ads_enabled: bool              │  │
│  │  - rewarded_ads_enabled: bool            │  │
│  └──────────────────────────────────────────┘  │
│                                                 │
│  ┌──────────────────────────────────────────┐  │
│  │  Ad Manager                              │  │
│  │  - Check remote config trước khi show    │  │
│  │  - Fallback khi offline                  │  │
│  └──────────────────────────────────────────┘  │
│                                                 │
│  📱 Ad Unit IDs (trong prod.json - OK)         │
│  - ADMOB_APP_ID: ca-app-pub-xxx~xxx            │
│  - APPLOVIN_SDK_KEY: xxx                       │
│                                                 │
│  ❌ KHÔNG có Replicate/Huggingface tokens      │
└─────────────────────────────────────────────────┘
                      ▲
                      │ Fetch config
                      │
┌─────────────────────┴───────────────────────────┐
│         Firebase Remote Config                  │
│         (hoặc Supabase app_config table)        │
│                                                 │
│  {                                              │
│    "ads_enabled": true/false,                   │
│    "banner_ads_enabled": true/false,            │
│    "rewarded_ads_enabled": true/false           │
│  }                                              │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│         Backend Server (api_server.py)          │
│                                                 │
│  🔐 Replicate API Token (server-side)          │
│  🔐 Huggingface API Token (server-side)        │
│                                                 │
│  Endpoints:                                     │
│  - POST /api/ai/hd-image                        │
│  - POST /api/ai/face-swap                       │
│  - POST /api/ai/fix-old-photo                   │
└─────────────────────────────────────────────────┘
```

---

## ✅ **CHECKLIST PRODUCTION:**

### **Secrets Management:**
- [ ] Ad Unit IDs trong `prod.json` (OK, không nguy hiểm)
- [ ] Replicate/Huggingface tokens KHÔNG có trong app
- [ ] Backend proxy cho AI API calls
- [ ] Supabase credentials trong app (OK, có RLS policies)

### **Remote Ads Control:**
- [ ] Firebase Remote Config setup
- [ ] Default values: `ads_enabled = false` (an toàn)
- [ ] Ad widgets check remote config trước khi show
- [ ] Fallback khi offline/fetch fail
- [ ] Targeting conditions (premium users, countries, versions)

### **Policy Compliance:**
- [ ] Không manipulate ad auction
- [ ] Không fake impressions/clicks
- [ ] Privacy policy mention ad control
- [ ] GDPR consent trước khi show ads

---

## 🎯 **TÓM TẮT - NHỮNG GÌ ANH CẦN LÀM:**

### **1. Bảo Mật Secrets:**

**✅ AN TOÀN để trong prod.json:**
```json
{
  "ADMOB_APP_ID_ANDROID": "...",
  "ADMOB_REWARDED_AD_UNIT_ID": "...",
  "APPLOVIN_SDK_KEY": "...",
  "SUPABASE_URL": "...",
  "SUPABASE_ANON_KEY": "...",
  "SUPPORT_EMAIL": "..."
}
```

**❌ DI CHUYỂN RA BACKEND:**
```json
{
  "REPLICATE_API_TOKEN": "...",  // ← Move to backend
  "HUGGINGFACE_TOKEN": "..."     // ← Move to backend
}
```

### **2. Remote Ads Control:**

**Option A: Firebase Remote Config (KHUYẾN NGHỊ)**
```bash
flutter pub add firebase_core firebase_remote_config
# Setup như hướng dẫn trên
```

**Option B: Supabase Config Table**
```sql
CREATE TABLE app_config (
  ads_enabled BOOLEAN DEFAULT false
);
```

### **3. Implementation:**
```dart
// main.dart
void main() async {
  await Firebase.initializeApp();
  await RemoteConfigService().initialize();
  
  if (RemoteConfigService().adsEnabled) {
    await initializeAds();
  }
  
  runApp(MyApp());
}

// Ad widgets
if (RemoteConfigService().bannerAdsEnabled) {
  showBannerAd();
}
```

---

## 📞 **Câu Hỏi Thường Gặp:**

**Q: Có cần update app khi bật/tắt ads không?**  
A: KHÔNG! Remote Config update real-time, user restart app là thấy thay đổi.

**Q: Nếu user offline thì sao?**  
A: Dùng giá trị default hoặc cached value lần fetch trước.

**Q: Chi phí Firebase Remote Config?**  
A: Free cho 2,000 active users, sau đó $0.01/1000 fetches.

**Q: AdMob có ban account vì tắt ads không?**  
A: KHÔNG! Đây là use case chính thức được Google support.

---

**🎉 KẾT LUẬN:**

1. **Ad IDs trong prod.json = OK**
2. **API Tokens phải move ra backend**
3. **Remote Config bật/tắt ads = HOÀN TOÀN HỢP LỆ**
4. **Use case của anh = Chiến lược marketing thông minh**

Có gì thắc mắc thêm cứ hỏi em nhé anh! 🚀
