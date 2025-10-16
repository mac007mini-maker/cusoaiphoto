import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '/services/remote_config_service.dart';

class AdMobRewardedService {
  static RewardedAd? _rewardedAd;
  static bool _isAdLoaded = false;
  static bool _isInitialized = false;
  
  static Function()? _onRewardedAdComplete;
  static Function()? _onRewardedAdFailed;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    if (kIsWeb) {
      debugPrint('⚠️ AdMob Rewarded not supported on web');
      _isInitialized = true;
      return;
    }

    try {
      debugPrint('🔍 AdMob Rewarded Configuration Check:');
      const adUnitId = String.fromEnvironment('ADMOB_REWARDED_AD_UNIT_ID');
      debugPrint('  Rewarded Ad Unit: ${adUnitId.isEmpty ? "❌ MISSING (will use test ads)" : "✅ Found"}');
      
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('✅ AdMob initialized successfully');
      
      loadRewardedAd();
    } catch (e) {
      debugPrint('❌ AdMob initialization failed: $e');
    }
  }

  static void loadRewardedAd() {
    if (kIsWeb) return;
    
    final String adUnitId = _getAdUnitId();
    
    if (adUnitId.isEmpty) {
      debugPrint('⚠️ AdMob Rewarded Ad Unit ID not configured');
      return;
    }

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          debugPrint('✅ AdMob Rewarded ad loaded');
          _rewardedAd = ad;
          _isAdLoaded = true;
          
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (RewardedAd ad) {
              debugPrint('📺 AdMob Rewarded ad showed full screen');
            },
            onAdDismissedFullScreenContent: (RewardedAd ad) {
              debugPrint('👋 AdMob Rewarded ad dismissed');
              ad.dispose();
              _rewardedAd = null;
              _isAdLoaded = false;
              loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
              debugPrint('❌ AdMob Rewarded ad failed to show: $error');
              ad.dispose();
              _rewardedAd = null;
              _isAdLoaded = false;
              _onRewardedAdFailed?.call();
              loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('❌ AdMob Rewarded ad failed to load: $error');
          _rewardedAd = null;
          _isAdLoaded = false;
        },
      ),
    );
  }

  static String _getAdUnitId() {
    final remoteConfig = RemoteConfigService();
    
    if (Platform.isAndroid) {
      final remoteId = remoteConfig.admobRewardedAndroidId;
      if (remoteId.isNotEmpty) {
        debugPrint('🔐 Using AdMob Rewarded ID from Remote Config (Android)');
        return remoteId;
      }
      
      const envId = String.fromEnvironment('ADMOB_REWARDED_AD_UNIT_ID');
      if (envId.isNotEmpty) {
        debugPrint('⚙️ Using AdMob Rewarded ID from Environment (Android)');
        return envId;
      }
      
      debugPrint('🧪 Using AdMob Rewarded Test ID (Android)');
      return 'ca-app-pub-3940256099942544/5224354917';
    } else if (Platform.isIOS) {
      final remoteId = remoteConfig.admobRewardedIosId;
      if (remoteId.isNotEmpty) {
        debugPrint('🔐 Using AdMob Rewarded ID from Remote Config (iOS)');
        return remoteId;
      }
      
      const envId = String.fromEnvironment('ADMOB_REWARDED_AD_UNIT_ID');
      if (envId.isNotEmpty) {
        debugPrint('⚙️ Using AdMob Rewarded ID from Environment (iOS)');
        return envId;
      }
      
      debugPrint('🧪 Using AdMob Rewarded Test ID (iOS)');
      return 'ca-app-pub-3940256099942544/1712485313';
    }
    
    return '';
  }

  static Future<void> showRewardedAd({
    required Function() onComplete,
    required Function() onFailed,
  }) async {
    if (kIsWeb) {
      debugPrint('⚠️ AdMob not available on web - skipping ad');
      onComplete();
      return;
    }

    _onRewardedAdComplete = onComplete;
    _onRewardedAdFailed = onFailed;

    if (_rewardedAd != null && _isAdLoaded) {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          debugPrint('🎁 User earned AdMob reward: ${reward.amount} ${reward.type}');
          _onRewardedAdComplete?.call();
        },
      );
    } else {
      debugPrint('⚠️ AdMob Rewarded ad not ready yet');
      onFailed();
    }
  }

  static bool get isAdReady => _isAdLoaded && _rewardedAd != null;
  static bool get isInitialized => _isInitialized;
}
