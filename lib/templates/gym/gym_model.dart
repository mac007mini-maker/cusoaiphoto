import '/flutter_flow/flutter_flow_util.dart';
import 'gym_widget.dart' show GymWidget;
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

class GymModel extends FlutterFlowModel<GymWidget> {
  int selectedTabIndex = 0;
  
  StyleTemplate? selectedTemplate;
  Uint8List? selectedUserPhoto;
  String? resultImageBase64;
  bool isProcessing = false;
  String? errorMessage;
  bool isTemplatesLoading = true;
  String? templatesError;
  
  List<StyleTemplate> gymStyles = [];

  Future<void> loadTemplates() async {
    try {
      isTemplatesLoading = true;
      templatesError = null;
      
      gymStyles = [
        StyleTemplate(
          name: 'Fitness Model',
          imagePath: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
          category: 'gym',
        ),
        StyleTemplate(
          name: 'Athlete Power',
          imagePath: 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800',
          category: 'gym',
        ),
        StyleTemplate(
          name: 'Workout Champion',
          imagePath: 'https://images.unsplash.com/photo-1605296867304-46d5465a13f1?w=800',
          category: 'gym',
        ),
        StyleTemplate(
          name: 'Strong Fitness',
          imagePath: 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800',
          category: 'gym',
        ),
        StyleTemplate(
          name: 'CrossFit Hero',
          imagePath: 'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800',
          category: 'gym',
        ),
      ];
      
      isTemplatesLoading = false;
    } catch (e) {
      isTemplatesLoading = false;
      templatesError = e.toString();
    }
  }

  List<StyleTemplate> get allTemplates => gymStyles;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
