import '/flutter_flow/flutter_flow_util.dart';
import 'selfie_widget.dart' show SelfieWidget;
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

class SelfieModel extends FlutterFlowModel<SelfieWidget> {
  int selectedTabIndex = 0;
  
  StyleTemplate? selectedTemplate;
  Uint8List? selectedUserPhoto;
  String? resultImageBase64;
  bool isProcessing = false;
  String? errorMessage;
  bool isTemplatesLoading = true;
  String? templatesError;
  
  List<StyleTemplate> selfieStyles = [];

  Future<void> loadTemplates() async {
    try {
      isTemplatesLoading = true;
      templatesError = null;
      
      selfieStyles = [
        StyleTemplate(
          name: 'Perfect Selfie',
          imagePath: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800',
          category: 'selfie',
        ),
        StyleTemplate(
          name: 'Candid Smile',
          imagePath: 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=800',
          category: 'selfie',
        ),
        StyleTemplate(
          name: 'Urban Selfie',
          imagePath: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800',
          category: 'selfie',
        ),
        StyleTemplate(
          name: 'Natural Beauty',
          imagePath: 'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=800',
          category: 'selfie',
        ),
        StyleTemplate(
          name: 'Stylish Portrait',
          imagePath: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=800',
          category: 'selfie',
        ),
      ];
      
      isTemplatesLoading = false;
    } catch (e) {
      isTemplatesLoading = false;
      templatesError = e.toString();
    }
  }

  List<StyleTemplate> get allTemplates => selfieStyles;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
