import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/components/bottom_navigation_with_ad.dart';
import '/main.dart';
import '/index.dart';
import '/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'settings_model.dart';
export 'settings_model.dart';

/// Settings Menu Overview
class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  static String routeName = 'settings';
  static String routePath = '/settings';

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  late SettingsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SettingsModel());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentTheme = FlutterFlowTheme.themeMode;
      if (currentTheme == ThemeMode.system) {
        MyApp.of(context).setThemeMode(ThemeMode.light);
      }
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFFF9FAFB),
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      [
                            Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Color(0xFF8B5CF6),
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            FFLocalizations.of(context).getText(
                                              'zyn1ia3y' /* Unlimited Artwork Styles */,
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .headlineSmall
                                                .override(
                                                  font: GoogleFonts.interTight(
                                                    fontWeight: FontWeight.bold,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                              context,
                                                            )
                                                            .headlineSmall
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                    context,
                                                  ).secondaryBackground,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).headlineSmall.fontStyle,
                                                ),
                                          ),
                                          FFButtonWidget(
                                            onPressed: () async {
                                              context.pushNamed(
                                                ProWidget.routeName,
                                              );
                                            },
                                            text: FFLocalizations.of(context)
                                                .getText(
                                                  '4xq2h1kh' /* Try Pro Now */,
                                                ),
                                            options: FFButtonOptions(
                                              height: 44.0,
                                              padding:
                                                  EdgeInsetsDirectional.fromSTEB(
                                                    24.0,
                                                    0.0,
                                                    24.0,
                                                    0.0,
                                                  ),
                                              iconPadding:
                                                  EdgeInsetsDirectional.fromSTEB(
                                                    0.0,
                                                    0.0,
                                                    0.0,
                                                    0.0,
                                                  ),
                                              color: Color(0xFF155DFC),
                                              textStyle:
                                                  FlutterFlowTheme.of(
                                                    context,
                                                  ).titleSmall.override(
                                                    font: GoogleFonts.interTight(
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                context,
                                                              )
                                                              .titleSmall
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                context,
                                                              )
                                                              .titleSmall
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                      context,
                                                    ).secondaryBackground,
                                                    letterSpacing: 0.0,
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).titleSmall.fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).titleSmall.fontStyle,
                                                  ),
                                              elevation: 0.0,
                                              borderRadius:
                                                  BorderRadius.circular(24.0),
                                            ),
                                          ),
                                        ].divide(SizedBox(height: 16.0)),
                                      ),
                                      Container(
                                        width: 80.0,
                                        height: 80.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(
                                            context,
                                          ).secondaryBackground,
                                          borderRadius: BorderRadius.circular(
                                            20.0,
                                          ),
                                        ),
                                        child: Align(
                                          alignment: AlignmentDirectional(
                                            0.0,
                                            0.0,
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              FFLocalizations.of(
                                                context,
                                              ).getText('x7q50ysa' /* 👑 */),
                                              style:
                                                  FlutterFlowTheme.of(
                                                    context,
                                                  ).displayMedium.override(
                                                    font: GoogleFonts.interTight(
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                context,
                                                              )
                                                              .displayMedium
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                context,
                                                              )
                                                              .displayMedium
                                                              .fontStyle,
                                                    ),
                                                    letterSpacing: 0.0,
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                              context,
                                                            )
                                                            .displayMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                              context,
                                                            )
                                                            .displayMedium
                                                            .fontStyle,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(
                                  context,
                                ).secondaryBackground,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Material(
                                      color: Colors.transparent,
                                      child: ListTile(
                                        onTap: () => _shareApp(),
                                        leading: Icon(
                                          Icons.share,
                                          color: Color(0xFF101828),
                                          size: 20.0,
                                        ),
                                        title: Text(
                                          FFLocalizations.of(
                                            context,
                                          ).getText('h1v7pqwe' /* Share */),
                                          style: FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .override(
                                                font: GoogleFonts.interTight(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).titleSmall.fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).titleSmall.fontStyle,
                                                ),
                                                color: Color(0xFF101828),
                                                letterSpacing: 0.0,
                                                fontWeight: FlutterFlowTheme.of(
                                                  context,
                                                ).titleSmall.fontWeight,
                                                fontStyle: FlutterFlowTheme.of(
                                                  context,
                                                ).titleSmall.fontStyle,
                                              ),
                                        ),
                                        trailing: Icon(
                                          Icons.chevron_right,
                                          color: Color(0xFF9CA3AF),
                                          size: 20.0,
                                        ),
                                        tileColor: FlutterFlowTheme.of(
                                          context,
                                        ).secondaryBackground,
                                        dense: false,
                                        contentPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                              16.0,
                                              12.0,
                                              16.0,
                                              12.0,
                                            ),
                                      ),
                                    ),
                                    Divider(
                                      height: 1.0,
                                      thickness: 1.0,
                                      color: Color(0xFFF1F5F9),
                                    ),
                                    Material(
                                      color: Colors.transparent,
                                      child: ListTile(
                                        onTap: () => _showThemeDialog(),
                                        leading: Icon(
                                          Icons.palette,
                                          color: Color(0xFF101828),
                                          size: 20.0,
                                        ),
                                        title: Text(
                                          'Theme',
                                          style: FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .override(
                                                font: GoogleFonts.interTight(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).titleSmall.fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).titleSmall.fontStyle,
                                                ),
                                                color: Color(0xFF101828),
                                                letterSpacing: 0.0,
                                                fontWeight: FlutterFlowTheme.of(
                                                  context,
                                                ).titleSmall.fontWeight,
                                                fontStyle: FlutterFlowTheme.of(
                                                  context,
                                                ).titleSmall.fontStyle,
                                              ),
                                        ),
                                        subtitle: Text(
                                          _getThemeModeName(),
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).bodySmall.fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).bodySmall.fontStyle,
                                                ),
                                                color: Color(0xFF4A5565),
                                                letterSpacing: 0.0,
                                                fontWeight: FlutterFlowTheme.of(
                                                  context,
                                                ).bodySmall.fontWeight,
                                                fontStyle: FlutterFlowTheme.of(
                                                  context,
                                                ).bodySmall.fontStyle,
                                              ),
                                        ),
                                        trailing: Icon(
                                          Icons.chevron_right,
                                          color: Color(0xFF9CA3AF),
                                          size: 20.0,
                                        ),
                                        tileColor: FlutterFlowTheme.of(
                                          context,
                                        ).secondaryBackground,
                                        dense: false,
                                        contentPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                              16.0,
                                              12.0,
                                              16.0,
                                              12.0,
                                            ),
                                      ),
                                    ),
                                    Divider(
                                      height: 1.0,
                                      thickness: 1.0,
                                      color: Color(0xFFF1F5F9),
                                    ),
                                    Material(
                                      color: Colors.transparent,
                                      child: ListTile(
                                        onTap: () => _sendFeedback(),
                                        leading: Icon(
                                          Icons.feedback,
                                          color: Color(0xFF101828),
                                          size: 20.0,
                                        ),
                                        title: Text(
                                          FFLocalizations.of(
                                            context,
                                          ).getText('mvzdzzj2' /* Feedback */),
                                          style: FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .override(
                                                font: GoogleFonts.interTight(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).titleSmall.fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).titleSmall.fontStyle,
                                                ),
                                                color: Color(0xFF101828),
                                                letterSpacing: 0.0,
                                                fontWeight: FlutterFlowTheme.of(
                                                  context,
                                                ).titleSmall.fontWeight,
                                                fontStyle: FlutterFlowTheme.of(
                                                  context,
                                                ).titleSmall.fontStyle,
                                              ),
                                        ),
                                        trailing: Icon(
                                          Icons.chevron_right,
                                          color: Color(0xFF9CA3AF),
                                          size: 20.0,
                                        ),
                                        tileColor: FlutterFlowTheme.of(
                                          context,
                                        ).secondaryBackground,
                                        dense: false,
                                        contentPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                              16.0,
                                              12.0,
                                              16.0,
                                              12.0,
                                            ),
                                      ),
                                    ),
                                    Divider(
                                      height: 1.0,
                                      thickness: 1.0,
                                      color: Color(0xFFF1F5F9),
                                    ),
                                    Material(
                                      color: Colors.transparent,
                                      child: ListTile(
                                        onTap: () async {
                                          await showDialog(
                                            context: context,
                                            builder: (alertDialogContext) {
                                              return _buildLanguageDialog(
                                                context,
                                              );
                                            },
                                          );
                                        },
                                        leading: Icon(
                                          Icons.language,
                                          color: Color(0xFF101828),
                                          size: 20.0,
                                        ),
                                        title: Text(
                                          FFLocalizations.of(
                                            context,
                                          ).getText('yrhjm7a5' /* Language */),
                                          style: FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .override(
                                                font: GoogleFonts.interTight(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).titleSmall.fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).titleSmall.fontStyle,
                                                ),
                                                color: Color(0xFF101828),
                                                letterSpacing: 0.0,
                                                fontWeight: FlutterFlowTheme.of(
                                                  context,
                                                ).titleSmall.fontWeight,
                                                fontStyle: FlutterFlowTheme.of(
                                                  context,
                                                ).titleSmall.fontStyle,
                                              ),
                                        ),
                                        trailing: Icon(
                                          Icons.chevron_right,
                                          color: Color(0xFF9CA3AF),
                                          size: 20.0,
                                        ),
                                        tileColor: FlutterFlowTheme.of(
                                          context,
                                        ).secondaryBackground,
                                        dense: false,
                                        contentPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                              16.0,
                                              12.0,
                                              16.0,
                                              12.0,
                                            ),
                                      ),
                                    ),
                                    Divider(
                                      height: 1.0,
                                      thickness: 1.0,
                                      color: Color(0xFFF1F5F9),
                                    ),
                                    Material(
                                      color: Colors.transparent,
                                      child: ListTile(
                                        onTap: () => _showAbout(),
                                        leading: Icon(
                                          Icons.info,
                                          color: Color(0xFF101828),
                                          size: 20.0,
                                        ),
                                        title: Text(
                                          FFLocalizations.of(
                                            context,
                                          ).getText('bygomt0g' /* About */),
                                          style: FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .override(
                                                font: GoogleFonts.interTight(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).titleSmall.fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).titleSmall.fontStyle,
                                                ),
                                                color: Color(0xFF101828),
                                                letterSpacing: 0.0,
                                                fontWeight: FlutterFlowTheme.of(
                                                  context,
                                                ).titleSmall.fontWeight,
                                                fontStyle: FlutterFlowTheme.of(
                                                  context,
                                                ).titleSmall.fontStyle,
                                              ),
                                        ),
                                        trailing: Icon(
                                          Icons.chevron_right,
                                          color: Color(0xFF9CA3AF),
                                          size: 20.0,
                                        ),
                                        tileColor: FlutterFlowTheme.of(
                                          context,
                                        ).secondaryBackground,
                                        dense: false,
                                        contentPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                              16.0,
                                              12.0,
                                              16.0,
                                              12.0,
                                            ),
                                      ),
                                    ),
                                    Divider(
                                      height: 1.0,
                                      thickness: 1.0,
                                      color: Color(0xFFF1F5F9),
                                    ),
                                    Material(
                                      color: Colors.transparent,
                                      child: ListTile(
                                        onTap: () => _showUserAgreement(),
                                        leading: Icon(
                                          Icons.description,
                                          color: Color(0xFF101828),
                                          size: 20.0,
                                        ),
                                        title: Text(
                                          FFLocalizations.of(context).getText(
                                            'te3zrkvj' /* User Agreement */,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .override(
                                                font: GoogleFonts.interTight(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).titleSmall.fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).titleSmall.fontStyle,
                                                ),
                                                color: Color(0xFF101828),
                                                letterSpacing: 0.0,
                                                fontWeight: FlutterFlowTheme.of(
                                                  context,
                                                ).titleSmall.fontWeight,
                                                fontStyle: FlutterFlowTheme.of(
                                                  context,
                                                ).titleSmall.fontStyle,
                                              ),
                                        ),
                                        trailing: Icon(
                                          Icons.chevron_right,
                                          color: Color(0xFF9CA3AF),
                                          size: 20.0,
                                        ),
                                        tileColor: FlutterFlowTheme.of(
                                          context,
                                        ).secondaryBackground,
                                        dense: false,
                                        contentPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                              16.0,
                                              12.0,
                                              16.0,
                                              12.0,
                                            ),
                                      ),
                                    ),
                                    Divider(
                                      height: 1.0,
                                      thickness: 1.0,
                                      color: Color(0xFFF1F5F9),
                                    ),
                                    Material(
                                      color: Colors.transparent,
                                      child: ListTile(
                                        onTap: () => _showPrivacyPolicy(),
                                        leading: Icon(
                                          Icons.privacy_tip,
                                          color: Color(0xFF101828),
                                          size: 20.0,
                                        ),
                                        title: Text(
                                          FFLocalizations.of(context).getText(
                                            'u64axgle' /* Privacy Policy */,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .override(
                                                font: GoogleFonts.interTight(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).titleSmall.fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).titleSmall.fontStyle,
                                                ),
                                                color: Color(0xFF101828),
                                                letterSpacing: 0.0,
                                                fontWeight: FlutterFlowTheme.of(
                                                  context,
                                                ).titleSmall.fontWeight,
                                                fontStyle: FlutterFlowTheme.of(
                                                  context,
                                                ).titleSmall.fontStyle,
                                              ),
                                        ),
                                        trailing: Icon(
                                          Icons.chevron_right,
                                          color: Color(0xFF9CA3AF),
                                          size: 20.0,
                                        ),
                                        tileColor: FlutterFlowTheme.of(
                                          context,
                                        ).secondaryBackground,
                                        dense: false,
                                        contentPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                              16.0,
                                              12.0,
                                              16.0,
                                              12.0,
                                            ),
                                      ),
                                    ),
                                    Divider(
                                      height: 1.0,
                                      thickness: 1.0,
                                      color: Color(0xFFF1F5F9),
                                    ),
                                    Material(
                                      color: Colors.transparent,
                                      child: ListTile(
                                        onTap: () => _showCommunityGuidelines(),
                                        leading: Icon(
                                          Icons.people,
                                          color: Color(0xFF101828),
                                          size: 20.0,
                                        ),
                                        title: Text(
                                          FFLocalizations.of(context).getText(
                                            'txw2u4xk' /* Community Guidelines */,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .override(
                                                font: GoogleFonts.interTight(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).titleSmall.fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).titleSmall.fontStyle,
                                                ),
                                                color: Color(0xFF101828),
                                                letterSpacing: 0.0,
                                                fontWeight: FlutterFlowTheme.of(
                                                  context,
                                                ).titleSmall.fontWeight,
                                                fontStyle: FlutterFlowTheme.of(
                                                  context,
                                                ).titleSmall.fontStyle,
                                              ),
                                        ),
                                        trailing: Icon(
                                          Icons.chevron_right,
                                          color: Color(0xFF9CA3AF),
                                          size: 20.0,
                                        ),
                                        tileColor: FlutterFlowTheme.of(
                                          context,
                                        ).secondaryBackground,
                                        dense: false,
                                        contentPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                              16.0,
                                              12.0,
                                              16.0,
                                              12.0,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ]
                          .divide(SizedBox(height: 16.0))
                          .addToStart(SizedBox(height: 16.0))
                          .addToEnd(SizedBox(height: 160.0)),
                ),
              ),
              BottomNavigationWithAd(currentPage: 'mine'),
            ],
          ),
        ),
      ),
    );
  }

  String _getThemeModeName() {
    final themeMode = FlutterFlowTheme.themeMode;
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
      default:
        return 'Light';
    }
  }

  void _showThemeDialog() {
    final currentTheme = FlutterFlowTheme.themeMode;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select Theme',
            style: FlutterFlowTheme.of(context).headlineSmall.override(
              font: GoogleFonts.interTight(
                fontWeight: FontWeight.bold,
                fontStyle: FlutterFlowTheme.of(context).headlineSmall.fontStyle,
              ),
              letterSpacing: 0.0,
              fontWeight: FontWeight.bold,
              fontStyle: FlutterFlowTheme.of(context).headlineSmall.fontStyle,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.light_mode,
                  color: currentTheme == ThemeMode.light
                      ? Color(0xFF9810FA)
                      : Color(0xFF4A5565),
                ),
                title: Text(
                  'Light',
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                    font: GoogleFonts.interTight(
                      fontWeight: FlutterFlowTheme.of(
                        context,
                      ).titleMedium.fontWeight,
                      fontStyle: FlutterFlowTheme.of(
                        context,
                      ).titleMedium.fontStyle,
                    ),
                    color: currentTheme == ThemeMode.light
                        ? Color(0xFF9810FA)
                        : Color(0xFF101828),
                    letterSpacing: 0.0,
                    fontWeight: FlutterFlowTheme.of(
                      context,
                    ).titleMedium.fontWeight,
                    fontStyle: FlutterFlowTheme.of(
                      context,
                    ).titleMedium.fontStyle,
                  ),
                ),
                trailing: currentTheme == ThemeMode.light
                    ? Icon(Icons.check, color: Color(0xFF9810FA))
                    : null,
                onTap: () {
                  MyApp.of(context).setThemeMode(ThemeMode.light);
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
              Divider(height: 1.0, thickness: 1.0),
              ListTile(
                leading: Icon(
                  Icons.dark_mode,
                  color: currentTheme == ThemeMode.dark
                      ? Color(0xFF9810FA)
                      : Color(0xFF4A5565),
                ),
                title: Text(
                  'Dark',
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                    font: GoogleFonts.interTight(
                      fontWeight: FlutterFlowTheme.of(
                        context,
                      ).titleMedium.fontWeight,
                      fontStyle: FlutterFlowTheme.of(
                        context,
                      ).titleMedium.fontStyle,
                    ),
                    color: currentTheme == ThemeMode.dark
                        ? Color(0xFF9810FA)
                        : Color(0xFF101828),
                    letterSpacing: 0.0,
                    fontWeight: FlutterFlowTheme.of(
                      context,
                    ).titleMedium.fontWeight,
                    fontStyle: FlutterFlowTheme.of(
                      context,
                    ).titleMedium.fontStyle,
                  ),
                ),
                trailing: currentTheme == ThemeMode.dark
                    ? Icon(Icons.check, color: Color(0xFF9810FA))
                    : null,
                onTap: () {
                  MyApp.of(context).setThemeMode(ThemeMode.dark);
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(
                    fontWeight: FlutterFlowTheme.of(
                      context,
                    ).bodyMedium.fontWeight,
                    fontStyle: FlutterFlowTheme.of(
                      context,
                    ).bodyMedium.fontStyle,
                  ),
                  color: Color(0xFF4A5565),
                  letterSpacing: 0.0,
                  fontWeight: FlutterFlowTheme.of(
                    context,
                  ).bodyMedium.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLanguageDialog(BuildContext context) {
    final currentLocale = FFLocalizations.of(context).languageCode;
    final languages = FFLocalizations.languages();
    final languageNames = FFLocalizations.languageNames();

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        'Select Language',
        style: FlutterFlowTheme.of(context).headlineSmall.override(
          font: GoogleFonts.interTight(
            fontWeight: FlutterFlowTheme.of(context).headlineSmall.fontWeight,
            fontStyle: FlutterFlowTheme.of(context).headlineSmall.fontStyle,
          ),
          color: Color(0xFF101828),
          letterSpacing: 0.0,
          fontWeight: FlutterFlowTheme.of(context).headlineSmall.fontWeight,
          fontStyle: FlutterFlowTheme.of(context).headlineSmall.fontStyle,
        ),
      ),
      content: Container(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: languages.length,
          separatorBuilder: (context, index) =>
              Divider(height: 1.0, thickness: 1.0),
          itemBuilder: (context, index) {
            final languageCode = languages[index];
            final languageName = languageNames[languageCode] ?? languageCode;
            final isSelected = currentLocale == languageCode;

            return ListTile(
              leading: Icon(
                Icons.language,
                color: isSelected ? Color(0xFF8B5CF6) : Color(0xFF4A5565),
              ),
              title: Text(
                languageName,
                style: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight: FlutterFlowTheme.of(
                      context,
                    ).titleMedium.fontWeight,
                    fontStyle: FlutterFlowTheme.of(
                      context,
                    ).titleMedium.fontStyle,
                  ),
                  color: isSelected ? Color(0xFF8B5CF6) : Color(0xFF101828),
                  letterSpacing: 0.0,
                  fontWeight: FlutterFlowTheme.of(
                    context,
                  ).titleMedium.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).titleMedium.fontStyle,
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check, color: Color(0xFF8B5CF6))
                  : null,
              onTap: () {
                MyApp.of(context).setLocale(languageCode);
                FFLocalizations.storeLocale(languageCode);
                Navigator.pop(context);
                setState(() {});
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.inter(
                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
              ),
              color: Color(0xFF4A5565),
              letterSpacing: 0.0,
              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
            ),
          ),
        ),
      ],
    );
  }

  void _shareApp() async {
    final String appUrl = 'https://visoai.replit.app';
    final String message =
        '✨ Transform your photos with AI magic! Create stunning AI headshots & avatars with Viso AI 🎨\n\n📸 60+ Professional Styles\n🚀 Studio-Quality Results\n⚡ Fast & Easy to Use\n\nTry it now: $appUrl\n\n#VisoAI #AIHeadshot #AIAvatar';

    try {
      await Share.share(
        message,
        subject: 'Check out Viso AI - AI Photo & Avatar Creator!',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _sendFeedback() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: kSupportEmail,
      query:
          'subject=Viso AI Feedback&body=Hello Viso AI Team,%0D%0A%0D%0AI would like to give feedback:%0D%0A%0D%0A',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        throw 'Could not launch email client';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open email: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFF8B5CF6)),
            SizedBox(width: 12),
            Text(
              'About Viso AI',
              style: FlutterFlowTheme.of(context).headlineSmall.override(
                font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Viso AI - AI Photo & Avatar Creator',
                style: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                  color: Color(0xFF8B5CF6),
                  letterSpacing: 0.0,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Transform your photos into studio-grade AI headshots and avatars in minutes. Powered by advanced AI technology to create professional, stylized images for any occasion.',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(),
                  letterSpacing: 0.0,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Features:',
                style: FlutterFlowTheme.of(context).titleSmall.override(
                  font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                  letterSpacing: 0.0,
                ),
              ),
              SizedBox(height: 8),
              _buildBulletPoint('60+ Professional AI Styles'),
              _buildBulletPoint('HD Photo Enhancement'),
              _buildBulletPoint('Old Photo Restoration'),
              _buildBulletPoint('AI Face Swapping'),
              _buildBulletPoint('Multiple Languages Support'),
              SizedBox(height: 16),
              Text(
                'Version: 1.0.0',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                  font: GoogleFonts.inter(),
                  color: Color(0xFF6B7280),
                  letterSpacing: 0.0,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(),
                color: Color(0xFF8B5CF6),
                letterSpacing: 0.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUserAgreement() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.description, color: Color(0xFF8B5CF6)),
            SizedBox(width: 12),
            Text(
              'User Agreement',
              style: FlutterFlowTheme.of(context).headlineSmall.override(
                font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            'Terms of Use\n\nBy using Viso AI, you agree to our terms and conditions. This app is provided "as is" for creating AI-generated photos and avatars.\n\nYou agree to:\n• Use the app responsibly\n• Not upload inappropriate content\n• Respect intellectual property rights\n• Accept that AI results may vary\n\nWe reserve the right to:\n• Modify these terms at any time\n• Suspend service for maintenance\n• Terminate accounts violating terms\n\n[Content will be updated by developer]',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.inter(),
              letterSpacing: 0.0,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(),
                color: Color(0xFF8B5CF6),
                letterSpacing: 0.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.privacy_tip, color: Color(0xFF8B5CF6)),
            SizedBox(width: 12),
            Text(
              'Privacy Policy',
              style: FlutterFlowTheme.of(context).headlineSmall.override(
                font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            'Privacy Policy\n\nYour privacy is important to us. This policy explains how we collect, use, and protect your data.\n\nData We Collect:\n• Photos you upload for AI processing\n• App usage statistics\n• Device information\n\nHow We Use Data:\n• To process your photos with AI\n• To improve our services\n• To provide customer support\n\nData Security:\n• Photos are processed securely\n• We do not sell your data\n• You can request data deletion\n\nContact us at $kSupportEmail for privacy concerns.\n\n[Content will be updated by developer]',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.inter(),
              letterSpacing: 0.0,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(),
                color: Color(0xFF8B5CF6),
                letterSpacing: 0.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCommunityGuidelines() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.people, color: Color(0xFF8B5CF6)),
            SizedBox(width: 12),
            Text(
              'Community Guidelines',
              style: FlutterFlowTheme.of(context).headlineSmall.override(
                font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            'Community Guidelines\n\nTo maintain a safe and respectful community, please follow these guidelines:\n\n✓ Do:\n• Be respectful to others\n• Use appropriate content\n• Report violations\n• Give constructive feedback\n• Respect privacy\n\n✗ Don\'t:\n• Upload inappropriate images\n• Harass other users\n• Share illegal content\n• Violate intellectual property\n• Abuse the service\n\nViolations may result in account suspension or termination.\n\nReport issues to: $kSupportEmail\n\n[Content will be updated by developer]',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.inter(),
              letterSpacing: 0.0,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(),
                color: Color(0xFF8B5CF6),
                letterSpacing: 0.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.inter(),
              color: Color(0xFF8B5CF6),
              letterSpacing: 0.0,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(),
                letterSpacing: 0.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
