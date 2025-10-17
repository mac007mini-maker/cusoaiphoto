import 'dart:convert';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/services/huggingface_service.dart';
import '/services/applovin_service.dart';
import '/services/admob_rewarded_service.dart';
import '/services/remote_config_service.dart';
import '/services/user_service.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'fixoldphoto_model.dart';
export 'fixoldphoto_model.dart';

class FixoldphotoWidget extends StatefulWidget {
  const FixoldphotoWidget({super.key});

  static String routeName = 'fixoldphoto';
  static String routePath = '/fixoldphoto';

  @override
  State<FixoldphotoWidget> createState() => _FixoldphotoWidgetState();
}

class _FixoldphotoWidgetState extends State<FixoldphotoWidget> {
  late FixoldphotoModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FixoldphotoModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _model.setUploadedImage(bytes, image.name);
        });
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _model.setUploadedImage(bytes, image.name);
        });
      }
    } catch (e) {
      _showError('Failed to capture image: $e');
    }
  }

  Future<void> _showAdAndRestore() async {
    if (_model.uploadedImageBytes == null) {
      _showError('Please upload a photo first');
      return;
    }

    final remoteConfig = RemoteConfigService();
    final userService = UserService();
    
    // Check if user is premium or ads disabled
    if (userService.isPremiumUser || !remoteConfig.adsEnabled || !remoteConfig.rewardedAdsEnabled) {
      debugPrint('🚫 User is premium or ads disabled - proceeding directly');
      _restorePhoto();
      return;
    }

    // Show rewarded ad for FREE users
    final preferredNetwork = remoteConfig.rewardedAdNetwork.toLowerCase();
    debugPrint('📺 Rewarded ad network preference: $preferredNetwork');

    if (preferredNetwork == 'applovin') {
      await AppLovinService.showRewardedAd(
        onComplete: () {
          debugPrint('✅ AppLovin ad watched - restoring old photo');
          _restorePhoto();
        },
        onFailed: () {
          debugPrint('❌ AppLovin ad failed');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⏳ Ads not ready yet. Please try again in a moment.'),
              backgroundColor: Colors.orange,
            ),
          );
        },
      );
    } else if (preferredNetwork == 'admob') {
      await AdMobRewardedService.showRewardedAd(
        onComplete: () {
          debugPrint('✅ AdMob ad watched - restoring old photo');
          _restorePhoto();
        },
        onFailed: () {
          debugPrint('❌ AdMob ad failed');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⏳ Ads not ready yet. Please try again in a moment.'),
              backgroundColor: Colors.orange,
            ),
          );
        },
      );
    } else {
      await AdMobRewardedService.showRewardedAd(
        onComplete: () {
          debugPrint('✅ AdMob ad watched - restoring old photo');
          _restorePhoto();
        },
        onFailed: () async {
          debugPrint('⚠️ AdMob ad failed - trying AppLovin fallback');
          await AppLovinService.showRewardedAd(
            onComplete: () {
              debugPrint('✅ AppLovin ad watched - restoring old photo');
              _restorePhoto();
            },
            onFailed: () {
              debugPrint('❌ Both AdMob and AppLovin ads failed');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('⏳ Ads not ready yet. Please try again in a moment.'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
          );
        },
      );
    }
  }

  Future<void> _restorePhoto() async {
    if (_model.uploadedImageBytes == null) {
      _showError('Please upload a photo first');
      return;
    }

    setState(() {
      _model.restoredImageBase64 = null;
      _model.errorMessage = null;
      _model.setProcessing(true);
    });

    try {
      final restoredImage = await HuggingfaceService.fixOldPhoto(
        imageBytes: _model.uploadedImageBytes!,
        version: _model.selectedVersion,
      );

      setState(() {
        _model.setRestoredImage(restoredImage);
        _model.setProcessing(false);
      });

      _showSuccess('Photo restored successfully!');
    } catch (e) {
      setState(() {
        _model.setError(e.toString());
      });
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderRadius: 20.0,
            buttonSize: 40.0,
            icon: Icon(
              Icons.arrow_back,
              color: Color(0xFF101828),
              size: 24.0,
            ),
            onPressed: () {
              context.safePop();
            },
          ),
          title: Text(
            FFLocalizations.of(context).getText(
              'iij9vkll' /* Fix Old Photo */,
            ),
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight: FontWeight.bold,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                  ),
                  color: Color(0xFF101828),
                  fontSize: 20.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                  fontStyle:
                      FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (_model.uploadedImageBytes == null && _model.restoredImageBase64 == null)
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 175.0,
                              height: 450.0,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: Image.asset(
                                    'assets/images/qn3pgr.png',
                                  ).image,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            Container(
                              width: 175.0,
                              height: 450.0,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: Image.asset(
                                    'assets/images/himizl.png',
                                  ).image,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ].divide(SizedBox(width: 8.0)),
                        ),
                      
                      if (_model.uploadedImageBytes != null || _model.restoredImageBase64 != null)
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        'Original',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      if (_model.uploadedImageBytes != null)
                                        Container(
                                          width: 160,
                                          height: 200,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.grey),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.memory(
                                              _model.uploadedImageBytes!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Restored',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF9810FA),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        width: 160,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Color(0xFF9810FA)),
                                        ),
                                        child: _model.restoredImageBase64 != null
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: Image.memory(
                                                  base64Decode(
                                                    _model.restoredImageBase64!.split(',').last,
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : Center(
                                                child: _model.isProcessing
                                                    ? CircularProgressIndicator()
                                                    : Icon(
                                                        Icons.auto_fix_high,
                                                        size: 48,
                                                        color: Colors.grey,
                                                      ),
                                              ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Model Version',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildVersionChip('v1.2'),
                                        _buildVersionChip('v1.3'),
                                        _buildVersionChip('v1.4'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                              FFButtonWidget(
                                onPressed: _model.isProcessing ? null : _showAdAndRestore,
                                text: _model.isProcessing ? 'Processing...' : 'Watch Ad & Restore Photo',
                                options: FFButtonOptions(
                                  width: double.infinity,
                                  height: 50,
                                  color: Color(0xFF9810FA),
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            FFLocalizations.of(context).getText(
                              'x56fi9fi' /* Add Your Photo */,
                            ),
                            style:
                                FlutterFlowTheme.of(context).headlineMedium.override(
                                      font: GoogleFonts.interTight(
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .headlineMedium
                                            .fontStyle,
                                      ),
                                      color: Color(0xFF101828),
                                      fontSize: 20.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .headlineMedium
                                          .fontStyle,
                                    ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: _pickImageFromGallery,
                                child: Container(
                                  width: 150.0,
                                  height: 80.0,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF9810FA),
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.photo_library,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          size: 32.0,
                                        ),
                                        Text(
                                          FFLocalizations.of(context).getText(
                                            '5p1t8vtr' /* Photos */,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.normal,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color: FlutterFlowTheme.of(context)
                                                    .secondaryBackground,
                                                fontSize: 16.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.normal,
                                                fontStyle: FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                              ),
                                        ),
                                      ].divide(SizedBox(height: 8.0)),
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: _pickImageFromCamera,
                                child: Container(
                                  width: 150.0,
                                  height: 80.0,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF6339A),
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.camera_alt,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          size: 32.0,
                                        ),
                                        Text(
                                          FFLocalizations.of(context).getText(
                                            '0den3z0s' /* Camera */,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.normal,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color: FlutterFlowTheme.of(context)
                                                    .secondaryBackground,
                                                fontSize: 16.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.normal,
                                                fontStyle: FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                              ),
                                        ),
                                      ].divide(SizedBox(height: 8.0)),
                                    ),
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(width: 15.0)),
                          ),
                        ].divide(SizedBox(height: 20.0)),
                      ),
                    ]
                        .divide(SizedBox(height: 16.0))
                        .addToEnd(SizedBox(height: 100.0)),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 50.0,
                decoration: BoxDecoration(
                  color: Colors.black,
                ),
                child: Center(
                  child: Text(
                    'Ad Loading...',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(),
                          color: Colors.white,
                          fontSize: 14.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 4.0,
                      color: Color(0x33000000),
                      offset: Offset(0.0, -2.0),
                    )
                  ],
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 20.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () async {
                          context.pushNamed(HomepageWidget.routeName);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.home,
                              color: Color(0xFF6B7280),
                              size: 24.0,
                            ),
                            Text(
                              'Home',
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    font: GoogleFonts.inter(),
                                    color: Color(0xFF6B7280),
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          context.pushNamed(AitoolsWidget.routeName);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: Color(0xFF6B7280),
                              size: 24.0,
                            ),
                            Text(
                              'AI Tools',
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    font: GoogleFonts.inter(),
                                    color: Color(0xFF6B7280),
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          context.pushNamed(MineWidget.routeName);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person,
                              color: Color(0xFF6B7280),
                              size: 24.0,
                            ),
                            Text(
                              'Mine',
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    font: GoogleFonts.inter(),
                                    color: Color(0xFF6B7280),
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersionChip(String version) {
    final isSelected = _model.selectedVersion == version;
    return GestureDetector(
      onTap: () {
        setState(() {
          _model.setVersion(version);
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF9810FA) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          version,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
