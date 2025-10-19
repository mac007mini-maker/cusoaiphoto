# Photo Templates Migration Guide

## Overview
This guide helps you migrate photo templates from hardcoded URLs to Supabase Storage for dynamic loading.

## ✅ COMPLETED: SwapFace Templates
**Bucket:** `face-swap-templates`  
**Status:** ✅ Already migrated and working!  
**Current photos:** 12 photos in 3 categories (female, male, mixed)

The SwapFace templates are already stored in Supabase Storage and loading dynamically.

---

## 📝 TODO: Story Templates (13 Categories)

You need to create the `story-templates` bucket in Supabase Storage and upload photos for these 13 categories:

### Bucket Structure
```
story-templates/
├── travel/
├── gym/
├── selfie/
├── tattoo/
├── wedding/
├── sport/
├── christmas/
├── newyear/
├── birthday/
├── school/
├── fashionshow/
├── profile/
└── suits/
```

### Current Hardcoded URLs (For Reference)

These are the current placeholder images from Unsplash. You can:
1. Download these images and re-upload to Supabase Storage, OR
2. Use your own images for each category

---

### 1. Travel Template (`travel/` folder)
Current images:
- Eiffel Tower: `https://images.unsplash.com/photo-1511739001486-6bfe10ce785f?w=800`
- Beach Paradise: `https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800`
- Mountain Adventure: `https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800`
- City Explorer: `https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=800`
- Desert Journey: `https://images.unsplash.com/photo-1473496169904-658ba7c44d8a?w=800`
- Tropical Island: `https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800`

---

### 2. Gym Template (`gym/` folder)
Current images:
- Gym Workout: `https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800`
- Fitness Training: `https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800`
- Weight Lifting: `https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=800`
- Yoga: `https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800`
- Running: `https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=800`
- CrossFit: `https://images.unsplash.com/photo-1599058917212-d750089bc07e?w=800`

---

### 3. Selfie Template (`selfie/` folder)
Current images:
- Casual Selfie: `https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=800`
- Outdoor Selfie: `https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800`
- Beach Selfie: `https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=800`
- City Selfie: `https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800`
- Nature Selfie: `https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=800`
- Mirror Selfie: `https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800`

---

### 4. Tattoo Template (`tattoo/` folder)
Current images:
- Arm Tattoo: `https://images.unsplash.com/photo-1565058663990-5ca8ff0f707d?w=800`
- Back Tattoo: `https://images.unsplash.com/photo-1611501275019-9b5cda06a901?w=800`
- Sleeve Tattoo: `https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?w=800`
- Chest Tattoo: `https://images.unsplash.com/photo-1609506899107-3c30f8fb87ff?w=800`
- Leg Tattoo: `https://images.unsplash.com/photo-1590246814883-57c511e2f3fa?w=800`
- Hand Tattoo: `https://images.unsplash.com/photo-1562962230-16e4623d36e6?w=800`

---

### 5. Wedding Template (`wedding/` folder)
Current images:
- Bride Portrait: `https://images.unsplash.com/photo-1519741497674-611481863552?w=800`
- Groom Portrait: `https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800`
- Wedding Couple: `https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?w=800`
- Wedding Dress: `https://images.unsplash.com/photo-1594973759598-abbbceb65465?w=800`
- Wedding Ring: `https://images.unsplash.com/photo-1492707892479-7bc8d5a4ee93?w=800`
- Wedding Venue: `https://images.unsplash.com/photo-1519167758481-83f29da8c2f6?w=800`

---

### 6. Sport Template (`sport/` folder)
Current images:
- Football: `https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=800`
- Basketball: `https://images.unsplash.com/photo-1546483875-ad9014c88eba?w=800`
- Tennis: `https://images.unsplash.com/photo-1542144612-1b3641ec1e5f?w=800`
- Soccer: `https://images.unsplash.com/photo-1575361204480-aadea25e6e68?w=800`
- Baseball: `https://images.unsplash.com/photo-1566577739112-5180d4bf9390?w=800`
- Volleyball: `https://images.unsplash.com/photo-1612872087720-bb876e2e67d1?w=800`

---

### 7. Christmas Template (`christmas/` folder)
Current images:
- Christmas Tree: `https://images.unsplash.com/photo-1512389142860-9c449e58a543?w=800`
- Santa Claus: `https://images.unsplash.com/photo-1543589077-47d81606c1bf?w=800`
- Snowman: `https://images.unsplash.com/photo-1483729558449-99ef09a8c325?w=800`
- Christmas Gifts: `https://images.unsplash.com/photo-1513885535751-8b9238bd345a?w=800`
- Winter Wonderland: `https://images.unsplash.com/photo-1482517967863-00e15c9b44be?w=800`
- Christmas Lights: `https://images.unsplash.com/photo-1481318281854-5c3c2e1eeb77?w=800`

---

### 8. New Year Template (`newyear/` folder)
Current images:
- Fireworks: `https://images.unsplash.com/photo-1467810563316-b5476525c0f9?w=800`
- Champagne: `https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=800`
- Party: `https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=800`
- Countdown: `https://images.unsplash.com/photo-1533777857889-4be7c70b33f7?w=800`
- Celebration: `https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800`
- Confetti: `https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=800`

---

### 9. Birthday Template (`birthday/` folder)
Current images:
- Birthday Cake: `https://images.unsplash.com/photo-1558636508-e0db3814bd1d?w=800`
- Birthday Party: `https://images.unsplash.com/photo-1464349153735-7db50ed83c84?w=800`
- Balloons: `https://images.unsplash.com/photo-1527529482837-4698179dc6ce?w=800`
- Birthday Candles: `https://images.unsplash.com/photo-1509281373149-e957c6296406?w=800`
- Birthday Gifts: `https://images.unsplash.com/photo-1549465220-1a8b9238cd48?w=800`
- Birthday Celebration: `https://images.unsplash.com/photo-1513151233558-d860c5398176?w=800`

---

### 10. School Template (`school/` folder)
Current images:
- Classroom: `https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=800`
- Student: `https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=800`
- Books: `https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=800`
- Graduation: `https://images.unsplash.com/photo-1523580494863-6f3031224c94?w=800`
- Library: `https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=800`
- School Building: `https://images.unsplash.com/photo-1562774053-701939374585?w=800`

---

### 11. Fashion Show Template (`fashionshow/` folder)
Current images:
- Runway: `https://images.unsplash.com/photo-1558769132-cb1aea8f022c?w=800`
- Model: `https://images.unsplash.com/photo-1509631179647-0177331693ae?w=800`
- Fashion: `https://images.unsplash.com/photo-1483985988355-763728e1935b?w=800`
- Catwalk: `https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800`
- Designer: `https://images.unsplash.com/photo-1558769132-cb1aea8f022c?w=800`
- Fashion Week: `https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=800`

---

### 12. Profile Template (`profile/` folder)
Current images:
- Professional: `https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800`
- Headshot: `https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=800`
- Business: `https://images.unsplash.com/photo-1556157382-97eda2d62296?w=800`
- Corporate: `https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=800`
- LinkedIn: `https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=800`
- Avatar: `https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800`

---

### 13. Suits Template (`suits/` folder)
Current images:
- Business Suit: `https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=800`
- Formal Wear: `https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800`
- Tuxedo: `https://images.unsplash.com/photo-1593030103066-0093718efeb9?w=800`
- Professional: `https://images.unsplash.com/photo-1556157382-97eda2d62296?w=800`
- Executive: `https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800`
- Corporate: `https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=800`

---

## 📋 Migration Steps

### Step 1: Create Supabase Storage Bucket
1. Go to your Supabase dashboard: https://supabase.com/dashboard
2. Navigate to Storage section
3. Create a new bucket named `story-templates`
4. Set bucket to **Public** (so URLs are accessible)

### Step 2: Create Folder Structure
Create these 13 folders inside the `story-templates` bucket:
- travel
- gym
- selfie
- tattoo
- wedding
- sport
- christmas
- newyear
- birthday
- school
- fashionshow
- profile
- suits

### Step 3: Upload Photos
For each category:
1. Download images from Unsplash URLs (or use your own images)
2. Upload to the corresponding folder in Supabase Storage
3. Supported formats: `.jpg`, `.jpeg`, `.png`, `.webp`

### Step 4: Set Bucket Permissions
Add this policy to the `story-templates` bucket:
- **Policy name:** Public can list files
- **Allowed operations:** SELECT
- **Target roles:** public
- **Policy definition:**
```sql
CREATE POLICY "Public can list files"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'story-templates');
```

### Step 5: Verify
1. Restart your Flutter app
2. Navigate to any story template (Travel, Gym, etc.)
3. Photos should load automatically from Supabase Storage
4. Check backend logs for: `✅ [PHOTO_TEMPLATES_STORY] Found X photos in Y categories (DYNAMIC)`

---

## 🎯 Benefits After Migration

✅ **Dynamic Updates:** Add/remove photos without rebuilding the app  
✅ **No Hardcoded URLs:** All images centrally managed in Supabase  
✅ **Easy Content Management:** Upload new templates anytime  
✅ **Automatic Sync:** App auto-loads new photos on next launch  
✅ **Scalable:** Same pattern as video templates (already working)

---

## 🔧 Troubleshooting

**Problem:** API returns empty templates  
**Solution:** Make sure:
1. Bucket name is exactly `story-templates` (case-sensitive)
2. Folders match category names exactly (travel, gym, etc.)
3. Bucket has public permissions
4. Photos have supported extensions (.jpg, .jpeg, .png, .webp)

**Problem:** Photos don't show in app  
**Solution:** 
1. Check backend logs for errors
2. Verify Supabase Storage URLs are accessible
3. Restart Flutter app to refresh templates

---

## 📊 Current Status

| Component | Status | Notes |
|-----------|--------|-------|
| Backend API `/photo-templates/swapface` | ✅ Working | Loads 12 photos from 3 categories |
| Backend API `/photo-templates/story` | ⚠️ Empty | Bucket not created yet |
| SwapFace Flutter Integration | ✅ Working | Dynamically loads from API |
| Story Templates Flutter Integration | ✅ Ready | Will load once photos uploaded |
| Bucket `face-swap-templates` | ✅ Created | Female, male, mixed folders |
| Bucket `story-templates` | ❌ Not created | User needs to create + upload |

---

## 🚀 Next Steps

1. Create `story-templates` bucket in Supabase
2. Upload photos for each of the 13 categories
3. Test in Flutter app
4. Enjoy dynamic photo template loading! 🎉
