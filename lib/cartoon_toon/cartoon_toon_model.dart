import '/flutter_flow/flutter_flow_model.dart';
import 'cartoon_toon_widget.dart' show CartoonToonWidget;
import 'dart:typed_data';
import 'package:flutter/material.dart';

class CartoonToonModel extends FlutterFlowModel<CartoonToonWidget> {
  Uint8List? selectedUserPhoto;
  Uint8List? resultImage;
  bool isProcessing = false;
  String? errorMessage;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    selectedUserPhoto = null;
    resultImage = null;
  }
}
