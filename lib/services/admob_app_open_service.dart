import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '/services/remote_config_service.dart';

class AdMobAppOpenService {
  static AppOpenAd? _appOpenAd;
  static bool _isAdLoaded = false;
  static bool _isInitialized = false;
  static bool _isShowingAd = false;
  static Function()? _onAdComplete;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    if (kIsWeb) {
      debugPrint('⚠️ AdMob App Open ads not supported on web');
      _isInitialized = true;
      return;
    }

    try {
      debugPrint('🔍 AdMob App Open Configuration Check:');
      const adUnitId = String.fromEnvironment('ADMOB_APP_OPEN_AD_UNIT_ID');
      debugPrint('  App Open Ad Unit: ${adUnitId.isEmpty ? "❌ MISSING (will use test ads)" : "✅ Found"}');
      
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('✅ AdMob App Open service initialized');
      
      loadAppOpenAd();
    } catch (e) {
      debugPrint('❌ AdMob App Open initialization failed: $e');
    }
  }

  static void loadAppOpenAd() {
    if (kIsWeb || _isShowingAd) return;
    
    final String adUnitId = _getAdUnitId();
    
    if (adUnitId.isEmpty) {
      debugPrint('⚠️ AdMob App Open Ad Unit ID not configured');
      return;
    }

    AppOpenAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (AppOpenAd ad) {
          debugPrint('✅ AdMob App Open ad loaded');
          _appOpenAd = ad;
          _isAdLoaded = true;
          
          _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (AppOpenAd ad) {
              debugPrint('📺 AdMob App Open ad showed full screen');
              _isShowingAd = true;
            },
            onAdDismissedFullScreenContent: (AppOpenAd ad) {
              debugPrint('👋 AdMob App Open ad dismissed');
              _isShowingAd = false;
              ad.dispose();
              _appOpenAd = null;
              _isAdLoaded = false;
              _onAdComplete?.call();
              loadAppOpenAd();
            },
            onAdFailedToShowFullScreenContent: (AppOpenAd ad, AdError error) {
              debugPrint('❌ AdMob App Open ad failed to show: $error');
              _isShowingAd = false;
              ad.dispose();
              _appOpenAd = null;
              _isAdLoaded = false;
              _onAdComplete?.call();
              loadAppOpenAd();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('❌ AdMob App Open ad failed to load: $error');
          _appOpenAd = null;
          _isAdLoaded = false;
        },
      ),
    );
  }

  static String _getAdUnitId() {
    final remoteConfig = RemoteConfigService();
    
    if (Platform.isAndroid) {
      final remoteId = remoteConfig.admobAppOpenAndroidId;
      if (remoteId.isNotEmpty) {
        debugPrint('🔐 Using AdMob App Open ID from Remote Config (Android)');
        return remoteId;
      }
      
      const envId = String.fromEnvironment('ADMOB_APP_OPEN_AD_UNIT_ID');
      if (envId.isNotEmpty) {
        debugPrint('⚙️ Using AdMob App Open ID from Environment (Android)');
        return envId;
      }
      
      debugPrint('🧪 Using AdMob App Open Test ID (Android)');
      return 'ca-app-pub-3940256099942544/9257395921';
    } else if (Platform.isIOS) {
      final remoteId = remoteConfig.admobAppOpenIosId;
      if (remoteId.isNotEmpty) {
        debugPrint('🔐 Using AdMob App Open ID from Remote Config (iOS)');
        return remoteId;
      }
      
      const envId = String.fromEnvironment('ADMOB_APP_OPEN_AD_UNIT_ID');
      if (envId.isNotEmpty) {
        debugPrint('⚙️ Using AdMob App Open ID from Environment (iOS)');
        return envId;
      }
      
      debugPrint('🧪 Using AdMob App Open Test ID (iOS)');
      return 'ca-app-pub-3940256099942544/5575463023';
    }
    
    return '';
  }

  static Future<bool> showAppOpenAd({Function()? onComplete}) async {
    if (kIsWeb) {
      debugPrint('⚠️ AdMob App Open not available on web');
      onComplete?.call();
      return false;
    }

    if (_isShowingAd) {
      debugPrint('⚠️ AdMob App Open ad already showing');
      onComplete?.call();
      return false;
    }

    _onAdComplete = onComplete;

    if (_appOpenAd != null && _isAdLoaded) {
      _appOpenAd!.show();
      return true;
    } else {
      debugPrint('⚠️ AdMob App Open ad not ready yet');
      onComplete?.call();
      return false;
    }
  }

  static bool get isAdReady => _isAdLoaded && !_isShowingAd;
  static bool get isInitialized => _isInitialized;
}
