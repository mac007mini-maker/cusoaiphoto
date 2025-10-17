import '/flutter_flow/flutter_flow_util.dart';
import 'profile_widget.dart' show ProfileWidget;
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

class ProfileModel extends FlutterFlowModel<ProfileWidget> {
  int selectedTabIndex = 0;
  
  StyleTemplate? selectedTemplate;
  Uint8List? selectedUserPhoto;
  String? resultImageBase64;
  bool isProcessing = false;
  String? errorMessage;
  bool isTemplatesLoading = true;
  String? templatesError;
  
  List<StyleTemplate> profileStyles = [];

  Future<void> loadTemplates() async {
    try {
      isTemplatesLoading = true;
      templatesError = null;
      
      profileStyles = [
        StyleTemplate(
          name: 'Professional Photo',
          imagePath: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800',
          category: 'profile',
        ),
        StyleTemplate(
          name: 'LinkedIn Portrait',
          imagePath: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800',
          category: 'profile',
        ),
        StyleTemplate(
          name: 'Headshot Pro',
          imagePath: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=800',
          category: 'profile',
        ),
        StyleTemplate(
          name: 'Business Profile',
          imagePath: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=800',
          category: 'profile',
        ),
        StyleTemplate(
          name: 'Corporate Portrait',
          imagePath: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=800',
          category: 'profile',
        ),
      ];
      
      isTemplatesLoading = false;
    } catch (e) {
      isTemplatesLoading = false;
      templatesError = e.toString();
    }
  }

  List<StyleTemplate> get allTemplates => profileStyles;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
