import '/flutter_flow/flutter_flow_util.dart';
import 'birthday_widget.dart' show BirthdayWidget;
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

class BirthdayModel extends FlutterFlowModel<BirthdayWidget> {
  int selectedTabIndex = 0;
  
  StyleTemplate? selectedTemplate;
  Uint8List? selectedUserPhoto;
  String? resultImageBase64;
  bool isProcessing = false;
  String? errorMessage;
  bool isTemplatesLoading = true;
  String? templatesError;
  
  List<StyleTemplate> birthdayStyles = [];

  Future<void> loadTemplates() async {
    try {
      isTemplatesLoading = true;
      templatesError = null;
      
      birthdayStyles = [
        StyleTemplate(
          name: 'Birthday Party',
          imagePath: 'https://images.unsplash.com/photo-1513151233558-d860c5398176?w=800',
          category: 'birthday',
        ),
        StyleTemplate(
          name: 'Cake Celebration',
          imagePath: 'https://images.unsplash.com/photo-1464349095431-e9a21285b5f3?w=800',
          category: 'birthday',
        ),
        StyleTemplate(
          name: 'Birthday Fun',
          imagePath: 'https://images.unsplash.com/photo-1530103043960-ef38714abb15?w=800',
          category: 'birthday',
        ),
        StyleTemplate(
          name: 'Special Day',
          imagePath: 'https://images.unsplash.com/photo-1558636508-e0db3814bd1d?w=800',
          category: 'birthday',
        ),
        StyleTemplate(
          name: 'Birthday Joy',
          imagePath: 'https://images.unsplash.com/photo-1555353540-064ed58e4cc8?w=800',
          category: 'birthday',
        ),
      ];
      
      isTemplatesLoading = false;
    } catch (e) {
      isTemplatesLoading = false;
      templatesError = e.toString();
    }
  }

  List<StyleTemplate> get allTemplates => birthdayStyles;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
