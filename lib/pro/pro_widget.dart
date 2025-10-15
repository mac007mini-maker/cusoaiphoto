import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/services/revenue_cat_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'pro_model.dart';
export 'pro_model.dart';

/// Subscription Plan Selection
class ProWidget extends StatefulWidget {
  const ProWidget({super.key});

  static String routeName = 'pro';
  static String routePath = '/pro';

  @override
  State<ProWidget> createState() => _ProWidgetState();
}

class _ProWidgetState extends State<ProWidget> {
  late ProModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProModel());
    
    // Load RevenueCat subscription packages
    _loadSubscriptionPackages();
  }

  /// Load subscription packages from RevenueCat
  Future<void> _loadSubscriptionPackages() async {
    debugPrint('🔵 PRO WIDGET: Starting _loadSubscriptionPackages()');
    
    // Check if running on Web
    if (kIsWeb) {
      debugPrint('⚠️ PRO WIDGET: Running on Web - using hardcoded display (RevenueCat not supported)');
      setState(() {
        _model.isLoading = false;
        _model.isWebPlatform = true; // Flag to show hardcoded UI
        _model.selectedPackageIndex = 0; // Auto-select first package
      });
      return;
    }
    
    setState(() {
      _model.isLoading = true;
      _model.errorMessage = null;
    });

    try {
      debugPrint('🔵 PRO WIDGET: Calling RevenueCatService().getSubscriptionPackages()');
      final packages = await RevenueCatService().getSubscriptionPackages();
      
      debugPrint('🔵 PRO WIDGET: Received ${packages.length} packages');
      
      setState(() {
        _model.availablePackages = packages;
        _model.isLoading = false;
        
        // Auto-select first package (Lifetime - best value)
        if (packages.isNotEmpty) {
          _model.selectedPackageIndex = 0;
          debugPrint('🔵 PRO WIDGET: Auto-selected package 0');
        } else {
          debugPrint('⚠️ PRO WIDGET: Packages list is EMPTY!');
        }
      });
      
      debugPrint('✅ PRO WIDGET: Loaded ${packages.length} subscription packages');
      debugPrint('🔵 PRO WIDGET: _model.availablePackages.length = ${_model.availablePackages.length}');
    } catch (e, stackTrace) {
      debugPrint('❌ PRO WIDGET: Error loading packages: $e');
      debugPrint('❌ PRO WIDGET: Stack trace: $stackTrace');
      
      setState(() {
        _model.isLoading = false;
        _model.errorMessage = 'Failed to load subscription plans. Please try again.';
      });
    }
  }

  /// Build subscription cards dynamically from RevenueCat packages
  List<Widget> _buildSubscriptionCards() {
    debugPrint('🔵 PRO WIDGET: _buildSubscriptionCards() called - packages count: ${_model.availablePackages.length}');
    
    // Web platform: show hardcoded UI (RevenueCat not supported)
    if (_model.isWebPlatform) {
      debugPrint('🌐 PRO WIDGET: Web platform - using hardcoded cards');
      return _buildHardcodedCardsForWeb();
    }
    
    if (_model.availablePackages.isEmpty) {
      debugPrint('⚠️ PRO WIDGET: Packages is EMPTY - returning empty list');
      return [];
    }

    return _model.availablePackages.asMap().entries.map((entry) {
      final index = entry.key;
      final package = entry.value;
      final product = package.storeProduct;
      final isSelected = _model.selectedPackageIndex == index;
      
      // Package type metadata
      final isLifetime = package.packageType == PackageType.lifetime;
      final isAnnual = package.packageType == PackageType.annual;
      final isWeekly = package.packageType == PackageType.weekly;
      
      // Labels based on package type
      String badge = '';
      Color? badgeColor;
      String icon = '📦';
      String duration = '';
      
      if (isLifetime) {
        badge = 'BEST VALUE';
        badgeColor = Color(0xFF1E2939);
        icon = '∞';
        duration = 'Lifetime\n1 purchase';
      } else if (isAnnual) {
        badge = 'SAVE 89%';
        badgeColor = Color(0xFF00C950);
        icon = '📅';
        duration = 'Year\nBest value';
      } else if (isWeekly) {
        badge = '';
        icon = '🗓️';
        // Compute daily cost from weekly price
        final dailyCost = product.price / 7;
        final currencyCode = product.currencyCode;
        duration = 'Week\n${dailyCost.toStringAsFixed(0)} $currencyCode/day';
      }
      
      return GestureDetector(
        onTap: () {
          setState(() {
            _model.selectedPackageIndex = index;
          });
        },
        child: Container(
          width: 110.0,
          height: 160.0,
          decoration: BoxDecoration(
            color: isSelected 
                ? Color(0xFF9810FA) 
                : FlutterFlowTheme.of(context).accent1,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Badge (BEST VALUE, SAVE 89%)
                badge.isNotEmpty
                    ? Container(
                        width: double.infinity,
                        height: 24.0,
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Text(
                            badge,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    : SizedBox(height: 24.0),
                
                // Icon & Duration
                Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      icon,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30.0,
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      duration,
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                        font: GoogleFonts.inter(),
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        fontSize: 14.0,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ],
                ),
                
                // Price (DYNAMIC from RevenueCat!)
                Text(
                  product.priceString,
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                    ),
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    fontSize: 18.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  /// Build hardcoded subscription cards for Web (RevenueCat not supported on Web)
  List<Widget> _buildHardcodedCardsForWeb() {
    // Hardcoded subscription data matching Vietnamese pricing
    final webPackages = [
      {
        'badge': 'BEST VALUE',
        'badgeColor': Color(0xFF1E2939),
        'icon': '∞',
        'duration': 'Lifetime\n1 purchase',
        'price': '₫2,050,000',
      },
      {
        'badge': 'SAVE 89%',
        'badgeColor': Color(0xFF00C950),
        'icon': '📅',
        'duration': 'Year\nBest value',
        'price': '₫944,000',
      },
      {
        'badge': '',
        'badgeColor': null,
        'icon': '🗓️',
        'duration': 'Week\n23,571 ₫/day',
        'price': '₫165,000',
      },
    ];

    return webPackages.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final isSelected = _model.selectedPackageIndex == index;

      return GestureDetector(
        onTap: () {
          setState(() {
            _model.selectedPackageIndex = index;
          });
        },
        child: Container(
          width: 110.0,
          height: 160.0,
          decoration: BoxDecoration(
            color: isSelected 
                ? Color(0xFF9810FA) 
                : FlutterFlowTheme.of(context).accent1,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Badge
                (data['badge'] as String).isNotEmpty
                    ? Container(
                        width: double.infinity,
                        height: 24.0,
                        decoration: BoxDecoration(
                          color: data['badgeColor'] as Color?,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Text(
                            data['badge'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    : SizedBox(height: 24.0),
                
                // Icon & Duration
                Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      data['icon'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30.0,
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      data['duration'] as String,
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                        font: GoogleFonts.inter(),
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        fontSize: 14.0,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ],
                ),
                
                // Price (Hardcoded for Web)
                Text(
                  data['price'] as String,
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                    ),
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    fontSize: 18.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
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
        backgroundColor: FlutterFlowTheme.of(context).accent1,
        body: SafeArea(
          top: true,
          bottom: true,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF7C3AED),
                      Color(0xFF9810FA),
                      Color(0xFFDB2777),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(24.0, 60.0, 24.0, 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 20.0, 0.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FlutterFlowIconButton(
                                borderRadius: 20.0,
                                buttonSize: 40.0,
                                icon: Icon(
                                  Icons.close,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  size: 24.0,
                                ),
                                onPressed: () async {
                                  context.pushNamed(HomepageWidget.routeName);
                                },
                              ),
                              FFButtonWidget(
                                onPressed: () async {
                                  // Show loading
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Restoring purchases...'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  
                                  // Restore purchases
                                  try {
                                    final result = await RevenueCatService().restorePurchases();
                                    
                                    if (result.success && result.isPremium) {
                                      // Success
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('✅ Purchases restored! You are now premium.'),
                                            backgroundColor: Colors.green,
                                            duration: Duration(seconds: 3),
                                          ),
                                        );
                                        
                                        // Navigate back to homepage
                                        context.pushNamed(HomepageWidget.routeName);
                                      }
                                    } else {
                                      // No purchases found
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(result.message ?? 'No active purchases found'),
                                            backgroundColor: Colors.orange,
                                            duration: Duration(seconds: 3),
                                          ),
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Error restoring purchases: $e'),
                                          backgroundColor: Colors.red,
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                    }
                                  }
                                },
                                text: FFLocalizations.of(context).getText(
                                  '8de8u8eh' /* Restore */,
                                ),
                                options: FFButtonOptions(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 8.0, 16.0, 8.0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  color: Colors.transparent,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        fontSize: 14.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                  elevation: 0.0,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  width: 24.0,
                                  height: 24.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Icon(
                                      Icons.check,
                                      color:
                                          FlutterFlowTheme.of(context).accent1,
                                      size: 16.0,
                                    ),
                                  ),
                                ),
                                Text(
                                  FFLocalizations.of(context).getText(
                                    'iw4hphiu' /* Unlock to All Features */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        fontSize: 18.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                ),
                              ].divide(SizedBox(width: 12.0)),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  width: 24.0,
                                  height: 24.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Icon(
                                      Icons.check,
                                      color:
                                          FlutterFlowTheme.of(context).accent1,
                                      size: 16.0,
                                    ),
                                  ),
                                ),
                                Text(
                                  FFLocalizations.of(context).getText(
                                    'fed9cxw8' /* 200% Faster Processing */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        fontSize: 18.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                ),
                              ].divide(SizedBox(width: 12.0)),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  width: 24.0,
                                  height: 24.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Icon(
                                      Icons.check,
                                      color:
                                          FlutterFlowTheme.of(context).accent1,
                                      size: 16.0,
                                    ),
                                  ),
                                ),
                                Text(
                                  FFLocalizations.of(context).getText(
                                    'mpvf33qt' /* Unlimited Creations */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        fontSize: 18.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                ),
                              ].divide(SizedBox(width: 12.0)),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  width: 24.0,
                                  height: 24.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Icon(
                                      Icons.check,
                                      color:
                                          FlutterFlowTheme.of(context).accent1,
                                      size: 16.0,
                                    ),
                                  ),
                                ),
                                Text(
                                  FFLocalizations.of(context).getText(
                                    'f3xxwid4' /* Priority Access to New Content */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        fontSize: 18.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                ),
                              ].divide(SizedBox(width: 12.0)),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  width: 24.0,
                                  height: 24.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Icon(
                                      Icons.check,
                                      color:
                                          FlutterFlowTheme.of(context).accent1,
                                      size: 16.0,
                                    ),
                                  ),
                                ),
                                Text(
                                  FFLocalizations.of(context).getText(
                                    'ojg5yxpr' /* No Ads, No Watermarks */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        fontSize: 18.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                ),
                              ].divide(SizedBox(width: 12.0)),
                            ),
                          ].divide(SizedBox(height: 16.0)),
                        ),
                        // Dynamic subscription cards from RevenueCat
                        _model.isLoading
                            ? Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : _model.errorMessage != null
                                ? Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(24.0),
                                      child: Text(
                                        _model.errorMessage!,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: _buildSubscriptionCards(),
                                  ),
                        FFButtonWidget(
                          onPressed: _model.isLoading || _model.selectedPackageIndex == null
                              ? null
                              : () async {
                            // Web platform: show info message (RevenueCat not supported)
                            if (_model.isWebPlatform) {
                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('📱 Mobile App Required'),
                                    content: Text(
                                      'In-app purchases are only available on mobile devices (iOS/Android).\n\n'
                                      'Please download the Viso AI mobile app to subscribe to Premium.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return;
                            }
                            
                            // Mobile: Get selected package
                            final package = _model.availablePackages[_model.selectedPackageIndex!];
                            
                            // Show loading dialog
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => Center(
                                child: Container(
                                  padding: EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 16),
                                      Text(
                                        'Processing purchase...',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                            
                            try {
                              // Purchase package
                              final result = await RevenueCatService().purchasePackage(package);
                              
                              // Close loading dialog
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                              
                              if (result.success && result.isPremium) {
                                // Success!
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('🎉 Welcome to Premium! All features unlocked.'),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                  
                                  // Navigate back to homepage
                                  await Future.delayed(Duration(seconds: 1));
                                  if (context.mounted) {
                                    context.pushNamed(HomepageWidget.routeName);
                                  }
                                }
                              } else if (result.userCancelled) {
                                // User cancelled - no message needed
                                debugPrint('User cancelled purchase');
                              } else {
                                // Error
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(result.error ?? 'Purchase failed. Please try again.'),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              // Close loading dialog
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                              
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              }
                            }
                          },
                          text: FFLocalizations.of(context).getText(
                            '6qgq3qxc' /* Continue */,
                          ),
                          icon: Icon(
                            Icons.arrow_forward,
                            size: 20.0,
                          ),
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 56.0,
                            padding: EdgeInsetsDirectional.fromSTEB(
                                24.0, 16.0, 24.0, 16.0),
                            iconAlignment: IconAlignment.end,
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            iconColor: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            color: Color(0xFF9810FA),
                            textStyle: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                  font: GoogleFonts.interTight(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  fontSize: 18.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .fontStyle,
                                ),
                            elevation: 0.0,
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              FFLocalizations.of(context).getText(
                                'zfpt22au' /* Auto-renewable. Cancel anytime... */,
                              ),
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    fontSize: 14.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FFButtonWidget(
                                  onPressed: () {
                                    print('Button pressed ...');
                                  },
                                  text: FFLocalizations.of(context).getText(
                                    'e6ng97k2' /* User Agreement */,
                                  ),
                                  options: FFButtonOptions(
                                    padding: EdgeInsets.all(8.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color: Colors.transparent,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          fontSize: 14.0,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                          decoration: TextDecoration.underline,
                                        ),
                                    elevation: 0.0,
                                    borderRadius: BorderRadius.circular(0.0),
                                  ),
                                ),
                                FFButtonWidget(
                                  onPressed: () {
                                    print('Button pressed ...');
                                  },
                                  text: FFLocalizations.of(context).getText(
                                    '7anzgjg8' /* Privacy Policy */,
                                  ),
                                  options: FFButtonOptions(
                                    padding: EdgeInsets.all(8.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color: Colors.transparent,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          fontSize: 14.0,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                          decoration: TextDecoration.underline,
                                        ),
                                    elevation: 0.0,
                                    borderRadius: BorderRadius.circular(0.0),
                                  ),
                                ),
                              ].divide(SizedBox(width: 20.0)),
                            ),
                          ].divide(SizedBox(height: 12.0)),
                        ),
                      ].divide(SizedBox(height: 20.0)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
