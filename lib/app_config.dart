import 'dart:io';

/// Centralized configuration access for the app
/// All environment variables and platform-specific configs accessed through this class
class AppConfig {
  // Environment
  static const String environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'prod',
  );

  static bool get isDev => environment == 'dev';
  static bool get isStaging => environment == 'staging';
  static bool get isProd => environment == 'prod';

  // API Configuration
  static const String apiDomain = String.fromEnvironment(
    'API_DOMAIN',
    defaultValue: 'web-production-a7698.up.railway.app',
  );

  static String get apiBaseUrl => 'https://$apiDomain';

  // Supabase Configuration
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  // RevenueCat Configuration
  static String get revenueCatApiKey {
    if (Platform.isIOS) {
      return const String.fromEnvironment(
        'REVENUECAT_IOS_KEY',
        defaultValue: '',
      );
    } else if (Platform.isAndroid) {
      return const String.fromEnvironment(
        'REVENUECAT_ANDROID_KEY',
        defaultValue: '',
      );
    }
    return '';
  }

  // AdMob Configuration
  static String get admobAppId {
    if (Platform.isIOS) {
      return const String.fromEnvironment(
        'ADMOB_APP_ID_IOS',
        defaultValue: 'ca-app-pub-3940256099942544~1458002511', // Test ID
      );
    } else if (Platform.isAndroid) {
      return const String.fromEnvironment(
        'ADMOB_APP_ID_ANDROID',
        defaultValue: 'ca-app-pub-3940256099942544~3347511713', // Test ID
      );
    }
    return '';
  }

  static String get admobBannerAdUnitId {
    if (Platform.isIOS) {
      return const String.fromEnvironment(
        'ADMOB_BANNER_AD_UNIT_ID',
        defaultValue: 'ca-app-pub-3940256099942544/2435281174', // Test ID
      );
    } else if (Platform.isAndroid) {
      return const String.fromEnvironment(
        'ADMOB_BANNER_AD_UNIT_ID',
        defaultValue: 'ca-app-pub-3940256099942544/6300978111', // Test ID
      );
    }
    return '';
  }

  static String get admobRewardedAdUnitId {
    return const String.fromEnvironment(
      'ADMOB_REWARDED_AD_UNIT_ID',
      defaultValue: 'ca-app-pub-3940256099942544/1712485313', // Test ID
    );
  }

  static String get admobAppOpenAdUnitId {
    if (Platform.isIOS) {
      return const String.fromEnvironment(
        'ADMOB_APP_OPEN_AD_UNIT_ID',
        defaultValue: 'ca-app-pub-3940256099942544/5575463023', // Test ID
      );
    } else if (Platform.isAndroid) {
      return const String.fromEnvironment(
        'ADMOB_APP_OPEN_AD_UNIT_ID',
        defaultValue: 'ca-app-pub-3940256099942544/3419835294', // Test ID
      );
    }
    return '';
  }

  // AppLovin Configuration
  static const String applovinSdkKey = String.fromEnvironment(
    'APPLOVIN_SDK_KEY',
    defaultValue: 'test_key',
  );

  // Support Email
  static const String supportEmail = String.fromEnvironment(
    'SUPPORT_EMAIL',
    defaultValue: 'jokerlin135@gmail.com',
  );

  // Debug Flags
  static const bool disableAppLovin = bool.fromEnvironment(
    'DISABLE_APPLOVIN',
    defaultValue: false,
  );

  // AI Service Tokens
  static const String huggingfaceToken = String.fromEnvironment(
    'HUGGINGFACE_TOKEN',
  );
  static const String replicateApiToken = String.fromEnvironment(
    'REPLICATE_API_TOKEN',
  );

  // API Key for backend authentication (if needed)
  static const String apiKey = String.fromEnvironment('API_KEY');

  /// Validate critical configuration
  /// Returns true if all critical configs are present
  static bool validate() {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      print('⚠️ Missing Supabase configuration');
      return false;
    }

    if (isProd && revenueCatApiKey.isEmpty) {
      print('⚠️ Missing RevenueCat API key for production');
      return false;
    }

    return true;
  }

  /// Print current configuration (for debugging)
  static void printConfig() {
    print('📋 App Configuration:');
    print('   Environment: $environment');
    print('   API Domain: $apiDomain');
    print('   Platform: ${Platform.operatingSystem}');
    print(
      '   RevenueCat Key: ${revenueCatApiKey.isNotEmpty ? revenueCatApiKey.substring(0, 10) + "..." : "NOT SET"}',
    );
    print(
      '   AdMob App ID: ${admobAppId.isNotEmpty ? admobAppId.substring(0, 20) + "..." : "NOT SET"}',
    );
  }
}
