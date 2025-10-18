import 'dart:typed_data';
import 'package:flutter/material.dart';

class MemojiAvatarModel {
  Uint8List? selectedUserPhoto;
  Uint8List? resultImage;
  bool isProcessing = false;
  String? errorMessage;

  void dispose() {
    selectedUserPhoto = null;
    resultImage = null;
  }
}

MemojiAvatarModel createModel(BuildContext context, Function modelCreator) {
  return modelCreator();
}
