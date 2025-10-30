import '/flutter_flow/flutter_flow_util.dart';
import 'kie_nano_banana_widget.dart' show KieNanoBananaWidget;
import 'package:flutter/material.dart';

class KieNanoBananaModel extends FlutterFlowModel<KieNanoBananaWidget> {
  FocusNode? promptFocusNode;
  TextEditingController? promptController;
  TextEditingController? referenceImagesController;

  bool isProcessing = false;
  String? errorMessage;
  String? infoMessage;
  String? lastPrompt;

  String outputFormat = 'png';
  String imageSize = '1:1';

  Uint8List? generatedImageBytes;
  String? generatedImageDataUri;
  String? generatedImageUrl;

  @override
  void initState(BuildContext context) {
    promptFocusNode = FocusNode();
    promptController = TextEditingController();
    referenceImagesController = TextEditingController();
  }

  @override
  void dispose() {
    promptFocusNode?.dispose();
    promptController?.dispose();
    referenceImagesController?.dispose();
  }

  void setProcessing(bool value) {
    isProcessing = value;
  }

  void setError(String error) {
    errorMessage = error;
    infoMessage = null;
    generatedImageBytes = null;
    generatedImageDataUri = null;
    generatedImageUrl = null;
  }

  void setInfo(String? message) {
    infoMessage = message;
  }

  void setResult({
    Uint8List? bytes,
    String? dataUri,
    String? url,
    String? prompt,
  }) {
    generatedImageBytes = bytes;
    generatedImageDataUri = dataUri;
    generatedImageUrl = url;
    errorMessage = null;
    infoMessage = null;
    lastPrompt = prompt;
  }

  void resetResult() {
    generatedImageBytes = null;
    generatedImageDataUri = null;
    generatedImageUrl = null;
    errorMessage = null;
    infoMessage = null;
  }

  List<String> get parsedReferenceUrls {
    final text = referenceImagesController?.text ?? '';
    return text
        .split(RegExp(r'[\s,\n]+'))
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .toList();
  }
}
