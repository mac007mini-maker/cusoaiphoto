import '/flutter_flow/flutter_flow_util.dart';
import 'suits_widget.dart' show SuitsWidget;
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

class SuitsModel extends FlutterFlowModel<SuitsWidget> {
  int selectedTabIndex = 0;
  
  StyleTemplate? selectedTemplate;
  Uint8List? selectedUserPhoto;
  String? resultImageBase64;
  bool isProcessing = false;
  String? errorMessage;
  bool isTemplatesLoading = true;
  String? templatesError;
  
  List<StyleTemplate> suitsStyles = [];

  Future<void> loadTemplates() async {
    try {
      isTemplatesLoading = true;
      templatesError = null;
      
      suitsStyles = [
        StyleTemplate(
          name: 'Executive Style',
          imagePath: 'https://images.unsplash.com/photo-1617127365659-c47fa864d8bc?w=800',
          category: 'suits',
        ),
        StyleTemplate(
          name: 'Business Suit',
          imagePath: 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=800',
          category: 'suits',
        ),
        StyleTemplate(
          name: 'Formal Attire',
          imagePath: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=800',
          category: 'suits',
        ),
        StyleTemplate(
          name: 'Tuxedo Elite',
          imagePath: 'https://images.unsplash.com/photo-1581044777550-4cfa60707c03?w=800',
          category: 'suits',
        ),
        StyleTemplate(
          name: 'Sharp Dressed',
          imagePath: 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=800',
          category: 'suits',
        ),
      ];
      
      isTemplatesLoading = false;
    } catch (e) {
      isTemplatesLoading = false;
      templatesError = e.toString();
    }
  }

  List<StyleTemplate> get allTemplates => suitsStyles;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
