# Mobile Build Instructions for Viso AI

## Current Issue: Mobile App Using Outdated API Domain

If your mobile app is showing errors like `FormatException: Unexpected character`, it's likely because:
1. The mobile app was built with an old Replit domain URL
2. That old domain no longer exists (Replit domains change when the server restarts)
3. The app receives HTML error pages instead of JSON responses

## Quick Workaround: Use Flutter Web
**Test the app on Flutter web instead of mobile** - it works immediately because it uses relative URLs that automatically adapt to the current domain.

Access your app at: `https://[your-current-replit-domain].replit.dev`

## Permanent Solution: Rebuild Mobile App

### Option 1: Build with Current Domain (Quick Fix)
The current Replit domain is already set as the default. Simply rebuild:

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

**Note:** This will break again when Replit restarts with a new domain.

### Option 2: Build with Custom Domain (Recommended)
If you have a custom domain or know the current domain, specify it at build time:

```bash
# Get current domain
env | grep DOMAIN

# Build with custom domain
flutter build apk --release --dart-define=API_DOMAIN=your-domain.replit.dev

# Example with current domain
flutter build apk --release --dart-define=API_DOMAIN=8bf1f206-1bbf-468e-94c3-c805a85c0cc0-00-3pryuqwgngpev.sisko.replit.dev
```

### Option 3: Production Solution (Best for Long-term)
For production apps, implement runtime configuration using Firebase Remote Config (already included in the project):

1. Store API domain in Firebase Remote Config
2. Fetch domain at app startup
3. No need to rebuild when domain changes

## Why This Happens
- **Flutter Web**: Uses `Uri.base.origin` which automatically gets the current domain ✅
- **Mobile Apps**: Need absolute URLs specified at compile time ❌
- **Replit**: Generates new domain IDs on each restart, breaking hardcoded URLs

## Verification
After rebuilding, check the logs when making API calls:
```
🌍 Making request to: https://[domain]/api/face-swap
```

If you see the correct domain, the app will work properly.

## Production Deployment Checklist
- [ ] Use a stable custom domain (not Replit auto-generated domain)
- [ ] OR implement Firebase Remote Config for dynamic API URL
- [ ] Test both web and mobile versions before release
- [ ] Document the API domain configuration for your team
