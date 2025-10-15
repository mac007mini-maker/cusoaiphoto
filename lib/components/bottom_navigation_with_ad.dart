import '/flutter_flow/flutter_flow_ad_banner.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/services/remote_config_service.dart';
import '/services/admob_banner_service.dart';
import '/services/applovin_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:applovin_max/applovin_max.dart' if (dart.library.html) '/services/applovin_stub.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class BottomNavigationWithAd extends StatefulWidget {
  final String currentPage;

  const BottomNavigationWithAd({
    super.key,
    required this.currentPage,
  });

  @override
  State<BottomNavigationWithAd> createState() => _BottomNavigationWithAdState();
}

class _BottomNavigationWithAdState extends State<BottomNavigationWithAd> {
  bool _adMobFailed = false;

  @override
  Widget build(BuildContext context) {
    final remoteConfig = RemoteConfigService();
    final showAds = remoteConfig.adsEnabled && remoteConfig.bannerAdsEnabled;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showAds && !kIsWeb)
            _buildBannerAdWidget(),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 4.0,
                  color: Color(0x33000000),
                  offset: Offset(0.0, -2.0),
                )
              ],
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 20.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: widget.currentPage != 'homepage'
                        ? () async {
                            context.pushNamed(HomepageWidget.routeName);
                          }
                        : null,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.home,
                          color: widget.currentPage == 'homepage'
                              ? Color(0xFF9810FA)
                              : Color(0xFF6B7280),
                          size: 24.0,
                        ),
                        Text(
                          'Home',
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                                font: GoogleFonts.inter(),
                                color: widget.currentPage == 'homepage'
                                    ? Color(0xFF9810FA)
                                    : Color(0xFF6B7280),
                                fontSize: 12.0,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: widget.currentPage != 'aitools'
                        ? () async {
                            context.pushNamed(AitoolsWidget.routeName);
                          }
                        : null,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: widget.currentPage == 'aitools'
                              ? Color(0xFF9810FA)
                              : Color(0xFF6B7280),
                          size: 24.0,
                        ),
                        Text(
                          'AI Tools',
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                                font: GoogleFonts.inter(),
                                color: widget.currentPage == 'aitools'
                                    ? Color(0xFF9810FA)
                                    : Color(0xFF6B7280),
                                fontSize: 12.0,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: widget.currentPage != 'mine'
                        ? () async {
                            context.pushNamed(MineWidget.routeName);
                          }
                        : null,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person,
                          color: widget.currentPage == 'mine'
                              ? Color(0xFF9810FA)
                              : Color(0xFF6B7280),
                          size: 24.0,
                        ),
                        Text(
                          'Mine',
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                                font: GoogleFonts.inter(),
                                color: widget.currentPage == 'mine'
                                    ? Color(0xFF9810FA)
                                    : Color(0xFF6B7280),
                                fontSize: 12.0,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerAdWidget() {
    // Web platform: Skip ad loading (not supported)
    if (kIsWeb) {
      return SizedBox.shrink();
    }

    final remoteConfig = RemoteConfigService();
    final preferredNetwork = remoteConfig.bannerAdNetwork.toLowerCase();
    debugPrint('📺 Banner ad network preference: $preferredNetwork');

    // AppLovin only (no fallback)
    if (preferredNetwork == 'applovin') {
      if (AppLovinService.bannerAdUnitId != null && AppLovinService.bannerAdUnitId!.isNotEmpty) {
        return Container(
          height: 50.0,
          color: Colors.black,
          child: MaxAdView(
            adUnitId: AppLovinService.bannerAdUnitId!,
            adFormat: AdFormat.banner,
            listener: AdViewAdListener(
              onAdLoadedCallback: (ad) {
                debugPrint('✅ AppLovin Banner ad loaded');
              },
              onAdLoadFailedCallback: (adUnitId, error) {
                debugPrint('❌ AppLovin Banner ad failed: ${error.message}');
              },
              onAdClickedCallback: (ad) {
                debugPrint('👆 AppLovin Banner ad clicked');
              },
              onAdExpandedCallback: (ad) {
                debugPrint('📺 AppLovin Banner ad expanded');
              },
              onAdCollapsedCallback: (ad) {
                debugPrint('📉 AppLovin Banner ad collapsed');
              },
            ),
          ),
        );
      }
      return SizedBox.shrink();
    }

    // AdMob only (no fallback)
    if (preferredNetwork == 'admob') {
      final adUnitId = AdMobBannerService.getBannerAdUnitId();
      if (adUnitId.isNotEmpty) {
        return Container(
          height: 50.0,
          child: FlutterFlowAdBanner(
            height: 50,
            showsTestAd: adUnitId.contains('3940256099942544'),
            androidAdUnitID: adUnitId,
            iOSAdUnitID: adUnitId,
            onAdFailedToLoad: () {
              debugPrint('❌ AdMob Banner failed');
            },
          ),
        );
      }
      return SizedBox.shrink();
    }

    // Auto mode: Try AdMob first, then AppLovin as fallback
    if (!_adMobFailed) {
      final adUnitId = AdMobBannerService.getBannerAdUnitId();
      
      if (adUnitId.isNotEmpty) {
        return Container(
          height: 50.0,
          child: FlutterFlowAdBanner(
            height: 50,
            showsTestAd: adUnitId.contains('3940256099942544'),
            androidAdUnitID: adUnitId,
            iOSAdUnitID: adUnitId,
            onAdFailedToLoad: () {
              debugPrint('❌ AdMob Banner failed - switching to AppLovin fallback');
              setState(() {
                _adMobFailed = true;
              });
            },
          ),
        );
      }
    }

    // AppLovin fallback (auto mode)
    if (AppLovinService.bannerAdUnitId != null && AppLovinService.bannerAdUnitId!.isNotEmpty) {
      return Container(
        height: 50.0,
        color: Colors.black,
        child: MaxAdView(
          adUnitId: AppLovinService.bannerAdUnitId!,
          adFormat: AdFormat.banner,
          listener: AdViewAdListener(
            onAdLoadedCallback: (ad) {
              debugPrint('✅ AppLovin Banner ad loaded (fallback)');
            },
            onAdLoadFailedCallback: (adUnitId, error) {
              debugPrint('❌ AppLovin Banner ad failed: ${error.message}');
            },
            onAdClickedCallback: (ad) {
              debugPrint('👆 AppLovin Banner ad clicked');
            },
            onAdExpandedCallback: (ad) {
              debugPrint('📺 AppLovin Banner ad expanded');
            },
            onAdCollapsedCallback: (ad) {
              debugPrint('📉 AppLovin Banner ad collapsed');
            },
          ),
        ),
      );
    }

    return Container(
      height: 50.0,
      color: Colors.black,
      child: Center(
        child: Text(
          'Ad Loading...',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}
