import '/flutter_flow/flutter_flow_util.dart';
import 'sport_widget.dart' show SportWidget;
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

class SportModel extends FlutterFlowModel<SportWidget> {
  int selectedTabIndex = 0;
  
  StyleTemplate? selectedTemplate;
  Uint8List? selectedUserPhoto;
  String? resultImageBase64;
  bool isProcessing = false;
  String? errorMessage;
  bool isTemplatesLoading = true;
  String? templatesError;
  
  List<StyleTemplate> sportStyles = [];

  Future<void> loadTemplates() async {
    try {
      isTemplatesLoading = true;
      templatesError = null;
      
      sportStyles = [
        StyleTemplate(
          name: 'Soccer Star',
          imagePath: 'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=800',
          category: 'sport',
        ),
        StyleTemplate(
          name: 'Basketball Pro',
          imagePath: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=800',
          category: 'sport',
        ),
        StyleTemplate(
          name: 'Tennis Champion',
          imagePath: 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?w=800',
          category: 'sport',
        ),
        StyleTemplate(
          name: 'Running Hero',
          imagePath: 'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=800',
          category: 'sport',
        ),
        StyleTemplate(
          name: 'Sports Elite',
          imagePath: 'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=800',
          category: 'sport',
        ),
      ];
      
      isTemplatesLoading = false;
    } catch (e) {
      isTemplatesLoading = false;
      templatesError = e.toString();
    }
  }

  List<StyleTemplate> get allTemplates => sportStyles;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
