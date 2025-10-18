import '/flutter_flow/flutter_flow_model.dart';
import 'video_swap_widget.dart' show VideoSwapWidget;
import 'dart:typed_data';
import 'package:flutter/material.dart';

class VideoSwapModel extends FlutterFlowModel<VideoSwapWidget> {
  // User's selected photo
  Uint8List? selectedUserPhoto;
  
  // Selected video template
  Map<String, dynamic>? selectedTemplate;
  
  // Result video URL
  String? resultVideoUrl;
  
  // Processing state
  bool isProcessing = false;
  double processingProgress = 0.0;
  String processingMessage = 'Starting video swap...';
  
  // Video templates loaded from Supabase
  Map<String, List<Map<String, dynamic>>> videoTemplates = {};
  bool isLoadingTemplates = true;
  
  // Error handling
  String? errorMessage;
  
  // Fun facts for loading screen
  final List<String> funFacts = [
    '💡 Video face swap uses advanced AI neural networks',
    '⭐ Best results come from well-lit, front-facing photos',
    '🎭 This technology powers visual effects in Hollywood movies!',
    '🎬 Processing your video frame by frame...',
    '✨ AI is analyzing facial features and expressions',
    '🎨 Creating seamless face transitions across frames',
    '⚡ Our AI processes thousands of images per second',
    '🌟 Pro tip: Smile naturally for the best results!',
  ];
  
  int currentFactIndex = 0;
  
  String getRandomFunFact() {
    currentFactIndex = (currentFactIndex + 1) % funFacts.length;
    return funFacts[currentFactIndex];
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    selectedUserPhoto = null;
    selectedTemplate = null;
    resultVideoUrl = null;
  }
}
