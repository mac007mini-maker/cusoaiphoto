import 'dart:typed_data';
import 'package:flutter/material.dart';

class CartoonToonModel {
  Uint8List? selectedUserPhoto;
  Uint8List? resultImage;
  bool isProcessing = false;
  String? errorMessage;

  void dispose() {
    selectedUserPhoto = null;
    resultImage = null;
  }
}
