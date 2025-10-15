# Viso AI - Photo Avatar Headshot

## Overview
Viso AI is a Flutter-based application designed for creating studio-grade AI headshots and avatars. It offers advanced photo enhancement, face swapping, and various AI-driven transformations to produce high-quality, stylized digital images. The project addresses the growing market demand for personalized digital content and AI-powered image manipulation.

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
- **Face Swapping**: AI-powered face replacement with a multi-provider fallback strategy, gallery permission handling, and rewarded ad integration.
- **AI Style Templates**: Provides diverse templates for aesthetic transformations, such as cartoonification and various avatar styles.
- **Monetization**:
    - **Advertising**: Supports Google Mobile Ads (AdMob) for web, and a dual-network system (AdMob primary, AppLovin MAX fallback) for mobile banner, app open, and rewarded ads. Firebase Remote Config enables dynamic ad control and A/B testing.
    - **In-App Purchases**: Utilizes RevenueCat SDK for managing premium subscriptions (Lifetime, Yearly, Weekly tiers) with test mode support. Premium features include ad bypass, unlimited creations, and priority processing.
- **Internationalization**: Supports 20 languages with interactive selection and persistence.
- **Mobile Download**: Images are saved directly to the device's Gallery/Photos app using the `gal` package, creating a "VisoAI" album and ensuring immediate visibility via MediaScanner integration.
- **Settings**: Includes features for sharing, feedback (email integration), "About" section, User Agreement, Privacy Policy, and Community Guidelines.

### System Design Choices
Supabase is used for backend services, covering authentication, database management, and storage. AI functionalities are primarily powered by Huggingface Spaces and Replicate APIs, accessed via a Python proxy server for efficient management. Face swap templates are dynamically loaded from Supabase Storage, facilitating automated discovery and management.

## External Dependencies

- **Supabase**: Backend services (authentication, database, storage), including dynamic loading of face swap templates.
- **Google Mobile Ads (AdMob)**: Advertising for web and primary ad network for mobile.
- **AppLovin MAX**: Secondary ad network for mobile (iOS/Android) for rewarded, interstitial, and banner ads.
- **RevenueCat**: In-app purchase management for premium subscriptions.
- **Huggingface API**: AI models for text/image generation, image enhancement, photo restoration, and style transfer.
- **Replicate API**: Production-grade AI services for photo restoration and face-swapping.
- **Flutter Core Dependencies**: `supabase_flutter`, `cached_network_image`, `go_router`, `google_fonts`, `flutter_animate`, `http`, `permission_handler`, `path_provider`, `applovin_max`, `share_plus`, `url_launcher`, `firebase_core`, `firebase_remote_config`, `purchases_flutter`, `gal`.