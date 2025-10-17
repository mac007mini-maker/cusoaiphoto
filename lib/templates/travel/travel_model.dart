import '/flutter_flow/flutter_flow_util.dart';
import 'travel_widget.dart' show TravelWidget;
import 'package:flutter/material.dart';
import 'dart:typed_data';

class StyleTemplate {
  final String name;
  final String imagePath;
  final String category;

  StyleTemplate({
    required this.name,
    required this.imagePath,
    required this.category,
  });
}

class TravelModel extends FlutterFlowModel<TravelWidget> {
  int selectedTabIndex = 0;
  
  // Face swap state
  StyleTemplate? selectedTemplate;
  Uint8List? selectedUserPhoto;
  String? resultImageBase64;
  bool isProcessing = false;
  String? errorMessage;

  // Template loading state
  bool isTemplatesLoading = true;
  String? templatesError;
  
  List<StyleTemplate> travelStyles = [];

  /// Load travel templates with placeholder images
  Future<void> loadTemplates() async {
    try {
      isTemplatesLoading = true;
      templatesError = null;
      
      // Placeholder images from Unsplash (free to use)
      travelStyles = [
        StyleTemplate(
          name: 'Eiffel Tower',
          imagePath: 'https://images.unsplash.com/photo-1511739001486-6bfe10ce785f?w=800',
          category: 'travel',
        ),
        StyleTemplate(
          name: 'Beach Paradise',
          imagePath: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
          category: 'travel',
        ),
        StyleTemplate(
          name: 'Mountain Adventure',
          imagePath: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
          category: 'travel',
        ),
        StyleTemplate(
          name: 'City Explorer',
          imagePath: 'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=800',
          category: 'travel',
        ),
        StyleTemplate(
          name: 'Desert Journey',
          imagePath: 'https://images.unsplash.com/photo-1473496169904-658ba7c44d8a?w=800',
          category: 'travel',
        ),
        StyleTemplate(
          name: 'Tropical Island',
          imagePath: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800',
          category: 'travel',
        ),
      ];
      
      isTemplatesLoading = false;
    } catch (e) {
      isTemplatesLoading = false;
      templatesError = e.toString();
      print('Error loading travel templates: $e');
    }
  }

  /// Get all templates
  List<StyleTemplate> get allTemplates {
    return travelStyles;
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
