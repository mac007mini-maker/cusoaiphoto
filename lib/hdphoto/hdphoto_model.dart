import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'hdphoto_widget.dart' show HdphotoWidget;
import 'package:flutter/material.dart';
import 'dart:typed_data';

class HdphotoModel extends FlutterFlowModel<HdphotoWidget> {
  // Selected image from picker
  Uint8List? selectedImageBytes;
  String? selectedImagePath;
  
  // Processing state
  bool isProcessing = false;
  
  // Result image after HD enhancement
  String? resultImageBase64;
  
  // Error message
  String? errorMessage;
  
  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    selectedImageBytes = null;
    resultImageBase64 = null;
  }
}
