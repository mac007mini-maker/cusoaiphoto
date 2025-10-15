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
