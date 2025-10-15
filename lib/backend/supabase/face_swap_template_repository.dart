import 'package:supabase_flutter/supabase_flutter.dart';

class FaceSwapTemplate {
  final String name;
  final String imageUrl;
  final String category; // 'female', 'male', or 'mixed'

  FaceSwapTemplate({
    required this.name,
    required this.imageUrl,
    required this.category,
  });
}

class FaceSwapTemplateRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _bucketName = 'face-swap-templates';

  /// Fetch templates from a specific category folder
  Future<List<FaceSwapTemplate>> fetchTemplatesByCategory(String category) async {
    try {
      // List all files in the category folder
      final files = await _supabase.storage
          .from(_bucketName)
          .list(path: category);

      // Filter image files and create template objects
      final templates = files
          .where((file) => _isImageFile((file as dynamic).name))
          .map((file) {
            final fileObj = file as dynamic;
            final imageUrl = _supabase.storage
                .from(_bucketName)
                .getPublicUrl('$category/${fileObj.name}');
            
            return FaceSwapTemplate(
              name: _formatDisplayName(fileObj.name),
              imageUrl: imageUrl,
              category: category,
            );
          })
          .toList();

      // Sort alphabetically by name
      templates.sort((a, b) => a.name.compareTo(b.name));

      return templates;
    } catch (e) {
      throw Exception('Failed to fetch $category templates: $e');
    }
  }

  /// Fetch all templates from all categories
  Future<Map<String, List<FaceSwapTemplate>>> fetchAllTemplates() async {
    try {
      final categories = ['female', 'male', 'mixed'];
      final Map<String, List<FaceSwapTemplate>> allTemplates = {};

      for (final category in categories) {
        allTemplates[category] = await fetchTemplatesByCategory(category);
      }

      return allTemplates;
    } catch (e) {
      throw Exception('Failed to fetch templates: $e');
    }
  }

  /// Check if file is an image
  bool _isImageFile(String filename) {
    final ext = filename.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'webp'].contains(ext);
  }

  /// Format filename to display name (remove extension, capitalize)
  String _formatDisplayName(String filename) {
    final nameWithoutExt = filename.split('.').first;
    return nameWithoutExt
        .split('_')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
