import 'dart:typed_data';
import 'package:flutter/material.dart';

class MuscleEnhanceModel {
  Uint8List? selectedUserPhoto;
  Uint8List? resultImage;
  bool isProcessing = false;
  String? errorMessage;
  String intensity = 'moderate';

  void dispose() {
    selectedUserPhoto = null;
    resultImage = null;
  }
}

