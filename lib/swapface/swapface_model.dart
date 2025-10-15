import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/backend/supabase/face_swap_template_repository.dart';
import 'swapface_widget.dart' show SwapfaceWidget;
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

class SwapfaceModel extends FlutterFlowModel<SwapfaceWidget> {
  final _repository = FaceSwapTemplateRepository();
  
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
  
  List<StyleTemplate> femaleStyles = [];
  List<StyleTemplate> maleStyles = [];
  List<StyleTemplate> mixedStyles = [];

  /// Load templates from Supabase Storage
  Future<void> loadTemplates() async {
    try {
      isTemplatesLoading = true;
      templatesError = null;
      
      // Fallback to hardcoded templates (Supabase Storage list() not supported on web)
      femaleStyles = [
        StyleTemplate(
          name: 'Beautiful Girl',
          imagePath: 'https://cvtlvrtvnwbvyhojetyt.supabase.co/storage/v1/object/public/face-swap-templates/female/beautiful-girl.jpg',
          category: 'female',
        ),
        StyleTemplate(
          name: 'Kate Upton',
          imagePath: 'https://cvtlvrtvnwbvyhojetyt.supabase.co/storage/v1/object/public/face-swap-templates/female/kate-upton.jpg',
          category: 'female',
        ),
        StyleTemplate(
          name: 'Nice Girl',
          imagePath: 'https://cvtlvrtvnwbvyhojetyt.supabase.co/storage/v1/object/public/face-swap-templates/female/nice-girl.jpg',
          category: 'female',
        ),
        StyleTemplate(
          name: 'USA Girl',
          imagePath: 'https://cvtlvrtvnwbvyhojetyt.supabase.co/storage/v1/object/public/face-swap-templates/female/usa-girl.jpg',
          category: 'female',
        ),
        StyleTemplate(
          name: 'Wedding Face',
          imagePath: 'https://cvtlvrtvnwbvyhojetyt.supabase.co/storage/v1/object/public/face-swap-templates/female/wedding-face.jpeg',
          category: 'female',
        ),
      ];

      maleStyles = [
        StyleTemplate(
          name: 'Aquaman',
          imagePath: 'https://cvtlvrtvnwbvyhojetyt.supabase.co/storage/v1/object/public/face-swap-templates/male/aquaman.jpg',
          category: 'male',
        ),
        StyleTemplate(
          name: 'Handsome',
          imagePath: 'https://cvtlvrtvnwbvyhojetyt.supabase.co/storage/v1/object/public/face-swap-templates/male/handsome.jpg',
          category: 'male',
        ),
        StyleTemplate(
          name: 'Superman',
          imagePath: 'https://cvtlvrtvnwbvyhojetyt.supabase.co/storage/v1/object/public/face-swap-templates/male/superman.jpg',
          category: 'male',
        ),
        StyleTemplate(
          name: 'Themen',
          imagePath: 'https://cvtlvrtvnwbvyhojetyt.supabase.co/storage/v1/object/public/face-swap-templates/male/themen.jpg',
          category: 'male',
        ),
      ];

      mixedStyles = [
        StyleTemplate(
          name: 'Beckham',
          imagePath: 'https://cvtlvrtvnwbvyhojetyt.supabase.co/storage/v1/object/public/face-swap-templates/mixed/beckham.jpg',
          category: 'mixed',
        ),
        StyleTemplate(
          name: 'Parka Clothing',
          imagePath: 'https://cvtlvrtvnwbvyhojetyt.supabase.co/storage/v1/object/public/face-swap-templates/mixed/parka-clothing.jpg',
          category: 'mixed',
        ),
      ];
      
      isTemplatesLoading = false;
    } catch (e) {
      isTemplatesLoading = false;
      templatesError = e.toString();
      print('Error loading templates: $e');
    }
  }

  /// Get all templates (combined list for carousel)
  List<StyleTemplate> get allTemplates {
    return [...femaleStyles, ...maleStyles, ...mixedStyles];
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
