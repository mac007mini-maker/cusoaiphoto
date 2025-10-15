import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'homepage_widget.dart' show HomepageWidget;
import 'package:flutter/material.dart';

class HomepageModel extends FlutterFlowModel<HomepageWidget> {
  TextEditingController? feedbackController;
  TextEditingController? emailController;

  @override
  void initState(BuildContext context) {
    feedbackController = TextEditingController();
    emailController = TextEditingController();
  }

  @override
  void dispose() {
    feedbackController?.dispose();
    emailController?.dispose();
  }
}
