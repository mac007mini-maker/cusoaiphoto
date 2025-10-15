import '/flutter_flow/flutter_flow_util.dart';
import 'ai_test_widget.dart' show AiTestWidget;
import 'package:flutter/material.dart';

class AiTestModel extends FlutterFlowModel<AiTestWidget> {
  final unfocusNode = FocusNode();
  
  TextEditingController? textPromptController;
  String? textPromptControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Please enter a prompt';
    }
    return null;
  }

  TextEditingController? imagePromptController;
  String? imagePromptControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Please enter a prompt';
    }
    return null;
  }

  bool isLoadingText = false;
  String generatedText = '';
  String textError = '';

  bool isLoadingImage = false;
  String generatedImageUrl = '';
  String imageError = '';

  @override
  void initState(BuildContext context) {
    textPromptController = TextEditingController();
    imagePromptController = TextEditingController();
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    textPromptController?.dispose();
    imagePromptController?.dispose();
  }
}
