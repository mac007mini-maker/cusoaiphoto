import '/flutter_flow/flutter_flow_util.dart';
import 'school_widget.dart' show SchoolWidget;
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

class SchoolModel extends FlutterFlowModel<SchoolWidget> {
  int selectedTabIndex = 0;
  
  StyleTemplate? selectedTemplate;
  Uint8List? selectedUserPhoto;
  String? resultImageBase64;
  bool isProcessing = false;
  String? errorMessage;
  bool isTemplatesLoading = true;
  String? templatesError;
  
  List<StyleTemplate> schoolStyles = [];

  Future<void> loadTemplates() async {
    try {
      isTemplatesLoading = true;
      templatesError = null;
      
      schoolStyles = [
        StyleTemplate(
          name: 'Graduation Day',
          imagePath: 'https://images.unsplash.com/photo-1523580494863-6f3031224c94?w=800',
          category: 'school',
        ),
        StyleTemplate(
          name: 'Student Life',
          imagePath: 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=800',
          category: 'school',
        ),
        StyleTemplate(
          name: 'Campus Style',
          imagePath: 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800',
          category: 'school',
        ),
        StyleTemplate(
          name: 'Academic Achievement',
          imagePath: 'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=800',
          category: 'school',
        ),
        StyleTemplate(
          name: 'Scholar Portrait',
          imagePath: 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=800',
          category: 'school',
        ),
      ];
      
      isTemplatesLoading = false;
    } catch (e) {
      isTemplatesLoading = false;
      templatesError = e.toString();
    }
  }

  List<StyleTemplate> get allTemplates => schoolStyles;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
