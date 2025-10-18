import 'dart:typed_data';
import 'package:flutter/material.dart';

class AnimalToonModel {
  Uint8List? selectedUserPhoto;
  Uint8List? resultImage;
  bool isProcessing = false;
  String? errorMessage;
  String selectedAnimal = 'bunny';

  void dispose() {
    selectedUserPhoto = null;
    resultImage = null;
  }
}

