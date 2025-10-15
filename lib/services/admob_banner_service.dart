import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobBannerService {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    if (kIsWeb) {
      debugPrint('⚠️ AdMob Banner ads not supported on web');
      _isInitialized = true;
      return;
    }

    try {
      debugPrint('🔍 AdMob Banner Configuration Check:');
      const adUnitId = String.fromEnvironment('ADMOB_BANNER_AD_UNIT_ID');
      debugPrint('  Banner Ad Unit: ${adUnitId.isEmpty ? "❌ MISSING (will use test ads)" : "✅ Found"}');
      
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('✅ AdMob Banner service initialized');
    } catch (e) {
      debugPrint('❌ AdMob Banner initialization failed: $e');
    }
  }

  static String getBannerAdUnitId() {
    const bannerAdUnitId = String.fromEnvironment('ADMOB_BANNER_AD_UNIT_ID');
    
    if (bannerAdUnitId.isNotEmpty) {
      return bannerAdUnitId;
    }

    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    
    return '';
  }

  static bool get isInitialized => _isInitialized;
}
