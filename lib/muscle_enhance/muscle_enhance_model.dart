import '/flutter_flow/flutter_flow_model.dart';
import 'muscle_enhance_widget.dart' show MuscleEnhanceWidget;
import 'dart:typed_data';
import 'package:flutter/material.dart';

class MuscleEnhanceModel extends FlutterFlowModel<MuscleEnhanceWidget> {
  Uint8List? selectedUserPhoto;
  Uint8List? resultImage;
  bool isProcessing = false;
  String? errorMessage;
  String intensity = 'moderate';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    selectedUserPhoto = null;
    resultImage = null;
  }
}

