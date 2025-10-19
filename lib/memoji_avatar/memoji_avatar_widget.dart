import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/services/huggingface_service.dart';
import '/services/applovin_service.dart';
import '/services/admob_rewarded_service.dart';
import '/services/admob_banner_service.dart';
import '/services/remote_config_service.dart';
import '/services/usage_limit_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:gal/gal.dart';
import 'memoji_avatar_model.dart';
export 'memoji_avatar_model.dart';

class MemojiAvatarWidget extends StatefulWidget {
  const MemojiAvatarWidget({super.key});

  static String routeName = 'memoji_avatar';
  static String routePath = '/memoji-avatar';

  @override
  State<MemojiAvatarWidget> createState() => _MemojiAvatarWidgetState();
}

class _MemojiAvatarWidgetState extends State<MemojiAvatarWidget> {
  late MemojiAvatarModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MemojiAvatarModel());
    
    final remoteConfig = RemoteConfigService();
    if (remoteConfig.adsEnabled && remoteConfig.bannerAdsEnabled) {
      _loadBannerAd();
    }
  }

  @override
  void dispose() {
    _model.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    final adUnitId = AdMobBannerService.getBannerAdUnitId();
    if (adUnitId.isEmpty) return;
    
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() => _isBannerAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    _bannerAd?.load();
  }

  Future<void> _pickPhoto({ImageSource source = ImageSource.gallery}) async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (photo != null) {
      final bytes = await photo.readAsBytes();
      setState(() {
        _model.selectedUserPhoto = bytes;
        _model.resultImage = null;
        _model.errorMessage = null;
      });
    }
  }

  Future<void> _showAdAndProcess() async {
    if (_model.selectedUserPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add your photo first')),
      );
      return;
    }

    final canProcess = await UsageLimitService.canProcessSwap();
    if (!canProcess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⏰ Daily limit reached (20/day for premium users). Resets tomorrow!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    final remoteConfig = RemoteConfigService();
    
    if (!remoteConfig.adsEnabled || !remoteConfig.rewardedAdsEnabled) {
      _processImage();
      return;
    }

    final preferredNetwork = remoteConfig.rewardedAdNetwork.toLowerCase();

    if (preferredNetwork == 'applovin') {
      await AppLovinService.showRewardedAd(
        onComplete: _processImage,
        onFailed: () {
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
        onComplete: _processImage,
        onFailed: () {
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
        onComplete: _processImage,
        onFailed: () async {
          await AppLovinService.showRewardedAd(
            onComplete: _processImage,
            onFailed: () {
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

  Future<void> _processImage() async {
    if (_model.selectedUserPhoto == null) return;

    setState(() {
      _model.isProcessing = true;
      _model.errorMessage = null;
    });

    try {
      await UsageLimitService.incrementSwapCount();
      
      final String base64Image = base64Encode(_model.selectedUserPhoto!);
      
      final apiDomain = String.fromEnvironment(
        'API_DOMAIN',
        defaultValue: 'web-production-a7698.up.railway.app',
      );
      
      final response = await http.post(
        Uri.parse('https://$apiDomain/api/ai/memoji'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': 'data:image/jpeg;base64,$base64Image'}),
      ).timeout(Duration(seconds: 180));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['url'] != null) {
          final resultUrl = data['url'];
          
          debugPrint('⬇️ Downloading memoji result from URL...');
          final imageResponse = await http.get(Uri.parse(resultUrl));
          
          if (imageResponse.statusCode != 200) {
            throw Exception('Failed to download result: HTTP ${imageResponse.statusCode}');
          }
          
          final resultBytes = imageResponse.bodyBytes;
          
          setState(() {
            _model.resultImage = resultBytes;
            _model.isProcessing = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Memoji transformation complete!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception(data['error'] ?? 'Unknown error');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _model.isProcessing = false;
        _model.errorMessage = e.toString();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _downloadImage() async {
    if (_model.resultImage == null) return;

    try {
      await Gal.putImageBytes(_model.resultImage!, album: 'VisoAI');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Saved to Gallery/VisoAI!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Download failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30,
            borderWidth: 1,
            buttonSize: 60,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () async {
              context.safePop();
            },
          ),
          title: Text(
            'Memoji Avatar',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              fontFamily: 'Inter Tight',
              color: Colors.white,
              fontSize: 22,
              letterSpacing: 0.0,
            ),
          ),
          centerTitle: true,
          elevation: 2,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_model.selectedUserPhoto == null)
                        Container(
                          height: 250,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).secondaryBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: FlutterFlowTheme.of(context).alternate,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 64,
                                color: FlutterFlowTheme.of(context).secondaryText,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Add Your Photo',
                                style: FlutterFlowTheme.of(context).titleMedium,
                              ),
                            ],
                          ),
                        ),
                      
                      if (_model.selectedUserPhoto != null && _model.resultImage == null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _model.selectedUserPhoto!,
                            height: 350,
                            fit: BoxFit.cover,
                          ),
                        ),
                      
                      if (_model.resultImage != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _model.resultImage!,
                            height: 400,
                            fit: BoxFit.cover,
                          ),
                        ),
                      
                      SizedBox(height: 20),
                      
                      Row(
                        children: [
                          Expanded(
                            child: FFButtonWidget(
                              onPressed: () => _pickPhoto(source: ImageSource.gallery),
                              text: 'Gallery',
                              icon: Icon(Icons.photo_library, size: 20),
                              options: FFButtonOptions(
                                height: 50,
                                color: FlutterFlowTheme.of(context).primary,
                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                  fontFamily: 'Inter Tight',
                                  color: Colors.white,
                                ),
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: FFButtonWidget(
                              onPressed: () => _pickPhoto(source: ImageSource.camera),
                              text: 'Camera',
                              icon: Icon(Icons.camera_alt, size: 20),
                              options: FFButtonOptions(
                                height: 50,
                                color: FlutterFlowTheme.of(context).secondary,
                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                  fontFamily: 'Inter Tight',
                                  color: Colors.white,
                                ),
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 16),
                      
                      if (_model.resultImage == null)
                        FFButtonWidget(
                          onPressed: _model.isProcessing ? null : _showAdAndProcess,
                          text: _model.isProcessing ? 'Processing...' : 'Transform to Memoji',
                          icon: _model.isProcessing 
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Icon(Icons.auto_awesome, size: 24),
                          options: FFButtonOptions(
                            height: 56,
                            color: FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                              fontFamily: 'Inter Tight',
                              color: Colors.white,
                              fontSize: 18,
                            ),
                            borderRadius: BorderRadius.circular(28),
                            elevation: 3,
                          ),
                        ),
                      
                      if (_model.resultImage != null)
                        Column(
                          children: [
                            FFButtonWidget(
                              onPressed: _downloadImage,
                              text: 'Download',
                              icon: Icon(Icons.download, size: 24),
                              options: FFButtonOptions(
                                height: 56,
                                color: Colors.green,
                                textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                                  fontFamily: 'Inter Tight',
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                                borderRadius: BorderRadius.circular(28),
                                elevation: 3,
                              ),
                            ),
                            SizedBox(height: 12),
                            FFButtonWidget(
                              onPressed: () {
                                setState(() {
                                  _model.resultImage = null;
                                  _model.selectedUserPhoto = null;
                                });
                              },
                              text: 'Try Another',
                              icon: Icon(Icons.refresh, size: 24),
                              options: FFButtonOptions(
                                height: 50,
                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                  fontFamily: 'Inter Tight',
                                  color: FlutterFlowTheme.of(context).primaryText,
                                ),
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              
              if (_isBannerAdLoaded && _bannerAd != null)
                Container(
                  height: 60,
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  child: AdWidget(ad: _bannerAd!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
