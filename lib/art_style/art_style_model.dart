import 'dart:typed_data';
import 'package:flutter/material.dart';

class ArtStyleModel {
  Uint8List? selectedUserPhoto;
  Uint8List? resultImage;
  bool isProcessing = false;
  String? errorMessage;
  String selectedStyle = 'mosaic';

  void dispose() {
    selectedUserPhoto = null;
    resultImage = null;
  }
}

