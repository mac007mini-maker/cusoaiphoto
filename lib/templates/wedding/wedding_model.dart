import '/flutter_flow/flutter_flow_util.dart';
import 'wedding_widget.dart' show WeddingWidget;
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

class WeddingModel extends FlutterFlowModel<WeddingWidget> {
  int selectedTabIndex = 0;
  
  StyleTemplate? selectedTemplate;
  Uint8List? selectedUserPhoto;
  String? resultImageBase64;
  bool isProcessing = false;
  String? errorMessage;
  bool isTemplatesLoading = true;
  String? templatesError;
  
  List<StyleTemplate> weddingStyles = [];

  Future<void> loadTemplates() async {
    try {
      isTemplatesLoading = true;
      templatesError = null;
      
      weddingStyles = [
        StyleTemplate(
          name: 'Bride Elegance',
          imagePath: 'https://images.unsplash.com/photo-1519741497674-611481863552?w=800',
          category: 'wedding',
        ),
        StyleTemplate(
          name: 'Groom Style',
          imagePath: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800',
          category: 'wedding',
        ),
        StyleTemplate(
          name: 'Wedding Day',
          imagePath: 'https://images.unsplash.com/photo-1606800052052-a08af7148866?w=800',
          category: 'wedding',
        ),
        StyleTemplate(
          name: 'Royal Wedding',
          imagePath: 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=800',
          category: 'wedding',
        ),
        StyleTemplate(
          name: 'Dream Ceremony',
          imagePath: 'https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?w=800',
          category: 'wedding',
        ),
      ];
      
      isTemplatesLoading = false;
    } catch (e) {
      isTemplatesLoading = false;
      templatesError = e.toString();
    }
  }

  List<StyleTemplate> get allTemplates => weddingStyles;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
