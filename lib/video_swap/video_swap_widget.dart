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
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'video_swap_model.dart';
export 'video_swap_model.dart';

class VideoSwapWidget extends StatefulWidget {
  const VideoSwapWidget({super.key});

  static String routeName = 'video_swap';
  static String routePath = '/video-swap';

  @override
  State<VideoSwapWidget> createState() => _VideoSwapWidgetState();
}

class _VideoSwapWidgetState extends State<VideoSwapWidget> {
  late VideoSwapModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  Timer? _funFactTimer;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VideoSwapModel());
    
    final remoteConfig = RemoteConfigService();
    if (remoteConfig.adsEnabled && remoteConfig.bannerAdsEnabled) {
      _loadBannerAd();
    }
    
    // Load video templates from Supabase
    _loadVideoTemplates();
  }

  @override
  void dispose() {
    _model.dispose();
    _bannerAd?.dispose();
    _funFactTimer?.cancel();
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

  Future<void> _loadVideoTemplates() async {
    setState(() {
      _model.isLoadingTemplates = true;
      _model.errorMessage = null;
    });

    try {
      final apiUrl = HuggingfaceService.aiBaseUrl;
      final response = await http.get(
        Uri.parse('$apiUrl/video-templates'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _model.videoTemplates = Map<String, List<Map<String, dynamic>>>.from(
              data['templates'].map((key, value) => MapEntry(
                key,
                List<Map<String, dynamic>>.from(value.map((item) => Map<String, dynamic>.from(item)))
              ))
            );
            _model.isLoadingTemplates = false;
          });
          print('✅ Loaded ${data['total_videos']} videos from ${data['categories'].length} categories');
        } else {
          throw Exception(data['error'] ?? 'Failed to load templates');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error loading templates: $e');
      setState(() {
        _model.isLoadingTemplates = false;
        _model.errorMessage = 'Failed to load video templates: $e';
      });
    }
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
        _model.resultVideoUrl = null;
        _model.errorMessage = null;
      });
    }
  }

  Future<void> _processVideoSwap() async {
    if (_model.selectedTemplate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a video template first')),
      );
      return;
    }

    if (_model.selectedUserPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add your photo first')),
      );
      return;
    }

    // Check video swap limit (tier-based & PRO gate)
    final tier = await UsageLimitService.getCurrentTier();
    final canProcess = await UsageLimitService.canProcessVideoSwap();
    
    if (!canProcess) {
      if (tier == 'free') {
        // FREE users - show upgrade modal and navigate to Pro page
        _showUpgradeModal();
        return;
      } else {
        // PRO users - show daily limit reached
        final limit = UsageLimitService.getVideoSwapDailyLimit(tier);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⏰ Daily video swap limit reached ($limit/day for $tier users). Resets tomorrow!'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }
    }

    setState(() {
      _model.isProcessing = true;
      _model.processingProgress = 0.0;
      _model.processingMessage = _model.getRandomFunFact();
      _model.errorMessage = null;
    });

    // Start fun facts rotation
    _startFunFactRotation();

    try {
      final apiUrl = HuggingfaceService.aiBaseUrl;
      final templateVideoUrl = _model.selectedTemplate!['video_url'] as String;
      final userImageBase64 = 'data:image/jpeg;base64,${base64Encode(_model.selectedUserPhoto!)}';

      print('🚀 Starting video swap...');
      print('📹 Template: $templateVideoUrl');

      final response = await http.post(
        Uri.parse('$apiUrl/video-swap'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_image': userImageBase64,
          'template_video_url': templateVideoUrl,
        }),
      ).timeout(Duration(minutes: 3));

      _funFactTimer?.cancel();

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        
        if (result['success'] == true) {
          // Increment video swap counter
          await UsageLimitService.incrementVideoSwapCount();
          
          setState(() {
            _model.resultVideoUrl = result['video_url'];
            _model.isProcessing = false;
            _model.processingProgress = 1.0;
            _model.processingMessage = '✅ Video swap completed!';
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Video swap successful! Provider: ${result['provider'] ?? 'Unknown'}'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception(result['error'] ?? 'Video swap failed');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _funFactTimer?.cancel();
      print('❌ Video swap error: $e');
      
      setState(() {
        _model.isProcessing = false;
        _model.processingProgress = 0.0;
        _model.errorMessage = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  void _startFunFactRotation() {
    _funFactTimer?.cancel();
    _funFactTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (!_model.isProcessing) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _model.processingMessage = _model.getRandomFunFact();
        _model.processingProgress = (_model.processingProgress + 0.1).clamp(0.0, 0.95);
      });
    });
  }

  Future<void> _downloadVideo() async {
    if (_model.resultVideoUrl == null) return;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('📥 Downloading video...')),
      );

      // Download via backend proxy to avoid CDN connection issues
      final apiUrl = HuggingfaceService.aiBaseUrl;
      final response = await http.post(
        Uri.parse('$apiUrl/video-swap/download'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'video_url': _model.resultVideoUrl}),
      );
      
      if (response.statusCode == 200) {
        final videoBytes = response.bodyBytes;
        
        // Save to temp file first, then use Gal.putVideo with path
        final tempDir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final tempFile = File('${tempDir.path}/video_swap_$timestamp.mp4');
        await tempFile.writeAsBytes(videoBytes);
        
        // Save to gallery with gal package
        await Gal.putVideo(tempFile.path, album: 'VisoAI');
        
        // Clean up temp file
        try {
          await tempFile.delete();
        } catch (e) {
          print('⚠️ Failed to delete temp file: $e');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Video saved to Gallery/VisoAI!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to download video');
      }
    } catch (e) {
      print('❌ Download error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Download failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showUpgradeModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.stars, color: Colors.amber, size: 28),
              SizedBox(width: 8),
              Text('Upgrade to PRO'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🎬 Video Face Swap is a PRO-only feature!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('✨ Unlock with PRO subscription:'),
              SizedBox(height: 8),
              Text('  • Weekly: 5 video swaps/day'),
              Text('  • Yearly: 10 video swaps/day'),
              Text('  • Lifetime: 20 video swaps/day'),
              SizedBox(height: 8),
              Text('  • Plus all other PRO features!'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.pushNamed(ProWidget.routeName);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).primary,
              ),
              child: Text(
                'Upgrade Now',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
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
            onPressed: () => context.pop(),
          ),
          title: Text(
            'SwapVideo',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              fontFamily: 'Outfit',
              color: Colors.white,
              fontSize: 22,
            ),
          ),
          centerTitle: false,
          elevation: 2,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Main content
              Expanded(
                child: _buildMainContent(),
              ),
              
              // Banner ad
              if (_isBannerAdLoaded && _bannerAd != null)
                Container(
                  width: double.infinity,
                  height: 50,
                  child: AdWidget(ad: _bannerAd!),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_model.isProcessing) {
      return _buildProcessingUI();
    }

    if (_model.resultVideoUrl != null) {
      return _buildResultUI();
    }

    return _buildTemplateGallery();
  }

  Widget _buildTemplateGallery() {
    if (_model.isLoadingTemplates) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading video templates...'),
          ],
        ),
      );
    }

    if (_model.errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                _model.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(height: 16),
              FFButtonWidget(
                onPressed: _loadVideoTemplates,
                text: 'Retry',
                options: FFButtonOptions(
                  height: 40,
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  color: FlutterFlowTheme.of(context).primary,
                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                    fontFamily: 'Readex Pro',
                    color: Colors.white,
                  ),
                  elevation: 3,
                  borderSide: BorderSide(color: Colors.transparent, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header instructions
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  '🎬 Choose a video template',
                  style: FlutterFlowTheme.of(context).headlineSmall,
                ),
                SizedBox(height: 8),
                Text(
                  'Select a video below, then add your photo to swap faces!',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
              ],
            ),
          ),

          // Templates by category
          ..._model.videoTemplates.entries.map((entry) {
            final category = entry.key;
            final videos = entry.value;
            
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      category.toUpperCase(),
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                        fontFamily: 'Readex Pro',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      itemCount: videos.length,
                      itemBuilder: (context, index) {
                        final video = videos[index];
                        final isSelected = _model.selectedTemplate?['id'] == video['id'];
                        
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _model.selectedTemplate = video;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('📹 Selected: ${video['title']}'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Container(
                              width: 120,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? FlutterFlowTheme.of(context).primary.withOpacity(0.3)
                                    : FlutterFlowTheme.of(context).secondaryBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? FlutterFlowTheme.of(context).primary
                                      : Colors.grey.shade300,
                                  width: isSelected ? 3 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.play_circle_outline,
                                    size: 48,
                                    color: isSelected
                                        ? FlutterFlowTheme.of(context).primary
                                        : Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      video['title'] ?? '',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          // User photo section
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                if (_model.selectedTemplate != null) ...[
                  Divider(height: 32),
                  Text(
                    '📸 Add Your Photo',
                    style: FlutterFlowTheme.of(context).headlineSmall,
                  ),
                  SizedBox(height: 16),
                  
                  if (_model.selectedUserPhoto != null)
                    Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          _model.selectedUserPhoto!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  
                  SizedBox(height: 16),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FFButtonWidget(
                        onPressed: () => _pickPhoto(source: ImageSource.gallery),
                        text: 'Gallery',
                        icon: Icon(Icons.photo_library, size: 20),
                        options: FFButtonOptions(
                          height: 45,
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          color: FlutterFlowTheme.of(context).secondary,
                          textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                            fontFamily: 'Readex Pro',
                            color: Colors.white,
                          ),
                          elevation: 3,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      SizedBox(width: 12),
                      FFButtonWidget(
                        onPressed: () => _pickPhoto(source: ImageSource.camera),
                        text: 'Camera',
                        icon: Icon(Icons.camera_alt, size: 20),
                        options: FFButtonOptions(
                          height: 45,
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          color: FlutterFlowTheme.of(context).secondary,
                          textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                            fontFamily: 'Readex Pro',
                            color: Colors.white,
                          ),
                          elevation: 3,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 24),
                  
                  if (_model.selectedUserPhoto != null)
                    FFButtonWidget(
                      onPressed: _processVideoSwap,
                      text: '🎬 Swap Face in Video',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 55,
                        padding: EdgeInsets.zero,
                        color: FlutterFlowTheme.of(context).primary,
                        textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                          fontFamily: 'Readex Pro',
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        elevation: 3,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingUI() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: _model.processingProgress,
                strokeWidth: 8,
                backgroundColor: Colors.grey.shade300,
              ),
            ),
            SizedBox(height: 32),
            Text(
              _model.processingMessage,
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).titleMedium,
            ),
            SizedBox(height: 16),
            Text(
              '⏱️ This may take 10-60 seconds',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Readex Pro',
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please don\'t close this screen...',
              style: FlutterFlowTheme.of(context).bodySmall.override(
                fontFamily: 'Readex Pro',
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultUI() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '✅ Video Swap Complete!',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Outfit',
                color: Colors.green,
              ),
            ),
            SizedBox(height: 24),
            
            // Video player placeholder (could add actual video player later)
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.video_library, size: 64, color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Video Ready!',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            FFButtonWidget(
              onPressed: _downloadVideo,
              text: '📥 Download to Gallery',
              options: FFButtonOptions(
                width: double.infinity,
                height: 55,
                color: FlutterFlowTheme.of(context).success,
                textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                  fontFamily: 'Readex Pro',
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                elevation: 3,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            
            SizedBox(height: 16),
            
            FFButtonWidget(
              onPressed: () {
                setState(() {
                  _model.selectedTemplate = null;
                  _model.selectedUserPhoto = null;
                  _model.resultVideoUrl = null;
                  _model.errorMessage = null;
                });
              },
              text: '🔄 Create Another',
              options: FFButtonOptions(
                width: double.infinity,
                height: 50,
                color: FlutterFlowTheme.of(context).secondary,
                textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                  fontFamily: 'Readex Pro',
                  color: Colors.white,
                ),
                elevation: 2,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
