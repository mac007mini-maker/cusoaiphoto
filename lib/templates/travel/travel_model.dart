import '/flutter_flow/flutter_flow_util.dart';
import 'travel_widget.dart' show TravelWidget;
import 'package:flutter/material.dart';
import 'dart:typed_data';
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

class TravelModel extends FlutterFlowModel<TravelWidget> {
  int selectedTabIndex = 0;
  
  // Face swap state
  StyleTemplate? selectedTemplate;
  Uint8List? selectedUserPhoto;
  Uint8List? resultImageBytes;
  bool isProcessing = false;
  String? errorMessage;

  // Template loading state
  bool isTemplatesLoading = true;
  String? templatesError;
  
  List<StyleTemplate> travelStyles = [];

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
          
          final category = 'travel';
          if (templates.containsKey(category)) {
            travelStyles = (templates[category] as List).map((item) {
              return StyleTemplate(
                name: item['name'] as String,
                imagePath: item['imagePath'] as String,
                category: category,
              );
            }).toList();
          }
          
          isTemplatesLoading = false;
          print('✅ Loaded ${templates[category]?.length ?? 0} $category templates (DYNAMIC)');
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

  /// Get all templates
  List<StyleTemplate> get allTemplates {
    return travelStyles;
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
