import '/flutter_flow/flutter_flow_model.dart';
import 'animal_toon_widget.dart' show AnimalToonWidget;
import 'dart:typed_data';
import 'package:flutter/material.dart';

class AnimalToonModel extends FlutterFlowModel<AnimalToonWidget> {
  Uint8List? selectedUserPhoto;
  Uint8List? resultImage;
  bool isProcessing = false;
  String? errorMessage;
  String selectedAnimal = 'bunny';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    selectedUserPhoto = null;
    resultImage = null;
  }
}

