import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/internationalization.dart';

import '/flutter_flow/admob_util.dart';
import '/services/applovin_service.dart';
import '/services/admob_rewarded_service.dart';
import '/services/admob_app_open_service.dart';
import '/services/admob_banner_service.dart';
import '/services/remote_config_service.dart';
import '/services/user_service.dart';
import '/services/revenue_cat_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized');
  } catch (e) {
    print('⚠️ Firebase not configured (will use defaults): $e');
  }

  await UserService().initialize();
  await RemoteConfigService().initialize();
  await RevenueCatService().initialize();

  await SupaFlow.initialize();

  await FlutterFlowTheme.initialize();

  if (RemoteConfigService().adsEnabled) {
    print('📢 Ads enabled via Remote Config - initializing ad services');
    adMobRequestConsent();
    adMobUpdateRequestConfiguration();
    
    await AdMobRewardedService.initialize();
    await AdMobAppOpenService.initialize();
    await AdMobBannerService.initialize();
    await AppLovinService.initialize();
  } else {
    print('🚫 Ads disabled via Remote Config - skipping ad initialization');
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Locale? _locale;

  ThemeMode _themeMode = FlutterFlowTheme.themeMode;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  bool _hasShownAppOpenAd = false;
  String getRoute([RouteMatch? routeMatch]) {
    final RouteMatch lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }

  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e))
          .toList();
  bool displaySplashImage = true;

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
    WidgetsBinding.instance.addObserver(this);

    Future.delayed(Duration(milliseconds: 1000), () {
      safeSetState(() => _appStateNotifier.stopShowingSplashImage());
      
      // Show App Open Ad on first launch (only if ads enabled via Remote Config)
      if (!_hasShownAppOpenAd && RemoteConfigService().appOpenAdsEnabled) {
        _hasShownAppOpenAd = true;
        _showAppOpenAdWithFallback();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Show App Open ad when app returns to foreground (only if ads enabled)
    if (state == AppLifecycleState.resumed && _hasShownAppOpenAd && RemoteConfigService().appOpenAdsEnabled) {
      _showAppOpenAdWithFallback();
    }
  }

  void _showAppOpenAdWithFallback() async {
    final remoteConfig = RemoteConfigService();
    final preferredNetwork = remoteConfig.appOpenAdNetwork.toLowerCase();
    debugPrint('📺 App Open ad network preference: $preferredNetwork');

    if (preferredNetwork == 'applovin') {
      // AppLovin only (no fallback)
      await AppLovinService.showAppOpenAd(
        onComplete: () {
          debugPrint('✅ AppLovin App Open ad completed');
        },
      );
    } else if (preferredNetwork == 'admob') {
      // AdMob only (no fallback)
      await AdMobAppOpenService.showAppOpenAd(
        onComplete: () {
          debugPrint('✅ AdMob App Open ad completed');
        },
      );
    } else {
      // Auto mode: Try AdMob first, then AppLovin as fallback
      final adMobShown = await AdMobAppOpenService.showAppOpenAd(
        onComplete: () {
          debugPrint('✅ AdMob App Open ad completed');
        },
      );
      
      if (!adMobShown) {
        debugPrint('⚠️ AdMob App Open not available - using AppLovin fallback');
        await AppLovinService.showAppOpenAd(
          onComplete: () {
            debugPrint('✅ AppLovin App Open ad completed (fallback)');
          },
        );
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void setLocale(String language) {
    safeSetState(() => _locale = createLocale(language));
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Viso AI - Photo Avatar Headshot',
      localizationsDelegates: [
        FFLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FallbackMaterialLocalizationDelegate(),
        FallbackCupertinoLocalizationDelegate(),
      ],
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('es'),
        Locale('pt'),
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
      ],
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: false,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: false,
      ),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}
