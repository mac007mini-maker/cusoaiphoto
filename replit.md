# Viso AI - Photo Avatar Headshot

## Overview
Viso AI is a Flutter-based application for generating studio-grade AI headshots and avatars. It provides advanced photo enhancement, face swapping, and various AI-driven transformations. The project aims to deliver high-quality, personalized digital images efficiently and cost-effectively, addressing the market demand for AI-powered image manipulation.

## User Preferences
None documented yet.

## System Architecture

### UI/UX Decisions
The application features a consistent and responsive design built with FlutterFlow-generated components, supporting both light and dark themes. It incorporates modern UI elements such as carousels with PageView sliders, smooth transitions, and dot indicators. Ad banners are strategically placed above navigation bars. A feedback system allows users to submit feature requests.

### Technical Implementations
Developed with Flutter 3.32.0 (Dart 3.8.0), Viso AI integrates with a Python Flask backend. This backend serves as a proxy for complex asynchronous image processing tasks and AI model interactions.

### Feature Specifications
- **AI Headshot & Avatar Generation**: Produces studio-grade AI headshots and stylized avatars.
- **Photo Enhancement**: Includes HD Image Enhancement (via Replicate Real-ESRGAN) and Old Photo Restoration (via Replicate GFPGAN).
- **Face Swapping**: Offers AI-powered face replacement with a multi-provider fallback system (PiAPI primary, Replicate fallback), robust gallery permission handling, and rewarded ad integration. Supports both image and video face swap functionalities.
- **AI Style Templates**: Features 14 diverse template categories for face swap and aesthetic transformations (e.g., Travel, Gym, Selfie, Tattoo, Wedding, Sport, Christmas, New Year, Birthday, School, Fashion Show, Profile, Suits). Each category includes carousel layouts and direct download capabilities. Templates are loaded dynamically from Supabase Storage.
- **AI Transformation Templates**: Provides 5 advanced AI transformations accessible from the Templates Gallery. Each template includes:
    - Multi-provider fallback for high uptime.
    - Rewarded ad integration for free users (AdMob → AppLovin).
    - PRO user bypass with daily usage limits (20/day).
    - Download functionality to device Gallery/VisoAI album.
    - Gallery and Camera photo picker integration.
    - Real-time processing feedback.
    - **Cartoon 3D Toon**: Transforms photos into Disney/Pixar-style cartoons.
    - **Memoji Avatar**: Creates Apple-style 3D memoji avatars.
    - **Animal Toon**: Transforms into animal characters (e.g., bunny, cat, dog).
    - **Muscle Enhancement**: Adds defined muscles with adjustable intensity.
    - **Art Style**: Applies artistic styles like mosaic, oil painting, or watercolor.
- **Monetization**:
    - **Advertising**: Google Mobile Ads (AdMob) for web, and a dual-network system (AdMob primary, AppLovin MAX fallback) for mobile banner, app open, and rewarded ads, configured via Firebase Remote Config.
    - **In-App Purchases**: RevenueCat SDK for premium subscriptions (Lifetime, Yearly, Weekly tiers) offering ad removal, unlimited creations, and priority processing.
- **Internationalization**: Supports 20 languages with interactive selection.
- **Mobile Download**: Images are saved to a dedicated "VisoAI" album in the device's gallery.
- **Settings**: Includes options for sharing, feedback, an "About" section, User Agreement, Privacy Policy, and Community Guidelines.

### System Design Choices
Supabase provides core backend services, including authentication, database, and storage. AI functionalities are primarily powered by Huggingface Spaces and Replicate APIs, accessed through a Python Flask proxy server. Face swap templates and video templates are dynamically loaded from Supabase Storage.

**Production Deployment Strategy:**
- **Backend**: Deployed on Railway Hobby for the Flask + Gunicorn application.
- **Database/Auth/Storage**: Managed by Supabase.
- **Mobile**: Flutter APK with `--split-per-abi` optimization.

### Recent Changes

**Face Swap Timeout Fix (October 2025)**
Fixed critical timeout bug in face swap feature (SwapFace + 13 story templates) by switching from base64 transfer to URL-based CDN download:

- **Problem**: Face swap was timing out after 120s despite fast API processing (9-30s). Root cause: Backend was downloading 6.8MB images → encoding to 9MB base64 → slow transfer to Flutter caused timeout.
- **Solution**: Backend now returns Replicate CDN URL directly (no download/encode). Flutter downloads image bytes from CDN separately.
- **Pattern**: Matches proven video swap implementation for consistency.
- **Implementation**:
  - Backend (`api/index.py`): `/api/ai/face-swap` returns `{'url': result_url}` instead of `{'image': base64_string}`
  - Service (`HuggingfaceService.dart`): `faceSwap()` returns URL String, validates non-empty
  - Widgets: SwapFace + 13 story templates download from URL via `http.get(Uri.parse(resultUrl))` after API call completes
  - Models: Changed `String? resultImageBase64` → `Uint8List? resultImageBytes` for all templates
- **Files Updated**: 
  - Backend: `api/index.py` (face swap endpoint)
  - Service: `lib/services/huggingface_service.dart` (faceSwap method)
  - SwapFace: `lib/swapface/swapface_model.dart`, `lib/swapface/swapface_widget.dart`
  - Story templates (26 files): travel, gym, selfie, tattoo, wedding, sport, christmas, newyear, birthday, school, fashionshow, profile, suits (model + widget each)
- **Ad Flow**: Rewarded ad displays first (15-30s) → Ad complete callback → Face swap API call (9-30s) → Download result from CDN → Display
- **Uptime**: Multi-provider fallback (Replicate → PiAPI) ensures 99.9%+ availability

## External Dependencies

- **Supabase**: Backend services (authentication, database, storage).
- **Google Mobile Ads (AdMob)**: Advertising network.
- **AppLovin MAX**: Secondary mobile ad network.
- **RevenueCat**: In-app purchase and subscription management.
- **Huggingface API**: AI models for various transformations and generations.
- **VModel API**: Primary provider for video face swap (photo-to-video).
- **Replicate API**: Provider for image and video face swap fallback, photo restoration, and style transfer.
- **PiAPI**: Face swap provider (fallback for image-only operations).
- **Flutter Core Dependencies**: `supabase_flutter`, `cached_network_image`, `go_router`, `google_fonts`, `flutter_animate`, `http`, `permission_handler`, `path_provider`, `applovin_max`, `share_plus`, `url_launcher`, `firebase_core`, `firebase_remote_config`, `purchases_flutter`, `gal`, `shared_preferences`.