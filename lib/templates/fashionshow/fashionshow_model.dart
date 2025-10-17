import '/flutter_flow/flutter_flow_util.dart';
import 'fashionshow_widget.dart' show FashionshowWidget;
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

class FashionshowModel extends FlutterFlowModel<FashionshowWidget> {
  int selectedTabIndex = 0;
  
  StyleTemplate? selectedTemplate;
  Uint8List? selectedUserPhoto;
  String? resultImageBase64;
  bool isProcessing = false;
  String? errorMessage;
  bool isTemplatesLoading = true;
  String? templatesError;
  
  List<StyleTemplate> fashionshowStyles = [];

  Future<void> loadTemplates() async {
    try {
      isTemplatesLoading = true;
      templatesError = null;
      
      fashionshowStyles = [
        StyleTemplate(
          name: 'Runway Model',
          imagePath: 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=800',
          category: 'fashionshow',
        ),
        StyleTemplate(
          name: 'Fashion Week',
          imagePath: 'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=800',
          category: 'fashionshow',
        ),
        StyleTemplate(
          name: 'Haute Couture',
          imagePath: 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=800',
          category: 'fashionshow',
        ),
        StyleTemplate(
          name: 'Catwalk Star',
          imagePath: 'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=800',
          category: 'fashionshow',
        ),
        StyleTemplate(
          name: 'Fashion Icon',
          imagePath: 'https://images.unsplash.com/photo-1445205170230-053b83016050?w=800',
          category: 'fashionshow',
        ),
      ];
      
      isTemplatesLoading = false;
    } catch (e) {
      isTemplatesLoading = false;
      templatesError = e.toString();
    }
  }

  List<StyleTemplate> get allTemplates => fashionshowStyles;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
