import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'templates_gallery_model.dart';
export 'templates_gallery_model.dart';

class TemplatesGalleryWidget extends StatefulWidget {
  const TemplatesGalleryWidget({super.key});

  static String routeName = 'templates_gallery';
  static String routePath = '/templates_gallery';

  @override
  State<TemplatesGalleryWidget> createState() => _TemplatesGalleryWidgetState();
}

class _TemplatesGalleryWidgetState extends State<TemplatesGalleryWidget> {
  late TemplatesGalleryModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Template categories with icons and routes
  final List<Map<String, dynamic>> templateCategories = [
    {
      'name': 'Travel',
      'icon': Icons.flight,
      'color': Color(0xFF3B82F6),
      'route': TravelWidget.routeName,
    },
    {
      'name': 'Gym',
      'icon': Icons.fitness_center,
      'color': Color(0xFFEF4444),
      'route': GymWidget.routeName,
    },
    {
      'name': 'Selfie',
      'icon': Icons.photo_camera,
      'color': Color(0xFF8B5CF6),
      'route': SelfieWidget.routeName,
    },
    {
      'name': 'Tattoo',
      'icon': Icons.brush,
      'color': Color(0xFF6366F1),
      'route': TattooWidget.routeName,
    },
    {
      'name': 'Wedding',
      'icon': Icons.favorite,
      'color': Color(0xFFEC4899),
      'route': WeddingWidget.routeName,
    },
    {
      'name': 'Sport',
      'icon': Icons.sports_soccer,
      'color': Color(0xFF10B981),
      'route': SportWidget.routeName,
    },
    {
      'name': 'Christmas',
      'icon': Icons.celebration,
      'color': Color(0xFFF43F5E),
      'route': ChristmasWidget.routeName,
    },
    {
      'name': 'New Year',
      'icon': Icons.auto_awesome,
      'color': Color(0xFFFBBF24),
      'route': NewyearWidget.routeName,
    },
    {
      'name': 'Birthday',
      'icon': Icons.cake,
      'color': Color(0xFFF97316),
      'route': BirthdayWidget.routeName,
    },
    {
      'name': 'School',
      'icon': Icons.school,
      'color': Color(0xFF0EA5E9),
      'route': SchoolWidget.routeName,
    },
    {
      'name': 'Fashion Show',
      'icon': Icons.checkroom,
      'color': Color(0xFFA855F7),
      'route': FashionshowWidget.routeName,
    },
    {
      'name': 'Profile',
      'icon': Icons.person,
      'color': Color(0xFF14B8A6),
      'route': ProfileWidget.routeName,
    },
    {
      'name': 'Suits',
      'icon': Icons.business_center,
      'color': Color(0xFF64748B),
      'route': SuitsWidget.routeName,
    },
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TemplatesGalleryModel());
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
        appBar: AppBar(
          backgroundColor: Color(0xFFF9FAFB),
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderRadius: 8.0,
            buttonSize: 40.0,
            icon: Icon(
              Icons.arrow_back,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 24.0,
            ),
            onPressed: () async {
              context.safePop();
            },
          ),
          title: Text(
            'Story of Life Templates',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight: FontWeight.bold,
                  ),
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontSize: 24.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Your Style',
                    style: FlutterFlowTheme.of(context).titleLarge.override(
                          font: GoogleFonts.interTight(
                            fontWeight: FontWeight.bold,
                          ),
                          color: FlutterFlowTheme.of(context).primaryText,
                          fontSize: 20.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Select a template category to create your story',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(),
                          color: FlutterFlowTheme.of(context).secondaryText,
                          fontSize: 14.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                  SizedBox(height: 24.0),
                  GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 1.0,
                    ),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: templateCategories.length,
                    itemBuilder: (context, index) {
                      final category = templateCategories[index];
                      return InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          context.pushNamed(category['route']);
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.0),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 4.0,
                                color: Color(0x1A000000),
                                offset: Offset(0.0, 2.0),
                              )
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 64.0,
                                height: 64.0,
                                decoration: BoxDecoration(
                                  color: category['color'].withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: Icon(
                                  category['icon'],
                                  color: category['color'],
                                  size: 32.0,
                                ),
                              ),
                              SizedBox(height: 12.0),
                              Text(
                                category['name'],
                                textAlign: TextAlign.center,
                                style: FlutterFlowTheme.of(context)
                                    .bodyLarge
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
