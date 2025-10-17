import '/flutter_flow/flutter_flow_util.dart';
import 'christmas_widget.dart' show ChristmasWidget;
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

class ChristmasModel extends FlutterFlowModel<ChristmasWidget> {
  int selectedTabIndex = 0;
  
  StyleTemplate? selectedTemplate;
  Uint8List? selectedUserPhoto;
  String? resultImageBase64;
  bool isProcessing = false;
  String? errorMessage;
  bool isTemplatesLoading = true;
  String? templatesError;
  
  List<StyleTemplate> christmasStyles = [];

  Future<void> loadTemplates() async {
    try {
      isTemplatesLoading = true;
      templatesError = null;
      
      christmasStyles = [
        StyleTemplate(
          name: 'Santa Claus',
          imagePath: 'https://images.unsplash.com/photo-1512909006721-3d6018887383?w=800',
          category: 'christmas',
        ),
        StyleTemplate(
          name: 'Christmas Spirit',
          imagePath: 'https://images.unsplash.com/photo-1543589077-47d81606c1bf?w=800',
          category: 'christmas',
        ),
        StyleTemplate(
          name: 'Winter Holiday',
          imagePath: 'https://images.unsplash.com/photo-1576919228236-a097c32a5cd4?w=800',
          category: 'christmas',
        ),
        StyleTemplate(
          name: 'Festive Cheer',
          imagePath: 'https://images.unsplash.com/photo-1482517967863-00e15c9b44be?w=800',
          category: 'christmas',
        ),
        StyleTemplate(
          name: 'Holiday Magic',
          imagePath: 'https://images.unsplash.com/photo-1544273677-c433136021de?w=800',
          category: 'christmas',
        ),
      ];
      
      isTemplatesLoading = false;
    } catch (e) {
      isTemplatesLoading = false;
      templatesError = e.toString();
    }
  }

  List<StyleTemplate> get allTemplates => christmasStyles;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
