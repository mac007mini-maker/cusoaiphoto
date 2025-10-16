import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '/services/remote_config_service.dart';

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
    final remoteConfig = RemoteConfigService();
    
    if (Platform.isAndroid) {
      final remoteId = remoteConfig.admobBannerAndroidId;
      if (remoteId.isNotEmpty) {
        debugPrint('🔐 Using AdMob Banner ID from Remote Config (Android)');
        return remoteId;
      }
      
      const envId = String.fromEnvironment('ADMOB_BANNER_AD_UNIT_ID');
      if (envId.isNotEmpty) {
        debugPrint('⚙️ Using AdMob Banner ID from Environment (Android)');
        return envId;
      }
      
      debugPrint('🧪 Using AdMob Banner Test ID (Android)');
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      final remoteId = remoteConfig.admobBannerIosId;
      if (remoteId.isNotEmpty) {
        debugPrint('🔐 Using AdMob Banner ID from Remote Config (iOS)');
        return remoteId;
      }
      
      const envId = String.fromEnvironment('ADMOB_BANNER_AD_UNIT_ID');
      if (envId.isNotEmpty) {
        debugPrint('⚙️ Using AdMob Banner ID from Environment (iOS)');
        return envId;
      }
      
      debugPrint('🧪 Using AdMob Banner Test ID (iOS)');
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    
    return '';
  }

  static bool get isInitialized => _isInitialized;
}
