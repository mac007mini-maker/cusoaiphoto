// Stub file for web platform - AppLovin not supported on web
// This prevents compilation errors when building for web

import 'package:flutter/widgets.dart';

class AppLovinMAX {
  static Future<void> initialize(String sdkKey) async {}
  static Future<void> setTestDeviceAdvertisingIds(List<String> deviceIds) async {}
  static void setRewardedAdListener(dynamic listener) {}
  static void setInterstitialListener(dynamic listener) {}
  static void setAppOpenAdListener(dynamic listener) {}
  static void loadRewardedAd(String adUnitId) {}
  static void loadInterstitial(String adUnitId) {}
  static void loadAppOpenAd(String adUnitId) {}
  static Future<bool?> isRewardedAdReady(String adUnitId) async => false;
  static Future<bool?> isInterstitialReady(String adUnitId) async => false;
  static Future<bool?> isAppOpenAdReady(String adUnitId) async => false;
  static void showRewardedAd(String adUnitId) {}
  static void showInterstitial(String adUnitId) {}
  static void showAppOpenAd(String adUnitId) {}
}

class RewardedAdListener {
  RewardedAdListener({
    Function(dynamic)? onAdLoadedCallback,
    Function(String, dynamic)? onAdLoadFailedCallback,
    Function(dynamic)? onAdDisplayedCallback,
    Function(dynamic, dynamic)? onAdDisplayFailedCallback,
    Function(dynamic)? onAdClickedCallback,
    Function(dynamic)? onAdHiddenCallback,
    Function(dynamic, dynamic)? onAdReceivedRewardCallback,
  });
}

class InterstitialListener {
  InterstitialListener({
    Function(dynamic)? onAdLoadedCallback,
    Function(String, dynamic)? onAdLoadFailedCallback,
    Function(dynamic)? onAdDisplayedCallback,
    Function(dynamic, dynamic)? onAdDisplayFailedCallback,
    Function(dynamic)? onAdClickedCallback,
    Function(dynamic)? onAdHiddenCallback,
  });
}

class AppOpenAdListener {
  AppOpenAdListener({
    Function(dynamic)? onAdLoadedCallback,
    Function(String, dynamic)? onAdLoadFailedCallback,
    Function(dynamic)? onAdDisplayedCallback,
    Function(dynamic, dynamic)? onAdDisplayFailedCallback,
    Function(dynamic)? onAdClickedCallback,
    Function(dynamic)? onAdHiddenCallback,
  });
}

// Banner Ad View stubs (for Web compilation)
class MaxAdView extends StatelessWidget {
  final String adUnitId;
  final AdFormat adFormat;
  final AdViewAdListener listener;

  const MaxAdView({
    Key? key,
    required this.adUnitId,
    required this.adFormat,
    required this.listener,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // No-op for web
  }
}

class AdFormat {
  static const banner = AdFormat._();
  const AdFormat._();
}

class AdViewAdListener {
  AdViewAdListener({
    Function(dynamic)? onAdLoadedCallback,
    Function(String, dynamic)? onAdLoadFailedCallback,
    Function(dynamic)? onAdClickedCallback,
    Function(dynamic)? onAdExpandedCallback,
    Function(dynamic)? onAdCollapsedCallback,
  });
}
