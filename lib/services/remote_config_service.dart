import 'package:firebase_remote_config/firebase_remote_config.dart';
import '/services/user_service.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  bool get adsEnabled {
    if (UserService().isPremiumUser) {
      return false;
    }
    return _remoteConfig.getBool('ads_enabled');
  }

  bool get bannerAdsEnabled {
    if (UserService().isPremiumUser) {
      return false;
    }
    return _remoteConfig.getBool('banner_ads_enabled');
  }

  bool get rewardedAdsEnabled {
    if (UserService().isPremiumUser) {
      return false;
    }
    return _remoteConfig.getBool('rewarded_ads_enabled');
  }

  bool get interstitialAdsEnabled {
    if (UserService().isPremiumUser) {
      return false;
    }
    return _remoteConfig.getBool('interstitial_ads_enabled');
  }

  bool get appOpenAdsEnabled {
    if (UserService().isPremiumUser) {
      return false;
    }
    return _remoteConfig.getBool('app_open_ads_enabled');
  }

  bool get nativeAdsEnabled {
    if (UserService().isPremiumUser) {
      return false;
    }
    return _remoteConfig.getBool('native_ads_enabled');
  }

  int get minUserCountForAds => _remoteConfig.getInt('min_user_count_for_ads');

  String get bannerAdNetwork => _remoteConfig.getString('banner_ad_network');
  String get rewardedAdNetwork => _remoteConfig.getString('rewarded_ad_network');
  String get appOpenAdNetwork => _remoteConfig.getString('app_open_ad_network');

  String get admobAppAndroidId => _remoteConfig.getString('admob_app_android_id');
  String get admobAppIosId => _remoteConfig.getString('admob_app_ios_id');
  String get admobBannerAndroidId => _remoteConfig.getString('admob_banner_android_id');
  String get admobBannerIosId => _remoteConfig.getString('admob_banner_ios_id');
  String get admobAppOpenAndroidId => _remoteConfig.getString('admob_app_open_android_id');
  String get admobAppOpenIosId => _remoteConfig.getString('admob_app_open_ios_id');
  String get admobRewardedAndroidId => _remoteConfig.getString('admob_rewarded_android_id');
  String get admobRewardedIosId => _remoteConfig.getString('admob_rewarded_ios_id');
  String get admobInterstitialAndroidId => _remoteConfig.getString('admob_interstitial_android_id');
  String get admobInterstitialIosId => _remoteConfig.getString('admob_interstitial_ios_id');
  String get admobNativeAndroidId => _remoteConfig.getString('admob_native_android_id');
  String get admobNativeIosId => _remoteConfig.getString('admob_native_ios_id');
  
  String get applovinSdkKey => _remoteConfig.getString('applovin_sdk_key');
  String get applovinBannerAndroidId => _remoteConfig.getString('applovin_banner_android_id');
  String get applovinBannerIosId => _remoteConfig.getString('applovin_banner_ios_id');
  String get applovinAppOpenAndroidId => _remoteConfig.getString('applovin_app_open_android_id');
  String get applovinAppOpenIosId => _remoteConfig.getString('applovin_app_open_ios_id');
  String get applovinRewardedAndroidId => _remoteConfig.getString('applovin_rewarded_android_id');
  String get applovinRewardedIosId => _remoteConfig.getString('applovin_rewarded_ios_id');
  String get applovinInterstitialAndroidId => _remoteConfig.getString('applovin_interstitial_android_id');
  String get applovinInterstitialIosId => _remoteConfig.getString('applovin_interstitial_ios_id');
  String get applovinNativeAndroidId => _remoteConfig.getString('applovin_native_android_id');
  String get applovinNativeIosId => _remoteConfig.getString('applovin_native_ios_id');

  Future<void> initialize() async {
    try {
      await _remoteConfig.setDefaults({
        'ads_enabled': false,
        'banner_ads_enabled': false,
        'rewarded_ads_enabled': false,
        'interstitial_ads_enabled': false,
        'app_open_ads_enabled': false,
        'native_ads_enabled': false,
        'min_user_count_for_ads': 5000,
        'banner_ad_network': 'auto',
        'rewarded_ad_network': 'auto',
        'app_open_ad_network': 'auto',
        'admob_app_android_id': '',
        'admob_app_ios_id': '',
        'admob_banner_android_id': '',
        'admob_banner_ios_id': '',
        'admob_app_open_android_id': '',
        'admob_app_open_ios_id': '',
        'admob_rewarded_android_id': '',
        'admob_rewarded_ios_id': '',
        'admob_interstitial_android_id': '',
        'admob_interstitial_ios_id': '',
        'admob_native_android_id': '',
        'admob_native_ios_id': '',
        'applovin_sdk_key': '',
        'applovin_banner_android_id': '',
        'applovin_banner_ios_id': '',
        'applovin_app_open_android_id': '',
        'applovin_app_open_ios_id': '',
        'applovin_rewarded_android_id': '',
        'applovin_rewarded_ios_id': '',
        'applovin_interstitial_android_id': '',
        'applovin_interstitial_ios_id': '',
        'applovin_native_android_id': '',
        'applovin_native_ios_id': '',
      });

      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      await _remoteConfig.fetchAndActivate();

      print('✅ Remote Config initialized');
      print('   - ads_enabled: $adsEnabled');
      print('   - banner_ads_enabled: $bannerAdsEnabled');
      print('   - rewarded_ads_enabled: $rewardedAdsEnabled');
      print('   - app_open_ads_enabled: $appOpenAdsEnabled');
      print('   - native_ads_enabled: $nativeAdsEnabled');
      print('   - banner_ad_network: $bannerAdNetwork');
      print('   - rewarded_ad_network: $rewardedAdNetwork');
      print('   - app_open_ad_network: $appOpenAdNetwork');
    } catch (e) {
      print('❌ Remote Config error: $e');
      print('   Using default values (ads disabled)');
    }
  }

  Future<void> refresh() async {
    try {
      await _remoteConfig.fetchAndActivate();
      print('🔄 Remote Config refreshed');
    } catch (e) {
      print('❌ Remote Config refresh error: $e');
    }
  }
}
