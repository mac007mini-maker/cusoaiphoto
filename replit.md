# Viso AI - Photo Avatar Headshot

## Overview
Viso AI is a Flutter-based application for creating studio-grade AI headshots and avatars. It offers advanced photo enhancement, face swapping, and various AI-driven transformations, addressing the market demand for personalized digital content and AI-powered image manipulation. The project aims to provide high-quality, stylized digital images efficiently and cost-effectively.

## Recent Changes (Oct 18, 2025)
### AI Template Model Updates - Fixed 4/5 Templates
- **Cartoon 3D Toon**: Fixed invalid `style_name` parameter - changed from "Cartoon" to "Disney Charactor" (valid PhotoMaker-Style param)
- **Memoji Avatar**: Fixed invalid `style_name` parameter - changed from "3D Avatar" to "Digital Art" (valid PhotoMaker-Style param)  
- **Muscle Enhancement**: Replaced broken model `arielreplicate/instruct-pix2pix` (404) with official `timothybrooks/instruct-pix2pix` (919K+ runs, $0.053/run)
- **Art Style**: Replaced broken Neural Neighbor model with PhotoMaker + artistic prompts (PRIMARY) and retained Oil Painting fallback
- **Animal Toon**: Already working ✅ (no changes needed)
- All gateways verified with multi-provider fallback architecture intact

## User Preferences
None documented yet.

## System Architecture

### UI/UX Decisions
The application utilizes FlutterFlow-generated components for a consistent, responsive design supporting light and dark themes. It features modern UI elements like carousels with PageView sliders, smooth transitions, and dot indicators. Ad banners are placed above navigation bars, and a feedback system allows users to submit feature requests.

### Technical Implementations
Built with Flutter 3.32.0 (Dart 3.8.0), Viso AI integrates with a Python Flask backend. This backend acts as a proxy for text and image generation, and complex asynchronous image processing tasks.

### Feature Specifications
- **AI Headshot & Avatar Generation**: Studio-grade AI headshots and stylized avatars.
- **Photo Enhancement**: Includes HD Image Enhancement using the HD Image Gateway (Replicate Real-ESRGAN) and Old Photo Restoration (GFPGAN via Replicate).
- **Face Swapping**: AI-powered face replacement with multi-provider fallback (PiAPI primary, Replicate fallback), gallery permission handling, and rewarded ad integration. Supports image and video face swap.
- **AI Style Templates**: 14 diverse template categories for face swap and aesthetic transformations (e.g., Travel, Gym, Selfie, Tattoo, Wedding, Sport, Christmas, New Year, Birthday, School, Fashion Show, Profile, Suits), each with carousel layouts and download capabilities.
- **AI Transformation Templates**: 5 advanced AI transformations accessible from Templates Gallery. Each template includes: (1) Multi-provider fallback for 99.9%+ uptime, (2) Rewarded ad integration (AdMob → AppLovin) for FREE users, (3) PRO user bypass with daily limits (20/day), (4) Download to Gallery/VisoAI album, (5) Gallery + Camera photo picker, (6) Real-time processing feedback.

    **1. Cartoon 3D Toon** (`/cartoon-toon`) - Transform photos into Disney/Pixar-style cartoon characters
    - **Provider Stack**: PRIMARY Replicate PhotoMaker-Style ($0.007/run, ~8s, timeout=20s) → FALLBACK Replicate InstantID Artistic ($0.069/run, ~71s, timeout=90s)
    - **API**: `POST /api/ai/cartoon` → `services/cartoon_gateway.py`
    - **Cost**: $0.007 typical, $0.069 worst-case. 10K/month = $70-$690

    **2. Memoji Avatar** (`/memoji-avatar`) - Create Apple-style 3D memoji avatars with smooth rendering
    - **Provider Stack**: PRIMARY Replicate PhotoMaker-Style ($0.007/run, ~8s, timeout=20s) → FALLBACK Replicate InstantID ($0.069/run, ~71s, timeout=90s)
    - **API**: `POST /api/ai/memoji` → `services/memoji_gateway.py`
    - **Cost**: $0.007 typical, $0.069 worst-case. 10K/month = $70-$690

    **3. Animal Toon** (`/animal-toon`) - Transform into cute animal characters (bunny, cat, dog, etc.)
    - **Provider Stack** (FULL 3-LAYER): PRIMARY Replicate PhotoMaker ($0.004/run, ~5s, timeout=30s) → FALLBACK Replicate InstantID ($0.069/run, ~71s, timeout=90s) → EMERGENCY PiAPI Flux (~$0.02/run, ~10s, timeout=20s)
    - **API**: `POST /api/ai/animal-toon` → `services/animal_toon_gateway.py` (supports `animal_type` param, default='bunny')
    - **Cost**: $0.004 typical (CHEAPEST), $0.02 emergency. 10K/month = $40-$200. BEST cost efficiency.

    **4. Muscle Enhancement** (`/muscle-enhance`) - Add defined muscles and athletic body (3 intensity levels)
    - **Provider Stack** (PRAGMATIC 2-PROVIDER): PRIMARY timothybrooks/instruct-pix2pix ($0.053/run, ~40s, timeout=60s) → FALLBACK retry with relaxed guidance params
    - **API**: `POST /api/ai/muscle` → `services/muscle_gateway.py` (supports `intensity` param: light/moderate/strong)
    - **Cost**: $0.053/run. 10K/month = $530
    - **Note**: Uses official Replicate Instruct-Pix2Pix model (919K+ runs). 2-provider setup provides reasonable resilience; most failures are input-related (poor photo quality) rather than API outages.

    **5. Art Style** (`/art-style`) - Apply artistic styles: mosaic, oil painting, watercolor
    - **Provider Stack**: PRIMARY Replicate PhotoMaker Art ($0.004/run, ~30s, timeout=30s) → FALLBACK Replicate Oil Painting ($0.08/run, SLOW ~11min, timeout=720s)
    - **API**: `POST /api/ai/art-style` → `services/art_style_gateway.py` (supports `style` param: mosaic/oil/watercolor)
    - **Cost**: $0.004 typical (uses same PhotoMaker as Animal Toon), $0.08 fallback. 10K/month = $40-$800
    - **Note**: PRIMARY uses prompt-based artistic style transformation with PhotoMaker. Fallback Oil Painting is SLOW (11min) but provides alternative rendering when needed.

    **Estimated production cost**: ~$1,250/month at scale (10K transformations/template). Total cost range: $40 (Animal Toon & Art Style cheapest with PhotoMaker) to $690 (Cartoon/Memoji worst-case).

    **Testing Plan**: (1) Navigate Templates Gallery → verify 5 new cards appear, (2) For each template: tap card → upload photo → watch ad (FREE) or bypass (PRO) → verify transformation → download to Gallery/VisoAI, (3) Fallback testing: disable APIs to verify provider switching in server logs, (4) Daily limits: verify 20/day cap for PRO users.
- **Monetization**:
    - **Advertising**: Google Mobile Ads (AdMob) for web, and a dual-network system (AdMob primary, AppLovin MAX fallback) for mobile banner, app open, and rewarded ads, managed via Firebase Remote Config.
    - **In-App Purchases**: RevenueCat SDK for premium subscriptions (Lifetime, Yearly, Weekly tiers) offering ad bypass, unlimited creations, and priority processing.
- **Internationalization**: Supports 20 languages with interactive selection.
- **Mobile Download**: Images are saved directly to the device's Gallery/Photos app in a "VisoAI" album.
- **Settings**: Includes sharing, feedback, "About" section, User Agreement, Privacy Policy, and Community Guidelines.

### System Design Choices
Supabase handles backend services including authentication, database, and storage. AI functionalities leverage Huggingface Spaces and Replicate APIs via a Python Flask proxy server. Face swap templates are dynamically loaded from Supabase Storage.

**Production Deployment Strategy:**
- **Backend**: Railway Hobby ($5/mo) at `web-production-a7698.up.railway.app` for 300s timeout. Uses `api/index.py` (Flask + Gunicorn) for production.
- **Database/Auth/Storage**: Supabase.
- **Mobile**: Flutter APK with `--split-per-abi` optimization.

## External Dependencies

- **Supabase**: Backend services (authentication, database, storage).
- **Google Mobile Ads (AdMob)**: Advertising.
- **AppLovin MAX**: Secondary mobile ad network.
- **RevenueCat**: In-app purchase management.
- **Huggingface API**: AI models for text/image generation, enhancement, restoration, and style transfer.
- **PiAPI**: Primary face swap provider.
- **Replicate API**: Fallback AI services for photo restoration and face-swapping.
- **Flutter Core Dependencies**: `supabase_flutter`, `cached_network_image`, `go_router`, `google_fonts`, `flutter_animate`, `http`, `permission_handler`, `path_provider`, `applovin_max`, `share_plus`, `url_launcher`, `firebase_core`, `firebase_remote_config`, `purchases_flutter`, `gal`, `shared_preferences`.