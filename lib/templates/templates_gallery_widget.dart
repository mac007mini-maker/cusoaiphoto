import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'templates_gallery_model.dart';
export 'templates_gallery_model.dart';

class TemplatesGalleryWidget extends StatefulWidget {
  const TemplatesGalleryWidget({super.key});

  static String routeName = 'templates_gallery';
  static String routePath = '/templates-gallery';

  @override
  State<TemplatesGalleryWidget> createState() => _TemplatesGalleryWidgetState();
}

class _TemplatesGalleryWidgetState extends State<TemplatesGalleryWidget> {
  late TemplatesGalleryModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Map<String, dynamic>> _templates = [
    {
      'title': 'Travel',
      'icon': '✈️',
      'color': Color(0xFF3B82F6),
      'route': TravelWidget.routeName,
    },
    {
      'title': 'Gym',
      'icon': '💪',
      'color': Color(0xFFEF4444),
      'route': GymWidget.routeName,
    },
    {
      'title': 'Selfie',
      'icon': '🤳',
      'color': Color(0xFFEC4899),
      'route': SelfieWidget.routeName,
    },
    {
      'title': 'Tattoo',
      'icon': '🎨',
      'color': Color(0xFF8B5CF6),
      'route': TattooWidget.routeName,
    },
    {
      'title': 'Wedding',
      'icon': '💍',
      'color': Color(0xFFF59E0B),
      'route': WeddingWidget.routeName,
    },
    {
      'title': 'Sport',
      'icon': '⚽',
      'color': Color(0xFF10B981),
      'route': SportWidget.routeName,
    },
    {
      'title': 'Christmas',
      'icon': '🎄',
      'color': Color(0xFFDC2626),
      'route': ChristmasWidget.routeName,
    },
    {
      'title': 'New Year',
      'icon': '🎉',
      'color': Color(0xFFFBBF24),
      'route': NewyearWidget.routeName,
    },
    {
      'title': 'Birthday',
      'icon': '🎂',
      'color': Color(0xFFDB2777),
      'route': BirthdayWidget.routeName,
    },
    {
      'title': 'School',
      'icon': '🎓',
      'color': Color(0xFF0891B2),
      'route': SchoolWidget.routeName,
    },
    {
      'title': 'Fashion Show',
      'icon': '👗',
      'color': Color(0xFFA855F7),
      'route': FashionshowWidget.routeName,
    },
    {
      'title': 'Profile',
      'icon': '👤',
      'color': Color(0xFF6366F1),
      'route': ProfileWidget.routeName,
    },
    {
      'title': 'Suits',
      'icon': '🤵',
      'color': Color(0xFF1F2937),
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
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 48.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF1F2937),
              size: 24.0,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            'Face Swap Templates',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              font: GoogleFonts.interTight(),
              color: Color(0xFF1F2937),
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 1.0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Your Style',
                    style: FlutterFlowTheme.of(context).headlineSmall.override(
                      font: GoogleFonts.interTight(),
                      color: Color(0xFF1F2937),
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Select a template category to start creating amazing AI photos',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(),
                      color: Color(0xFF6B7280),
                      fontSize: 14.0,
                    ),
                  ),
                  SizedBox(height: 24.0),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: _templates.length,
                    itemBuilder: (context, index) {
                      final template = _templates[index];
                      return InkWell(
                        onTap: () {
                          context.pushNamed(template['route']);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 64.0,
                                height: 64.0,
                                decoration: BoxDecoration(
                                  color: template['color'].withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: Center(
                                  child: Text(
                                    template['icon'],
                                    style: TextStyle(fontSize: 32.0),
                                  ),
                                ),
                              ),
                              SizedBox(height: 12.0),
                              Text(
                                template['title'],
                                style: FlutterFlowTheme.of(context)
                                    .bodyLarge
                                    .override(
                                      font: GoogleFonts.inter(),
                                      color: Color(0xFF1F2937),
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 4.0),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  color: template['color'].withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Text(
                                  '5-8 templates',
                                  style: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .override(
                                        font: GoogleFonts.inter(),
                                        color: template['color'],
                                        fontSize: 11.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 100.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
