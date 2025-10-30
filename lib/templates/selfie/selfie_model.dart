import '/flutter_flow/flutter_flow_util.dart';
import 'selfie_widget.dart' show SelfieWidget;
import 'package:flutter/material.dart';
import '/services/huggingface_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  Uint8List? resultImageBytes;
  bool isProcessing = false;
  String? errorMessage;
  bool isTemplatesLoading = true;
  String? templatesError;

  List<StyleTemplate> selfieStyles = [];

  Future<void> loadTemplates() async {
    try {
      isTemplatesLoading = true;
      templatesError = null;

      final apiUrl = HuggingfaceService.aiBaseUrl;
      final response = await http.get(
        Uri.parse('$apiUrl/photo-templates/story'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final templates = Map<String, List<dynamic>>.from(data['templates']);

          final category = 'selfie';
          if (templates.containsKey(category)) {
            selfieStyles = (templates[category] as List).map((item) {
              return StyleTemplate(
                name: item['name'] as String,
                imagePath: item['imagePath'] as String,
                category: category,
              );
            }).toList();
          }

          isTemplatesLoading = false;
          print(
            '✅ Loaded ${templates[category]?.length ?? 0} $category templates (DYNAMIC)',
          );
        } else {
          throw Exception(data['error'] ?? 'Failed to load templates');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      isTemplatesLoading = false;
      templatesError = e.toString();
      print('❌ Error loading templates: $e');
    }
  }

  List<StyleTemplate> get allTemplates => selfieStyles;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
