# Face Swap Auto-Loading Templates Feature

## Overview
Face swap templates are now automatically loaded from Supabase Storage, eliminating the need for manual code updates when adding new templates.

## How It Works

### Architecture
```
Supabase Storage (face-swap-templates bucket)
    ├── female/
    ├── male/
    └── mixed/
         ↓
FaceSwapTemplateRepository.fetchAllTemplates()
         ↓
SwapfaceModel.loadTemplates()
         ↓
SwapfaceWidget (UI with loading/error/success states)
```

### Key Components

#### 1. FaceSwapTemplateRepository (`lib/backend/supabase/face_swap_template_repository.dart`)
- Fetches templates from Supabase Storage using `list()` API
- Auto-discovers files from female/, male/, mixed/ folders
- Filters image files (jpg, jpeg, png, webp)
- Formats display names (removes extension, capitalizes words)
- Generates public URLs for each template

#### 2. SwapfaceModel (`lib/swapface/swapface_model.dart`)
- Loading states: `isTemplatesLoading`, `templatesError`
- Dynamic template lists: `femaleStyles`, `maleStyles`, `mixedStyles`
- `loadTemplates()` method fetches and populates templates
- `allTemplates` getter combines all categories for carousel

#### 3. SwapfaceWidget (`lib/swapface/swapface_widget.dart`)
- Loads templates on `initState`
- Shows loading spinner while fetching
- Displays error UI with retry button on failure
- Shows empty state if no templates found
- Renders carousel when templates loaded successfully

## Adding New Templates

### Simple Process:
1. Upload image files to Supabase Storage bucket `face-swap-templates`
2. Choose folder: `female/`, `male/`, or `mixed/`
3. That's it! App will auto-discover on next load

### Example:
```
Upload: male/handsome.jpg, male/themen.jpg
Result: Templates auto-appear in carousel as "Handsome" and "Themen"
```

## UI States

### 1. Loading State
- Purple circular spinner
- "Loading templates..." text
- Shown during initial fetch

### 2. Error State
- Red error icon
- "Failed to load templates" message
- Error details displayed
- Purple "Retry" button

### 3. Empty State
- "No templates available" message
- Shown when folders are empty

### 4. Success State
- PageView carousel with templates
- Animated scaling for center item
- Dot indicators
- First template auto-selected

## Current Templates (Auto-Loaded)

### Female (5 templates)
- Beautiful Girl
- Kate Upton
- Nice Girl
- USA Girl
- Wedding Face

### Male (4 templates)
- Aquaman
- Handsome
- Superman
- Themen

### Mixed (2 templates)
- Beckham
- Parka Clothing

**Total: 11 templates** (dynamically loaded)

## Benefits
✅ No code changes needed when adding templates
✅ Clean separation of data and code
✅ Easy template management via Supabase UI
✅ Automatic error handling and retry
✅ Scalable solution for unlimited templates

## Mobile Download Enhancement
Face swap results now save to **Gallery/Photos app** using `gal` package instead of internal storage. Users can easily find downloaded images in their device's photo gallery.

---
*Last Updated: October 2025*
