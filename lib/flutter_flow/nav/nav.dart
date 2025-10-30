import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/flutter_flow/flutter_flow_util.dart';

import '/index.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class InitialPageWidget extends StatelessWidget {
  const InitialPageWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkHasSeenIntro(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.white,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        
        final hasSeenIntro = snapshot.data ?? false;
        return hasSeenIntro ? HomepageWidget() : Intro1Widget();
      },
    );
  }

  Future<bool> _checkHasSeenIntro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasSeenIntro') ?? false;
  }
}

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  bool showSplashImage = true;

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      errorBuilder: (context, state) => appStateNotifier.showSplashImage
          ? Builder(
              builder: (context) => Container(
                color: Colors.transparent,
                child: Image.asset(
                  'assets/images/viso-ai.png',
                  fit: BoxFit.cover,
                ),
              ),
            )
          : InitialPageWidget(),
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) => appStateNotifier.showSplashImage
              ? Builder(
                  builder: (context) => Container(
                    color: Colors.transparent,
                    child: Image.asset(
                      'assets/images/viso-ai.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : InitialPageWidget(),
        ),
        FFRoute(
          name: XPageWidget.routeName,
          path: XPageWidget.routePath,
          builder: (context, params) => XPageWidget(),
        ),
        FFRoute(
          name: Intro1Widget.routeName,
          path: Intro1Widget.routePath,
          builder: (context, params) => Intro1Widget(),
        ),
        FFRoute(
          name: Intro2Widget.routeName,
          path: Intro2Widget.routePath,
          builder: (context, params) => Intro2Widget(),
        ),
        FFRoute(
          name: Intro3Widget.routeName,
          path: Intro3Widget.routePath,
          builder: (context, params) => Intro3Widget(),
        ),
        FFRoute(
          name: IapWidget.routeName,
          path: IapWidget.routePath,
          builder: (context, params) => IapWidget(),
        ),
        FFRoute(
          name: HomepageWidget.routeName,
          path: HomepageWidget.routePath,
          builder: (context, params) => HomepageWidget(),
        ),
        FFRoute(
          name: AitoolsWidget.routeName,
          path: AitoolsWidget.routePath,
          builder: (context, params) => AitoolsWidget(),
        ),
        FFRoute(
          name: MineWidget.routeName,
          path: MineWidget.routePath,
          builder: (context, params) => MineWidget(),
        ),
        FFRoute(
          name: ProWidget.routeName,
          path: ProWidget.routePath,
          builder: (context, params) => ProWidget(),
        ),
        FFRoute(
          name: SettingsWidget.routeName,
          path: SettingsWidget.routePath,
          builder: (context, params) => SettingsWidget(),
        ),
        FFRoute(
          name: AiphotoWidget.routeName,
          path: AiphotoWidget.routePath,
          builder: (context, params) => AiphotoWidget(),
        ),
        FFRoute(
          name: FemaleWidget.routeName,
          path: FemaleWidget.routePath,
          builder: (context, params) => FemaleWidget(),
        ),
        FFRoute(
          name: MaleWidget.routeName,
          path: MaleWidget.routePath,
          builder: (context, params) => MaleWidget(),
        ),
        FFRoute(
          name: OthersWidget.routeName,
          path: OthersWidget.routePath,
          builder: (context, params) => OthersWidget(),
        ),
        FFRoute(
          name: FixoldphotoWidget.routeName,
          path: FixoldphotoWidget.routePath,
          builder: (context, params) => FixoldphotoWidget(),
        ),
        FFRoute(
          name: TrendingWidget.routeName,
          path: TrendingWidget.routePath,
          builder: (context, params) => TrendingWidget(),
        ),
        FFRoute(
          name: HdphotoWidget.routeName,
          path: HdphotoWidget.routePath,
          builder: (context, params) => HdphotoWidget(),
        ),
        FFRoute(
          name: ForyouWidget.routeName,
          path: ForyouWidget.routePath,
          builder: (context, params) => ForyouWidget(),
        ),
        FFRoute(
          name: HeadshotsWidget.routeName,
          path: HeadshotsWidget.routePath,
          builder: (context, params) => HeadshotsWidget(),
        ),
        FFRoute(
          name: TophitsWidget.routeName,
          path: TophitsWidget.routePath,
          builder: (context, params) => TophitsWidget(),
        ),
        FFRoute(
          name: ExploreWidget.routeName,
          path: ExploreWidget.routePath,
          builder: (context, params) => ExploreWidget(),
        ),
        FFRoute(
          name: SwapfaceWidget.routeName,
          path: SwapfaceWidget.routePath,
          builder: (context, params) => SwapfaceWidget(),
        ),
        FFRoute(
          name: TemplatesGalleryWidget.routeName,
          path: TemplatesGalleryWidget.routePath,
          builder: (context, params) => TemplatesGalleryWidget(),
        ),
        FFRoute(
          name: TravelWidget.routeName,
          path: TravelWidget.routePath,
          builder: (context, params) => TravelWidget(),
        ),
        FFRoute(
          name: GymWidget.routeName,
          path: GymWidget.routePath,
          builder: (context, params) => GymWidget(),
        ),
        FFRoute(
          name: SelfieWidget.routeName,
          path: SelfieWidget.routePath,
          builder: (context, params) => SelfieWidget(),
        ),
        FFRoute(
          name: TattooWidget.routeName,
          path: TattooWidget.routePath,
          builder: (context, params) => TattooWidget(),
        ),
        FFRoute(
          name: WeddingWidget.routeName,
          path: WeddingWidget.routePath,
          builder: (context, params) => WeddingWidget(),
        ),
        FFRoute(
          name: SportWidget.routeName,
          path: SportWidget.routePath,
          builder: (context, params) => SportWidget(),
        ),
        FFRoute(
          name: ChristmasWidget.routeName,
          path: ChristmasWidget.routePath,
          builder: (context, params) => ChristmasWidget(),
        ),
        FFRoute(
          name: NewyearWidget.routeName,
          path: NewyearWidget.routePath,
          builder: (context, params) => NewyearWidget(),
        ),
        FFRoute(
          name: BirthdayWidget.routeName,
          path: BirthdayWidget.routePath,
          builder: (context, params) => BirthdayWidget(),
        ),
        FFRoute(
          name: SchoolWidget.routeName,
          path: SchoolWidget.routePath,
          builder: (context, params) => SchoolWidget(),
        ),
        FFRoute(
          name: FashionshowWidget.routeName,
          path: FashionshowWidget.routePath,
          builder: (context, params) => FashionshowWidget(),
        ),
        FFRoute(
          name: ProfileWidget.routeName,
          path: ProfileWidget.routePath,
          builder: (context, params) => ProfileWidget(),
        ),
        FFRoute(
          name: SuitsWidget.routeName,
          path: SuitsWidget.routePath,
          builder: (context, params) => SuitsWidget(),
        ),
        FFRoute(
          name: AiTestWidget.routeName,
          path: AiTestWidget.routePath,
          builder: (context, params) => AiTestWidget(),
        ),
        FFRoute(
          name: CartoonToonWidget.routeName,
          path: CartoonToonWidget.routePath,
          builder: (context, params) => CartoonToonWidget(),
        ),
        FFRoute(
          name: MemojiAvatarWidget.routeName,
          path: MemojiAvatarWidget.routePath,
          builder: (context, params) => MemojiAvatarWidget(),
        ),
        FFRoute(
          name: AnimalToonWidget.routeName,
          path: AnimalToonWidget.routePath,
          builder: (context, params) => AnimalToonWidget(),
        ),
        FFRoute(
          name: MuscleEnhanceWidget.routeName,
          path: MuscleEnhanceWidget.routePath,
          builder: (context, params) => MuscleEnhanceWidget(),
        ),
        FFRoute(
          name: ArtStyleWidget.routeName,
          path: ArtStyleWidget.routePath,
          builder: (context, params) => ArtStyleWidget(),
        ),
        FFRoute(
          name: VideoSwapWidget.routeName,
          path: VideoSwapWidget.routePath,
          builder: (context, params) => VideoSwapWidget(),
        ),
        FFRoute(
          name: KieNanoBananaWidget.routeName,
          path: KieNanoBananaWidget.routePath,
          builder: (context, params) => KieNanoBananaWidget(),
        ),
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(key: state.pageKey, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
