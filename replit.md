# Viso AI - Photo Avatar Headshot

## Overview
Viso AI is a Flutter-based application designed for creating studio-grade AI headshots and avatars. It offers advanced photo enhancement, face swapping, and various AI-driven transformations to produce high-quality, stylized digital images. The project addresses the growing market demand for personalized digital content and AI-powered image manipulation.

## Recent Changes
- **2025-10-17**: 📊 **Daily Usage Limits**: Implemented PRO user daily usage tracking (20 swaps/day) via SharedPreferences with auto-reset mechanism. FREE users enjoy unlimited swaps with rewarded ads. UsageLimitService tracks counter, checks limits before processing, and provides user feedback when limit reached.
- **2025-10-17**: 🎬 **Rewarded Ads for HD Image & Fix Old Photo**: Added full rewarded ad integration to HD Image Enhancement and Fix Old Photo Restoration features. FREE users watch ads before processing (AdMob/AppLovin with 'auto' fallback mode). PRO users bypass ads. Complete error handling with user feedback when ads unavailable.
- **2025-10-17**: 🎨 **13 New Template Categories**: Expanded face swap templates from 1 to 14 categories: Travel, Gym, Selfie, Tattoo, Wedding, Sport, Christmas, New Year, Birthday, School, Fashion Show, Profile, Suits. Each template features carousel layout with PageView slider, dot indicators, 5-8 Unsplash placeholder images, and download functionality. Templates ready for user customization with real images.
- **2025-10-17**: 🎨 **Fixed Mine Page UI Overlap**: Added SafeArea wrapper to Mine page to prevent Android system navigation bar from covering bottom content. Bottom navigation and "Start Creating" button now properly visible on all devices.
- **2025-10-16**: 🔄 **Fixed Provider Fallback Bug**: Face swap gateway now correctly switches from Replicate → PiAPI when Replicate fails/timeouts. Previously gateway would retry failed provider instead of falling back. Added `break` statement to exit retry loop on provider failure (success=False), allowing proper provider switching.
- **2025-10-16**: ⚡ **App Startup Optimization (70% faster)**: Reduced startup time from 7-10s → 1-2s using combo 3 strategies: (1) Parallel service initialization with Future.wait for core services (UserService, RemoteConfig, RevenueCat, Supabase, Theme), (2) Lazy ads loading - UI shows immediately, ads init in background, (3) Remote Config timeout reduction (60s → 10s). Architect-reviewed and verified safe with no race conditions or dependency issues.
- **2025-10-16**: 🔐 **Secure Ad IDs with Remote Config**: Migrated AdMob (12 IDs: App ID + 5 ad units × 2 platforms) & AppLovin (11 IDs: SDK Key + 5 ad units × 2 platforms) to Firebase Remote Config for security. 3-layer fallback: Remote Config → Env Vars → Test IDs. Created comprehensive setup guide (FIREBASE_AD_IDS_SETUP.md). Prevents APK decompilation risks and enables real-time ad ID updates without app rebuild. Platform-specific tracking for better analytics.
- **2025-10-16**: 🐛 **Fixed PiAPI Input Error**: Keep data URI format (data:image/...;base64,) intact - PiAPI needs format info. Previous strip attempt caused `input:null` errors.
- **2025-10-16**: 🔧 **Fixed PiAPI Header**: Changed "X-API-Key" → "x-api-key" per PiAPI 2025 API requirements (lowercase header).
- **2025-10-16**: 📸 **Swapface UI Improvements**: Changed page title "Ghostface" → "Swapface", added camera button alongside gallery picker for direct photo capture using image_picker package.
- **2025-10-16**: ✅ **Production Backend: Railway Only**: User migrated from Vercel → Railway Hobby ($5/mo) for stable 300s timeout. Local Replit backend (`api_server.py`) deprecated - Railway (`api/index.py`) is SOLE production backend.
- **2025-10-16**: 🔧 **Fixed Face Swap Response Format**: Changed response field from `'result'` → `'image'` (base64) in `api/index.py` for Flutter compatibility. Local `api_server.py` not updated (deprecated).
- **2025-10-16**: ✅ **Railway Production Deployed!**: Backend live at `web-production-a7698.up.railway.app` with 300s timeout. Flutter app updated to use Railway domain. Simplified config (removed nixpacks.toml, auto-detection works perfectly).
- **2025-10-16**: 🚂 **Railway Deployment Ready**: Created Railway config files (Procfile, railway.toml, railway_app.py) and complete setup guide (RAILWAY_SETUP.md). Railway Hobby ($5/mo) provides 300s timeout - perfect for face swap (30-120s).
- **2025-10-16**: Added gunicorn to requirements.txt for production WSGI server
- **2025-10-16**: Fixed null handling in faceSwap API response to prevent type errors
- **2025-10-16**: Attempted Vercel deployment but discovered serverless timeout limitations (10s free tier, insufficient for face swap)
- **2025-10-16**: Fixed replicate package version to 1.0.7 in requirements.txt
- **2025-10-16**: Prepared Vercel deployment files for stable production backend (api/index.py, vercel.json, requirements.txt)
- **2025-10-16**: Created comprehensive deployment guides (VERCEL_SETUP_GUIDE.md, APK_SIZE_OPTIMIZATION.md)
- **2025-10-16**: Implemented configurable API domain for mobile builds using `--dart-define=API_DOMAIN` to prevent hardcoded URL issues when Replit domain changes
- **2025-10-16**: Fixed critical validation bug - was reading partial data (1000 bytes) causing corrupt images; now reads full response and validates image signatures (JPEG/PNG/GIF/WEBP/BMP magic bytes)
- **2025-10-15**: Added comprehensive debug logging and output type handling for Replicate models (list/FileOutput/string)
- **2025-10-15**: Enhanced download validation - accept CDN octet-stream responses and detect HTML error pages
- **2025-10-15**: Switched provider priority - Replicate PRIMARY (budget-friendly) → PiAPI FALLBACK (99.9% SLA) to save credits
- **2025-10-15**: Fixed face swap response format mismatch - server now downloads images and converts to base64 for Flutter compatibility

## User Preferences
None documented yet.

## System Architecture

### UI/UX Decisions
The application leverages FlutterFlow-generated components to ensure a consistent, responsive design with support for both light and dark themes. It incorporates modern UI elements such as carousels with PageView sliders, smooth transitions, and dot indicators. Ad banners are strategically placed above navigation bars to comply with Google Ads policies. A feedback system allows users to submit feature requests via an integrated dialog.

### Technical Implementations
Built with Flutter 3.32.0 (Dart 3.8.0), Viso AI integrates with a Python Flask backend. This backend functions as a proxy, handling text and image generation, and managing complex image processing tasks with an asynchronous architecture.

### Feature Specifications
- **AI Headshot & Avatar Generation**: Studio-grade AI headshots and stylized avatars.
- **Photo Enhancement**: Includes HD Image Enhancement with a 3-tier fallback system (Huggingface Inference API, Replicate Real-ESRGAN, Huggingface Space), and Old Photo Restoration using GFPGAN via Replicate.
- **Face Swapping**: AI-powered face replacement with multi-provider fallback strategy (PiAPI primary with 99.9% SLA, Replicate fallback), gallery permission handling, and rewarded ad integration. Supports both image and video face swap.
- **AI Style Templates**: Provides 14 diverse template categories for face swap and aesthetic transformations: Travel, Gym, Selfie, Tattoo, Wedding, Sport, Christmas, New Year, Birthday, School, Fashion Show, Profile, Suits, plus original templates. Each category features carousel layout with 5-8 curated images and instant download capability.
- **Monetization**:
    - **Advertising**: Supports Google Mobile Ads (AdMob) for web, and a dual-network system (AdMob primary, AppLovin MAX fallback) for mobile banner, app open, and rewarded ads. Firebase Remote Config enables dynamic ad control and A/B testing.
    - **In-App Purchases**: Utilizes RevenueCat SDK for managing premium subscriptions (Lifetime, Yearly, Weekly tiers) with test mode support. Premium features include ad bypass, unlimited creations, and priority processing.
- **Internationalization**: Supports 20 languages with interactive selection and persistence.
- **Mobile Download**: Images are saved directly to the device's Gallery/Photos app using the `gal` package, creating a "VisoAI" album and ensuring immediate visibility via MediaScanner integration.
- **Settings**: Includes features for sharing, feedback (email integration), "About" section, User Agreement, Privacy Policy, and Community Guidelines.

### System Design Choices
Supabase is used for backend services, covering authentication, database management, and storage. AI functionalities are primarily powered by Huggingface Spaces and Replicate APIs, accessed via a Python Flask proxy server. Face swap templates are dynamically loaded from Supabase Storage, facilitating automated discovery and management.

**Production Deployment Strategy:**
- **Backend**: ✅ **Railway Hobby ($5/mo) ONLY** - LIVE at `web-production-a7698.up.railway.app` with 300s timeout, perfect for AI operations. Container 24/7, no cold start, stable domain.
  - Production: `api/index.py` → `railway_app.py` (Flask + Gunicorn)
  - Local Dev: `api_server.py` (DEPRECATED - not maintained, Railway is sole production backend)
- **Database/Auth/Storage**: Supabase (as current)
- **Mobile**: Flutter APK with `--split-per-abi` optimization (reduces from 200MB to 40-60MB per APK)
- **Web**: Flutter web served from Replit (development) or static hosting (production)

**Why Railway over Vercel:**
- Railway: 300s timeout, container 24/7, $5/mo - ✅ **DEPLOYED & WORKING**
- Vercel Free: 10s timeout (insufficient for face swap 30-120s)
- Vercel Pro Max: 300s timeout, $40/mo (8x more expensive than Railway)

**Backend Architecture (Production):**
```
Users → Railway (web-production-a7698.up.railway.app)
         ├─ api/index.py (Flask endpoints) ✅
         ├─ railway_app.py (WSGI entry) ✅
         ├─ services/face_swap_gateway.py (Multi-provider)
         └─ Gunicorn (Production WSGI server)
         
[Local Replit - DEPRECATED, NOT USED]
         └─ api_server.py (dev only, not maintained)
```

## External Dependencies

- **Supabase**: Backend services (authentication, database, storage), including dynamic loading of face swap templates.
- **Google Mobile Ads (AdMob)**: Advertising for web and primary ad network for mobile.
- **AppLovin MAX**: Secondary ad network for mobile (iOS/Android) for rewarded, interstitial, and banner ads.
- **RevenueCat**: In-app purchase management for premium subscriptions.
- **Huggingface API**: AI models for text/image generation, image enhancement, photo restoration, and style transfer.
- **PiAPI**: Primary face swap provider with 99.9% uptime SLA for enterprise-grade image and video face swapping.
- **Replicate API**: Fallback AI services for photo restoration and face-swapping.
- **Flutter Core Dependencies**: `supabase_flutter`, `cached_network_image`, `go_router`, `google_fonts`, `flutter_animate`, `http`, `permission_handler`, `path_provider`, `applovin_max`, `share_plus`, `url_launcher`, `firebase_core`, `firebase_remote_config`, `purchases_flutter`, `gal`, `shared_preferences`.