import '/flutter_flow/flutter_flow_model.dart';
import 'memoji_avatar_widget.dart' show MemojiAvatarWidget;
import 'dart:typed_data';
import 'package:flutter/material.dart';

class MemojiAvatarModel extends FlutterFlowModel<MemojiAvatarWidget> {
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

