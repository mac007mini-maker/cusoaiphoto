import '/flutter_flow/flutter_flow_util.dart';
import 'pro_widget.dart' show ProWidget;
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class ProModel extends FlutterFlowModel<ProWidget> {
  // State field(s) for this page.
  int? selectedPackageIndex;
  List<Package> availablePackages = [];
  bool isLoading = true;
  String? errorMessage;
  bool isWebPlatform = false; // Flag for web platform (RevenueCat not supported)

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
