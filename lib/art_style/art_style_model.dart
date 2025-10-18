import '/flutter_flow/flutter_flow_model.dart';
import 'art_style_widget.dart' show ArtStyleWidget;
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ArtStyleModel extends FlutterFlowModel<ArtStyleWidget> {
  Uint8List? selectedUserPhoto;
  Uint8List? resultImage;
  bool isProcessing = false;
  String? errorMessage;
  String selectedStyle = 'mosaic';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    selectedUserPhoto = null;
    resultImage = null;
  }
}

