import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/backend/supabase/face_swap_template_repository.dart';
import '/services/huggingface_service.dart';
import 'swapface_widget.dart' show SwapfaceWidget;
import 'package:flutter/material.dart';
import 'dart:typed_data';
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

class SwapfaceModel extends FlutterFlowModel<SwapfaceWidget> {
  final _repository = FaceSwapTemplateRepository();
  
  int selectedTabIndex = 0;
  
  // Face swap state
  StyleTemplate? selectedTemplate;
  Uint8List? selectedUserPhoto;
  String? resultImageBase64;
  bool isProcessing = false;
  String? errorMessage;

  // Template loading state
  bool isTemplatesLoading = true;
  String? templatesError;
  
  List<StyleTemplate> femaleStyles = [];
  List<StyleTemplate> maleStyles = [];
  List<StyleTemplate> mixedStyles = [];

  /// Load templates from Supabase Storage dynamically via API
  Future<void> loadTemplates() async {
    try {
      isTemplatesLoading = true;
      templatesError = null;
      
      final apiUrl = HuggingfaceService.aiBaseUrl;
      final response = await http.get(
        Uri.parse('$apiUrl/photo-templates/swapface'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final templates = Map<String, List<dynamic>>.from(data['templates']);
          
          // Parse female templates
          if (templates.containsKey('female')) {
            femaleStyles = (templates['female'] as List).map((item) {
              return StyleTemplate(
                name: item['name'] as String,
                imagePath: item['imagePath'] as String,
                category: 'female',
              );
            }).toList();
          }
          
          // Parse male templates
          if (templates.containsKey('male')) {
            maleStyles = (templates['male'] as List).map((item) {
              return StyleTemplate(
                name: item['name'] as String,
                imagePath: item['imagePath'] as String,
                category: 'male',
              );
            }).toList();
          }
          
          // Parse mixed templates
          if (templates.containsKey('mixed')) {
            mixedStyles = (templates['mixed'] as List).map((item) {
              return StyleTemplate(
                name: item['name'] as String,
                imagePath: item['imagePath'] as String,
                category: 'mixed',
              );
            }).toList();
          }
          
          isTemplatesLoading = false;
          print('✅ Loaded ${data['total_photos']} photos from ${data['categories'].length} categories (DYNAMIC)');
        } else {
          throw Exception(data['error'] ?? 'Failed to load templates');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      isTemplatesLoading = false;
      templatesError = e.toString();
      print('❌ Error loading SwapFace templates: $e');
    }
  }

  /// Get all templates (combined list for carousel)
  List<StyleTemplate> get allTemplates {
    return [...femaleStyles, ...maleStyles, ...mixedStyles];
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
