import '/flutter_flow/flutter_flow_util.dart';
import 'fixoldphoto_widget.dart' show FixoldphotoWidget;
import 'package:flutter/material.dart';

class FixoldphotoModel extends FlutterFlowModel<FixoldphotoWidget> {
  Uint8List? uploadedImageBytes;
  String? uploadedImageName;
  String? restoredImageBase64;
  bool isProcessing = false;
  String? errorMessage;
  String selectedVersion = 'v1.3';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  void setUploadedImage(Uint8List? bytes, String? name) {
    uploadedImageBytes = bytes;
    uploadedImageName = name;
    restoredImageBase64 = null;
    errorMessage = null;
  }

  void setRestoredImage(String base64Image) {
    restoredImageBase64 = base64Image;
    errorMessage = null;
  }

  void setProcessing(bool processing) {
    isProcessing = processing;
  }

  void setError(String error) {
    errorMessage = error;
    isProcessing = false;
  }

  void setVersion(String version) {
    selectedVersion = version;
  }

  void reset() {
    uploadedImageBytes = null;
    uploadedImageName = null;
    restoredImageBase64 = null;
    isProcessing = false;
    errorMessage = null;
    selectedVersion = 'v1.3';
  }
}
