import '/flutter_flow/flutter_flow_util.dart';
import 'newyear_widget.dart' show NewyearWidget;
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

class NewyearModel extends FlutterFlowModel<NewyearWidget> {
  int selectedTabIndex = 0;
  
  StyleTemplate? selectedTemplate;
  Uint8List? selectedUserPhoto;
  String? resultImageBase64;
  bool isProcessing = false;
  String? errorMessage;
  bool isTemplatesLoading = true;
  String? templatesError;
  
  List<StyleTemplate> newyearStyles = [];

  Future<void> loadTemplates() async {
    try {
      isTemplatesLoading = true;
      templatesError = null;
      
      newyearStyles = [
        StyleTemplate(
          name: 'Party Celebration',
          imagePath: 'https://images.unsplash.com/photo-1467810563316-b5476525c0f9?w=800',
          category: 'newyear',
        ),
        StyleTemplate(
          name: 'Fireworks Night',
          imagePath: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800',
          category: 'newyear',
        ),
        StyleTemplate(
          name: 'New Beginning',
          imagePath: 'https://images.unsplash.com/photo-1530103043960-ef38714abb15?w=800',
          category: 'newyear',
        ),
        StyleTemplate(
          name: 'Countdown Fun',
          imagePath: 'https://images.unsplash.com/photo-1528605248644-14dd04022da1?w=800',
          category: 'newyear',
        ),
        StyleTemplate(
          name: 'NYE Glamour',
          imagePath: 'https://images.unsplash.com/photo-1482399865740-8c86508a3c6c?w=800',
          category: 'newyear',
        ),
      ];
      
      isTemplatesLoading = false;
    } catch (e) {
      isTemplatesLoading = false;
      templatesError = e.toString();
    }
  }

  List<StyleTemplate> get allTemplates => newyearStyles;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
