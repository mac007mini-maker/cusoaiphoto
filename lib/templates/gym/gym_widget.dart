import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/services/huggingface_service.dart';
import '/services/applovin_service.dart';
import '/services/admob_rewarded_service.dart';
import '/services/admob_banner_service.dart';
import '/services/remote_config_service.dart';
import '/services/revenue_cat_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:google_mobile_ads/google_mobile_ads.dart';
// Conditional imports for platform-specific code
import 'gym_download_stub.dart'
    if (dart.library.html) 'gym_download_web.dart'
    if (dart.library.io) 'gym_download_mobile.dart';
import 'gym_model.dart';
export 'gym_model.dart';

class GymWidget extends StatefulWidget {
  const GymWidget({super.key});

  static String routeName = 'gym';
  static String routePath = '/gym';

  @override
  State<GymWidget> createState() => _GymWidgetState();
}

class _GymWidgetState extends State<GymWidget> {
  late GymModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late PageController _pageController;
  int _currentPage = 0;
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GymModel());
    _pageController = PageController(viewportFraction: 0.85);
    
    // Load templates from Supabase
    _loadTemplatesAndAds();
  }

  Future<void> _loadTemplatesAndAds() async {
    await _model.loadTemplates();
    
    // Always update UI after loading (success, error, or empty)
    if (mounted) {
      setState(() {
        // Set first template as selected if available
        if (_model.allTemplates.isNotEmpty) {
          _model.selectedTemplate = _model.allTemplates[0];
        }
      });
    }
    
    // Only load banner ads if enabled via Remote Config
    final remoteConfig = RemoteConfigService();
    if (remoteConfig.adsEnabled && remoteConfig.bannerAdsEnabled) {
      _loadBannerAd();
    } else {
      debugPrint('🚫 Banner ads disabled via Remote Config - skipping banner load');
    }
  }

  @override
  void dispose() {
    _model.dispose();
    _pageController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    final adUnitId = AdMobBannerService.getBannerAdUnitId();
    
    if (adUnitId.isEmpty) {
      debugPrint('⚠️ Banner Ad Unit ID not available');
      return;
    }
    
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('✅ Face Swap banner ad loaded');
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ Face Swap banner ad failed: $error');
          ad.dispose();
        },
      ),
    );
    _bannerAd?.load();
  }

  List<StyleTemplate> get _allTemplates => _model.allTemplates;

  Future<void> _pickUserPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (photo != null) {
      final bytes = await photo.readAsBytes();
      setState(() {
        _model.selectedUserPhoto = bytes;
      });
    }
  }

  Future<void> _pickPhotoFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (photo != null) {
      final bytes = await photo.readAsBytes();
      setState(() {
        _model.selectedUserPhoto = bytes;
      });
    }
  }

  Future<void> _showAdAndSwapFace() async {
    if (_model.selectedTemplate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a template first')),
      );
      return;
    }

    if (_model.selectedUserPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add your photo first')),
      );
      return;
    }

    final remoteConfig = RemoteConfigService();
    
    if (!remoteConfig.adsEnabled || !remoteConfig.rewardedAdsEnabled) {
      debugPrint('🚫 Rewarded ads disabled via Remote Config - proceeding directly');
      _swapFace();
      return;
    }

    // Get preferred ad network from Remote Config
    final preferredNetwork = remoteConfig.rewardedAdNetwork.toLowerCase();
    debugPrint('📺 Rewarded ad network preference: $preferredNetwork');

    if (preferredNetwork == 'applovin') {
      // AppLovin only (no fallback)
      await AppLovinService.showRewardedAd(
        onComplete: () {
          debugPrint('✅ AppLovin ad watched - proceeding with face swap');
          _swapFace();
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
      // AdMob only (no fallback)
      await AdMobRewardedService.showRewardedAd(
        onComplete: () {
          debugPrint('✅ AdMob ad watched - proceeding with face swap');
          _swapFace();
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
      // Auto mode: Try AdMob first, then AppLovin as fallback
      await AdMobRewardedService.showRewardedAd(
        onComplete: () {
          debugPrint('✅ AdMob ad watched - proceeding with face swap');
          _swapFace();
        },
        onFailed: () async {
          debugPrint('⚠️ AdMob ad failed - trying AppLovin fallback');
          await AppLovinService.showRewardedAd(
            onComplete: () {
              debugPrint('✅ AppLovin ad watched - proceeding with face swap');
              _swapFace();
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

  Future<void> _swapFace() async {
    if (_model.selectedTemplate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a template first')),
      );
      return;
    }

    if (_model.selectedUserPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add your photo first')),
      );
      return;
    }

    setState(() {
      _model.isProcessing = true;
    });

    try {
      final template = _model.selectedTemplate!;
      
      // Read template image
      final Uint8List templateBytes;
      if (template.imagePath.startsWith('http')) {
        final response = await http.get(Uri.parse(template.imagePath));
        if (response.statusCode != 200) {
          throw Exception('Failed to load template: HTTP ${response.statusCode}');
        }
        templateBytes = response.bodyBytes;
      } else {
        final ByteData templateData = await DefaultAssetBundle.of(context).load(template.imagePath);
        templateBytes = templateData.buffer.asUint8List();
      }

      // Call Face Swap API (returns URL)
      final resultUrl = await HuggingfaceService.faceSwap(
        targetImageBytes: templateBytes,
        sourceFaceBytes: _model.selectedUserPhoto!,
      );

      // Download image via proxy to avoid network blocking
      final resultBytes = await HuggingfaceService.downloadImageViaProxy(resultUrl);

      setState(() {
        _model.resultImageBytes = resultBytes;
        _model.isProcessing = false;
      });

      _showResultDialog();
    } catch (e) {
      setState(() {
        _model.isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Face swap failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showResultDialog() {
    if (_model.resultImageBytes == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '✨ Face Swap Result',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.memory(
                    _model.resultImageBytes!,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close),
                      label: Text('Close'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _downloadResult(),
                      icon: Icon(Icons.download),
                      label: Text('Download'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF7C4DFF),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _downloadResult() async {
    if (_model.resultImageBytes == null) return;

    try {
      final bytes = _model.resultImageBytes!;
      final filename = 'face_swap_${DateTime.now().millisecondsSinceEpoch}.png';
      
      // Download image
      await downloadImage(bytes, filename);
      
      // Show success with location info
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('Image saved to Gallery!'),
                ],
              ),
              SizedBox(height: 4),
              Text(
                'Check your Photos app → VisoAI album',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // Close dialog after download
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Download failed: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        elevation: 0,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30,
          buttonSize: 46,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: FlutterFlowTheme.of(context).primaryText,
            size: 25,
          ),
          onPressed: () async {
            context.pop();
          },
        ),
        title: Text(
          'Gym',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                font: GoogleFonts.inter(),
                letterSpacing: 0.0,
              ),
        ),
        actions: [
          FutureBuilder<bool>(
              future: RevenueCatService().isPremiumUser(),
              builder: (context, snapshot) {
                // Hide button during loading OR if user is premium
                if (!snapshot.hasData || snapshot.data == true) {
                return SizedBox.shrink();
              }
              
              return Padding(
                padding: EdgeInsets.only(right: 16),
                child: ElevatedButton(
                  onPressed: () {
                    context.pushNamed('pro');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF7C4DFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Remove Ad',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              );
            },
          ),
        ],
        centerTitle: false,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Carousel Section
              Expanded(
                flex: 5,
                child: _model.isTemplatesLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Color(0xFF7C4DFF),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Loading templates...',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _model.templatesError != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.red,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Failed to load templates',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 32),
                                  child: Text(
                                    _model.templatesError!,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _loadTemplatesAndAds();
                                    });
                                  },
                                  icon: Icon(Icons.refresh),
                                  label: Text('Retry'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF7C4DFF),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _allTemplates.isEmpty
                            ? Center(
                                child: Text(
                                  'No templates available',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  SizedBox(height: 20),
                                  // PageView Carousel
                                  Expanded(
                                    child: PageView.builder(
                                      controller: _pageController,
                                      onPageChanged: (index) {
                                        setState(() {
                                          _currentPage = index;
                                          _model.selectedTemplate = _allTemplates[index];
                                        });
                                      },
                                      itemCount: _allTemplates.length,
                                      itemBuilder: (context, index) {
                                        final template = _allTemplates[index];
                                        final isCenter = index == _currentPage;
                                        
                                        return AnimatedContainer(
                                          duration: Duration(milliseconds: 300),
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: isCenter ? 0 : 30,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(20),
                                            child: template.imagePath.startsWith('http')
                                                ? Image.network(
                                                    template.imagePath,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.asset(
                                                    template.imagePath,
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  // Dots Indicator
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      _allTemplates.length,
                                      (index) => Container(
                                        margin: EdgeInsets.symmetric(horizontal: 4),
                                        width: index == _currentPage ? 24 : 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: index == _currentPage
                                              ? Color(0xFF7C4DFF)
                                              : Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                ],
                              ),
              ),

              // Add Photo Section
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add your face to swap',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: FlutterFlowTheme.of(context).primaryText,
                        ),
                      ),
                      SizedBox(height: 12),
                      
                      // Photo Picker Buttons (Gallery + Camera)
                      Row(
                        children: [
                          // Gallery Button
                          GestureDetector(
                            onTap: _pickUserPhoto,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: _model.selectedUserPhoto != null
                                    ? Colors.transparent
                                    : Color(0xFF7C4DFF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Color(0xFF7C4DFF),
                                  width: 2,
                                ),
                              ),
                              child: _model.selectedUserPhoto != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.memory(
                                        _model.selectedUserPhoto!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Icon(
                                      Icons.add,
                                      size: 40,
                                      color: Color(0xFF7C4DFF),
                                    ),
                            ),
                          ),
                          SizedBox(width: 12),
                          // Camera Button
                          GestureDetector(
                            onTap: _pickPhotoFromCamera,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Color(0xFF7C4DFF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Color(0xFF7C4DFF),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: Color(0xFF7C4DFF),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      
                      // Swap Face Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _model.isProcessing ? null : _showAdAndSwapFace,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF7C4DFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: _model.isProcessing
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.play_circle_outline, color: Colors.white),
                                    SizedBox(width: 8),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Swap Face',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'Watch Ad',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: Colors.white.withOpacity(0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // AdMob Banner (with SafeArea padding to prevent system nav bar overlap)
              if (_isBannerAdLoaded && _bannerAd != null)
                SafeArea(
                  top: false,
                  bottom: true, // Prevent overlap with system navigation bar
                  child: Container(
                    color: Colors.white,
                    height: _bannerAd!.size.height.toDouble(),
                    width: double.infinity,
                    child: AdWidget(ad: _bannerAd!),
                  ),
                ),
            ],
          ),

          // Loading Overlay
          if (_model.isProcessing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C4DFF)),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Swapping faces...\nThis may take up to 2 minutes',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
