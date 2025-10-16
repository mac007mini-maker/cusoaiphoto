import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'dart:math';
import 'package:applovin_max/applovin_max.dart' if (dart.library.html) 'applovin_stub.dart';
import '/services/remote_config_service.dart';

class AppLovinService {
  static bool _isInitialized = false;
  static String? _rewardedAdUnitId;
  static String? _bannerAdUnitId;
  static String? _interstitialAdUnitId;
  static String? _appOpenAdUnitId;
  static String? _nativeAdUnitId;
  
  static int _rewardedAdRetryAttempt = 0;
  static int _interstitialAdRetryAttempt = 0;
  static int _appOpenAdRetryAttempt = 0;
  static const int _maxRetryCount = 6;
  
  static bool _isRewardedAdReady = false;
  static bool _isInterstitialAdReady = false;
  static bool _isAppOpenAdReady = false;
  
  static Function()? _onRewardedAdComplete;
  static Function()? _onRewardedAdFailed;
  static Function()? _onAppOpenAdComplete;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Skip AppLovin on web platform (not supported)
    if (kIsWeb) {
      debugPrint('⚠️ AppLovin MAX not supported on web - skipping initialization');
      _isInitialized = true;
      return;
    }

    try {
      final remoteConfig = RemoteConfigService();
      
      String sdkKey = remoteConfig.applovinSdkKey;
      if (sdkKey.isEmpty) {
        sdkKey = const String.fromEnvironment('APPLOVIN_SDK_KEY');
        if (sdkKey.isNotEmpty) {
          debugPrint('⚙️ Using AppLovin SDK Key from Environment');
        }
      } else {
        debugPrint('🔐 Using AppLovin SDK Key from Remote Config');
      }
      
      _rewardedAdUnitId = _getPlatformAdUnitId(
        Platform.isAndroid ? remoteConfig.applovinRewardedAndroidId : remoteConfig.applovinRewardedIosId,
        const String.fromEnvironment('APPLOVIN_REWARDED_AD_UNIT_ID'),
        'REWARDED'
      );
          
      _bannerAdUnitId = _getPlatformAdUnitId(
        Platform.isAndroid ? remoteConfig.applovinBannerAndroidId : remoteConfig.applovinBannerIosId,
        const String.fromEnvironment('APPLOVIN_BANNER_AD_UNIT_ID'),
        'BANNER'
      );
          
      _interstitialAdUnitId = _getPlatformAdUnitId(
        Platform.isAndroid ? remoteConfig.applovinInterstitialAndroidId : remoteConfig.applovinInterstitialIosId,
        const String.fromEnvironment('APPLOVIN_INTERSTITIAL_AD_UNIT_ID'),
        'INTERSTITIAL'
      );
          
      _appOpenAdUnitId = _getPlatformAdUnitId(
        Platform.isAndroid ? remoteConfig.applovinAppOpenAndroidId : remoteConfig.applovinAppOpenIosId,
        const String.fromEnvironment('APPLOVIN_APP_OPEN_AD_UNIT_ID'),
        'APP_OPEN'
      );
          
      _nativeAdUnitId = _getPlatformAdUnitId(
        Platform.isAndroid ? remoteConfig.applovinNativeAndroidId : remoteConfig.applovinNativeIosId,
        const String.fromEnvironment('APPLOVIN_NATIVE_AD_UNIT_ID'),
        'NATIVE'
      );

      debugPrint('🔍 AppLovin Configuration Check:');
      debugPrint('  SDK Key: ${sdkKey.isEmpty ? "❌ MISSING" : "✅ Found"}');
      debugPrint('  Rewarded Ad Unit: ${_rewardedAdUnitId?.isEmpty ?? true ? "❌ MISSING" : "✅ Found"}');
      debugPrint('  Banner Ad Unit: ${_bannerAdUnitId?.isEmpty ?? true ? "❌ MISSING" : "✅ Found"}');
      debugPrint('  Interstitial Ad Unit: ${_interstitialAdUnitId?.isEmpty ?? true ? "❌ MISSING" : "✅ Found"}');

      if (sdkKey.isEmpty) {
        debugPrint('❌ AppLovin SDK Key not found (checked Remote Config + Environment)');
        debugPrint('💡 Add to Firebase Remote Config or build with: ./build_with_all_ads.sh apk');
        return;
      }

      await AppLovinMAX.initialize(sdkKey);
      
      // Enable Test Mode with registered test devices
      final testDeviceIds = [
        '60a8473b-a7ab-4638-aa2f-10calad1abe1',  // note8
        '712b3dc1-ad2c-4489-a0e7-b89835531451',  // mumu
        '505a6f9e-362d-4b54-9de9-92f9afaf79d9',  // samsung
        '08d95f27-e083-4c60-b963-becd2ad36e55',  // ldplayer
        '0fad319a-b895-4791-ac2d-9f10ad1b9206',  // vuvu
      ];
      AppLovinMAX.setTestDeviceAdvertisingIds(testDeviceIds);
      debugPrint('🧪 AppLovin Test Mode enabled for ${testDeviceIds.length} devices');
      
      _isInitialized = true;
      debugPrint('✅ AppLovin MAX initialized successfully');

      _setupRewardedAdListeners();
      _setupInterstitialAdListeners();
      _setupAppOpenAdListeners();
      
      if (_rewardedAdUnitId != null && _rewardedAdUnitId!.isNotEmpty) {
        loadRewardedAd();
      }
      
      if (_interstitialAdUnitId != null && _interstitialAdUnitId!.isNotEmpty) {
        loadInterstitialAd();
      }
      
      if (_appOpenAdUnitId != null && _appOpenAdUnitId!.isNotEmpty) {
        loadAppOpenAd();
      }
    } catch (e) {
      debugPrint('❌ AppLovin initialization failed: $e');
    }
  }

  static void _setupRewardedAdListeners() {
    AppLovinMAX.setRewardedAdListener(RewardedAdListener(
      onAdLoadedCallback: (ad) {
        debugPrint('✅ Rewarded ad loaded from ${ad.networkName}');
        _rewardedAdRetryAttempt = 0;
        _isRewardedAdReady = true;
      },
      onAdLoadFailedCallback: (adUnitId, error) {
        _isRewardedAdReady = false;
        _rewardedAdRetryAttempt++;
        
        if (_rewardedAdRetryAttempt > _maxRetryCount) {
          debugPrint('❌ Rewarded ad failed after ${_maxRetryCount} retries');
          return;
        }
        
        int retryDelay = pow(2, min(_maxRetryCount, _rewardedAdRetryAttempt)).toInt();
        debugPrint('⏳ Rewarded ad failed (${error.code}) - retrying in ${retryDelay}s');
        
        Future.delayed(Duration(seconds: retryDelay), () {
          loadRewardedAd();
        });
      },
      onAdDisplayedCallback: (ad) {
        debugPrint('📺 Rewarded ad displayed');
      },
      onAdDisplayFailedCallback: (ad, error) {
        debugPrint('❌ Rewarded ad display failed: ${error.message}');
        _isRewardedAdReady = false;
        _onRewardedAdFailed?.call();
        loadRewardedAd();
      },
      onAdClickedCallback: (ad) {
        debugPrint('👆 Rewarded ad clicked');
      },
      onAdHiddenCallback: (ad) {
        debugPrint('👋 Rewarded ad hidden');
        _isRewardedAdReady = false;
        loadRewardedAd();
      },
      onAdReceivedRewardCallback: (ad, reward) {
        debugPrint('🎁 User earned reward: ${reward.amount} ${reward.label}');
        _onRewardedAdComplete?.call();
      },
    ));
  }

  static void _setupInterstitialAdListeners() {
    AppLovinMAX.setInterstitialListener(InterstitialListener(
      onAdLoadedCallback: (ad) {
        debugPrint('✅ Interstitial ad loaded from ${ad.networkName}');
        _interstitialAdRetryAttempt = 0;
        _isInterstitialAdReady = true;
      },
      onAdLoadFailedCallback: (adUnitId, error) {
        _isInterstitialAdReady = false;
        _interstitialAdRetryAttempt++;
        
        if (_interstitialAdRetryAttempt > _maxRetryCount) {
          return;
        }
        
        int retryDelay = pow(2, min(_maxRetryCount, _interstitialAdRetryAttempt)).toInt();
        debugPrint('⏳ Interstitial ad failed (${error.code}) - retrying in ${retryDelay}s');
        
        Future.delayed(Duration(seconds: retryDelay), () {
          loadInterstitialAd();
        });
      },
      onAdDisplayedCallback: (ad) {
        debugPrint('📺 Interstitial ad displayed');
      },
      onAdDisplayFailedCallback: (ad, error) {
        debugPrint('❌ Interstitial ad display failed');
        _isInterstitialAdReady = false;
        loadInterstitialAd();
      },
      onAdClickedCallback: (ad) {
        debugPrint('👆 Interstitial ad clicked');
      },
      onAdHiddenCallback: (ad) {
        debugPrint('👋 Interstitial ad hidden');
        _isInterstitialAdReady = false;
        loadInterstitialAd();
      },
    ));
  }

  static void _setupAppOpenAdListeners() {
    AppLovinMAX.setAppOpenAdListener(AppOpenAdListener(
      onAdLoadedCallback: (ad) {
        debugPrint('✅ App Open ad loaded from ${ad.networkName}');
        _appOpenAdRetryAttempt = 0;
        _isAppOpenAdReady = true;
      },
      onAdLoadFailedCallback: (adUnitId, error) {
        _isAppOpenAdReady = false;
        _appOpenAdRetryAttempt++;
        
        if (_appOpenAdRetryAttempt > _maxRetryCount) {
          return;
        }
        
        int retryDelay = pow(2, min(_maxRetryCount, _appOpenAdRetryAttempt)).toInt();
        debugPrint('⏳ App Open ad failed (${error.code}) - retrying in ${retryDelay}s');
        
        Future.delayed(Duration(seconds: retryDelay), () {
          loadAppOpenAd();
        });
      },
      onAdDisplayedCallback: (ad) {
        debugPrint('📺 App Open ad displayed');
      },
      onAdDisplayFailedCallback: (ad, error) {
        debugPrint('❌ App Open ad display failed');
        _isAppOpenAdReady = false;
        loadAppOpenAd();
      },
      onAdClickedCallback: (ad) {
        debugPrint('👆 App Open ad clicked');
      },
      onAdHiddenCallback: (ad) {
        debugPrint('👋 App Open ad hidden');
        _isAppOpenAdReady = false;
        _onAppOpenAdComplete?.call();
        loadAppOpenAd();
      },
    ));
  }

  static void loadRewardedAd() {
    if (_rewardedAdUnitId == null || _rewardedAdUnitId!.isEmpty) {
      debugPrint('⚠️ Rewarded Ad Unit ID not configured');
      return;
    }
    AppLovinMAX.loadRewardedAd(_rewardedAdUnitId!);
  }

  static void loadInterstitialAd() {
    if (_interstitialAdUnitId == null || _interstitialAdUnitId!.isEmpty) {
      debugPrint('⚠️ Interstitial Ad Unit ID not configured');
      return;
    }
    AppLovinMAX.loadInterstitial(_interstitialAdUnitId!);
  }

  static void loadAppOpenAd() {
    if (_appOpenAdUnitId == null || _appOpenAdUnitId!.isEmpty) {
      debugPrint('⚠️ App Open Ad Unit ID not configured');
      return;
    }
    AppLovinMAX.loadAppOpenAd(_appOpenAdUnitId!);
  }

  static Future<bool> isRewardedAdReady() async {
    if (_rewardedAdUnitId == null || _rewardedAdUnitId!.isEmpty) return false;
    return await AppLovinMAX.isRewardedAdReady(_rewardedAdUnitId!) ?? false;
  }

  static Future<bool> isInterstitialAdReady() async {
    if (_interstitialAdUnitId == null || _interstitialAdUnitId!.isEmpty) return false;
    return await AppLovinMAX.isInterstitialReady(_interstitialAdUnitId!) ?? false;
  }

  static Future<bool> isAppOpenAdReady() async {
    if (_appOpenAdUnitId == null || _appOpenAdUnitId!.isEmpty) return false;
    return await AppLovinMAX.isAppOpenAdReady(_appOpenAdUnitId!) ?? false;
  }

  static Future<void> showRewardedAd({
    required Function() onComplete,
    required Function() onFailed,
  }) async {
    // On web, skip ads and proceed directly
    if (kIsWeb) {
      debugPrint('⚠️ AppLovin not available on web - skipping ad');
      onComplete();
      return;
    }

    _onRewardedAdComplete = onComplete;
    _onRewardedAdFailed = onFailed;

    final isReady = await isRewardedAdReady();
    
    if (isReady) {
      AppLovinMAX.showRewardedAd(_rewardedAdUnitId!);
    } else {
      debugPrint('⚠️ Rewarded ad not ready yet');
      onFailed();
    }
  }

  static Future<void> showInterstitialAd() async {
    final isReady = await isInterstitialAdReady();
    
    if (isReady) {
      AppLovinMAX.showInterstitial(_interstitialAdUnitId!);
    } else {
      debugPrint('⚠️ Interstitial ad not ready yet');
    }
  }

  static Future<void> showAppOpenAd({Function()? onComplete}) async {
    // On web, skip ads
    if (kIsWeb) {
      debugPrint('⚠️ AppLovin App Open ad not available on web');
      onComplete?.call();
      return;
    }

    _onAppOpenAdComplete = onComplete;
    
    final isReady = await isAppOpenAdReady();
    
    if (isReady) {
      AppLovinMAX.showAppOpenAd(_appOpenAdUnitId!);
    } else {
      debugPrint('⚠️ App Open ad not ready yet');
      onComplete?.call();
    }
  }

  static String _getPlatformAdUnitId(String remoteId, String envId, String adType) {
    final platform = Platform.isAndroid ? 'Android' : 'iOS';
    
    if (remoteId.isNotEmpty) {
      debugPrint('🔐 Using AppLovin $adType ID ($platform) from Remote Config');
      return remoteId;
    }
    
    if (envId.isNotEmpty) {
      debugPrint('⚙️ Using AppLovin $adType ID ($platform) from Environment');
      return envId;
    }
    
    debugPrint('⚠️ AppLovin $adType ID ($platform) not configured (Remote Config + Env both empty)');
    debugPrint('💡 AppLovin requires SDK setup - no public test IDs like AdMob');
    debugPrint('   Add IDs to Firebase Remote Config for production use');
    return '';
  }

  static String? get bannerAdUnitId => _bannerAdUnitId;
  static String? get nativeAdUnitId => _nativeAdUnitId;
  static bool get isInitialized => _isInitialized;
}
