import '/flutter_flow/flutter_flow_util.dart';
import 'tattoo_widget.dart' show TattooWidget;
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

class TattooModel extends FlutterFlowModel<TattooWidget> {
  int selectedTabIndex = 0;
  
  StyleTemplate? selectedTemplate;
  Uint8List? selectedUserPhoto;
  String? resultImageBase64;
  bool isProcessing = false;
  String? errorMessage;
  bool isTemplatesLoading = true;
  String? templatesError;
  
  List<StyleTemplate> tattooStyles = [];

  Future<void> loadTemplates() async {
    try {
      isTemplatesLoading = true;
      templatesError = null;
      
      tattooStyles = [
        StyleTemplate(
          name: 'Arm Tattoo Art',
          imagePath: 'https://images.unsplash.com/photo-1611501275019-9b5cda994e8d?w=800',
          category: 'tattoo',
        ),
        StyleTemplate(
          name: 'Sleeve Design',
          imagePath: 'https://images.unsplash.com/photo-1565058379802-bbe93b2f703f?w=800',
          category: 'tattoo',
        ),
        StyleTemplate(
          name: 'Ink Master',
          imagePath: 'https://images.unsplash.com/photo-1598371839696-5c5bb00bdc28?w=800',
          category: 'tattoo',
        ),
        StyleTemplate(
          name: 'Body Art',
          imagePath: 'https://images.unsplash.com/photo-1590246814883-57c511b416d6?w=800',
          category: 'tattoo',
        ),
        StyleTemplate(
          name: 'Tattoo Style',
          imagePath: 'https://images.unsplash.com/photo-1551847812-ff3e8f4c22a6?w=800',
          category: 'tattoo',
        ),
      ];
      
      isTemplatesLoading = false;
    } catch (e) {
      isTemplatesLoading = false;
      templatesError = e.toString();
    }
  }

  List<StyleTemplate> get allTemplates => tattooStyles;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
