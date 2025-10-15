# 📸 Supabase Storage Setup - Face Swap Templates

## Bước 1: Tạo Storage Bucket trong Supabase

1. Truy cập **Supabase Dashboard**: https://supabase.com/dashboard
2. Chọn project **lfeyveflpbkrzsoscjcv** (URL của bạn)
3. Vào **Storage** (menu bên trái)
4. Click **New Bucket**
   - **Name**: `face-swap-templates`
   - **Public**: ✅ Check (để Flutter app có thể download)
   - Click **Create bucket**

## Bước 2: Upload Template Images

### Cấu trúc thư mục:
```
face-swap-templates/
├── female/
│   ├── bedroom_aesthetic.jpg
│   ├── pink_vintage.jpg
│   ├── modern_outdoor.jpg
│   ├── street_fashion.jpg
│   ├── elegant_portrait.jpg
│   └── ngoctrinh_outfit.jpg
├── male/
│   ├── elegant_portrait.jpg
│   ├── business_suit.jpg
│   ├── casual_outdoor.jpg
│   ├── sport_style.jpg
│   └── vintage_classic.jpg
└── mixed/
    ├── couple_romantic.jpg
    ├── friend_group.jpg
    └── family_portrait.jpg
```

### Upload steps:
1. Trong bucket `face-swap-templates`
2. Tạo folders: `female`, `male`, `mixed`
3. Upload các hình template vào từng folder
4. **Lưu ý**: Đặt tên file chính xác theo danh sách trên

## Bước 3: Get Public URLs

Sau khi upload, mỗi template sẽ có public URL:
```
https://lfeyveflpbkrzsoscjcv.supabase.co/storage/v1/object/public/face-swap-templates/female/bedroom_aesthetic.jpg
```

**Pattern**: 
```
{SUPABASE_URL}/storage/v1/object/public/{bucket}/{folder}/{filename}
```

## Bước 4: Configure trong Flutter

### A. Tạo Template Model

Tạo file `lib/models/face_swap_template.dart`:

```dart
class FaceSwapTemplate {
  final String id;
  final String name;
  final String category; // 'female', 'male', 'mixed'
  final String imageUrl;
  final String fileName;

  FaceSwapTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.fileName,
  });

  // Supabase URL helper
  static String getSupabaseUrl(String fileName, String category) {
    const supabaseUrl = 'https://lfeyveflpbkrzsoscjcv.supabase.co';
    return '$supabaseUrl/storage/v1/object/public/face-swap-templates/$category/$fileName';
  }
}
```

### B. Define Templates List

Tạo file `lib/config/face_swap_templates.dart`:

```dart
import '../models/face_swap_template.dart';

class FaceSwapTemplates {
  static List<FaceSwapTemplate> femaleTemplates = [
    FaceSwapTemplate(
      id: 'bedroom_aesthetic',
      name: 'Bedroom Aesthetic',
      category: 'female',
      fileName: 'bedroom_aesthetic.jpg',
      imageUrl: FaceSwapTemplate.getSupabaseUrl('bedroom_aesthetic.jpg', 'female'),
    ),
    FaceSwapTemplate(
      id: 'pink_vintage',
      name: 'Pink Vintage',
      category: 'female',
      fileName: 'pink_vintage.jpg',
      imageUrl: FaceSwapTemplate.getSupabaseUrl('pink_vintage.jpg', 'female'),
    ),
    FaceSwapTemplate(
      id: 'elegant_portrait',
      name: 'Elegant Portrait',
      category: 'female',
      fileName: 'elegant_portrait.jpg',
      imageUrl: FaceSwapTemplate.getSupabaseUrl('elegant_portrait.jpg', 'female'),
    ),
    FaceSwapTemplate(
      id: 'street_fashion',
      name: 'Street Fashion',
      category: 'female',
      fileName: 'street_fashion.jpg',
      imageUrl: FaceSwapTemplate.getSupabaseUrl('street_fashion.jpg', 'female'),
    ),
    FaceSwapTemplate(
      id: 'modern_outdoor',
      name: 'Modern Outdoor',
      category: 'female',
      fileName: 'modern_outdoor.jpg',
      imageUrl: FaceSwapTemplate.getSupabaseUrl('modern_outdoor.jpg', 'female'),
    ),
    FaceSwapTemplate(
      id: 'ngoctrinh_outfit',
      name: 'Ngoctrinh Outfit',
      category: 'female',
      fileName: 'ngoctrinh_outfit.jpg',
      imageUrl: FaceSwapTemplate.getSupabaseUrl('ngoctrinh_outfit.jpg', 'female'),
    ),
  ];

  static List<FaceSwapTemplate> maleTemplates = [
    FaceSwapTemplate(
      id: 'elegant_portrait_male',
      name: 'Elegant Portrait',
      category: 'male',
      fileName: 'elegant_portrait.jpg',
      imageUrl: FaceSwapTemplate.getSupabaseUrl('elegant_portrait.jpg', 'male'),
    ),
    FaceSwapTemplate(
      id: 'business_suit',
      name: 'Business Suit',
      category: 'male',
      fileName: 'business_suit.jpg',
      imageUrl: FaceSwapTemplate.getSupabaseUrl('business_suit.jpg', 'male'),
    ),
    FaceSwapTemplate(
      id: 'casual_outdoor',
      name: 'Casual Outdoor',
      category: 'male',
      fileName: 'casual_outdoor.jpg',
      imageUrl: FaceSwapTemplate.getSupabaseUrl('casual_outdoor.jpg', 'male'),
    ),
    FaceSwapTemplate(
      id: 'sport_style',
      name: 'Sport Style',
      category: 'male',
      fileName: 'sport_style.jpg',
      imageUrl: FaceSwapTemplate.getSupabaseUrl('sport_style.jpg', 'male'),
    ),
    FaceSwapTemplate(
      id: 'vintage_classic',
      name: 'Vintage Classic',
      category: 'male',
      fileName: 'vintage_classic.jpg',
      imageUrl: FaceSwapTemplate.getSupabaseUrl('vintage_classic.jpg', 'male'),
    ),
  ];

  static List<FaceSwapTemplate> mixedTemplates = [
    FaceSwapTemplate(
      id: 'couple_romantic',
      name: 'Couple Romantic',
      category: 'mixed',
      fileName: 'couple_romantic.jpg',
      imageUrl: FaceSwapTemplate.getSupabaseUrl('couple_romantic.jpg', 'mixed'),
    ),
    FaceSwapTemplate(
      id: 'friend_group',
      name: 'Friend Group',
      category: 'mixed',
      fileName: 'friend_group.jpg',
      imageUrl: FaceSwapTemplate.getSupabaseUrl('friend_group.jpg', 'mixed'),
    ),
    FaceSwapTemplate(
      id: 'family_portrait',
      name: 'Family Portrait',
      category: 'mixed',
      fileName: 'family_portrait.jpg',
      imageUrl: FaceSwapTemplate.getSupabaseUrl('family_portrait.jpg', 'mixed'),
    ),
  ];

  static List<FaceSwapTemplate> getAllTemplates() {
    return [...femaleTemplates, ...maleTemplates, ...mixedTemplates];
  }
}
```

## Bước 5: Test Template URLs

Sau khi upload, test URL trong browser:
```
https://lfeyveflpbkrzsoscjcv.supabase.co/storage/v1/object/public/face-swap-templates/female/bedroom_aesthetic.jpg
```

Nếu hiển thị hình → Success! ✅

## Alternative: Hardcoded Assets (Nếu không dùng Supabase)

Nếu muốn lưu local trong Flutter app:

1. Copy template images vào `assets/images/face_swap_templates/`
2. Update `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/images/face_swap_templates/female/
    - assets/images/face_swap_templates/male/
    - assets/images/face_swap_templates/mixed/
```

3. Update template URLs:
```dart
imageUrl: 'assets/images/face_swap_templates/female/bedroom_aesthetic.jpg'
```

## 🔥 Recommended: Dùng Supabase Storage

**Ưu điểm**:
- ✅ Không làm tăng kích thước APK
- ✅ Dễ update templates mới (không cần rebuild app)
- ✅ Public CDN (load nhanh)
- ✅ Có thể thêm templates động

**Nhược điểm**:
- ⚠️ Cần internet để load lần đầu
- ⚠️ Dùng bandwidth Supabase (nhưng free tier đủ)

---

## Next Steps

Sau khi setup xong Supabase Storage:
1. ✅ Upload all template images
2. ✅ Test public URLs
3. ➡️ Update Flutter UI (Task 4)
4. ➡️ Implement Face Swap logic (Task 4)
5. ➡️ Add Download functionality (Task 5)
