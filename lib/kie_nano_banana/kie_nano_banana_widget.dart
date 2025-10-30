import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/services/kie_nano_banana_service.dart';
import 'kie_nano_banana_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

export 'kie_nano_banana_model.dart';

class KieNanoBananaWidget extends StatefulWidget {
  const KieNanoBananaWidget({super.key});

  static String routeName = 'kie_nano_banana';
  static String routePath = '/kie-nano-banana';

  @override
  State<KieNanoBananaWidget> createState() => _KieNanoBananaWidgetState();
}

class _KieNanoBananaWidgetState extends State<KieNanoBananaWidget> {
  late KieNanoBananaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final List<String> _samplePrompts = const [
    'Portrait of a confident entrepreneur in neon cyberpunk lighting, ultra realistic, 4k',
    'Minimalist skincare banner with soft gradients, white background, floating product bottle, high fashion',
    'Anime style couple enjoying a sunset beach, pastel palette, cinematic lighting, detailed clouds',
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => KieNanoBananaModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _applySamplePrompt(String prompt) async {
    _model.promptController?.text = prompt;
    await _generateImage(prompt: prompt);
  }

  Future<void> _generateImage({String? prompt}) async {
    final text = prompt ?? _model.promptController?.text.trim() ?? '';

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a creative prompt first.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _model.setProcessing(true);
      _model.resetResult();
    });

    final result = await KieNanoBananaService.generateImage(prompt: text);

    if (!mounted) return;

    if (!result.success) {
      setState(() {
        _model.setProcessing(false);
        _model.setError(result.message ?? 'Nano Banana API returned an error.');
      });
      return;
    }

    Uint8List? imageBytes = result.imageBytes;
    String? dataUri = result.imageDataUri;
    String? imageUrl = result.imageUrl;

    if (imageBytes == null && result.imageBase64 != null) {
      try {
        imageBytes = base64Decode(result.imageBase64!);
      } catch (_) {
        // ignore invalid base64
      }
    }

    if (imageBytes == null && imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final response = await http
            .get(Uri.parse(imageUrl))
            .timeout(const Duration(seconds: 60));
        if (response.statusCode == 200) {
          imageBytes = response.bodyBytes;
        }
      } catch (e) {
        debugPrint('⚠️ Failed to download image from $imageUrl: $e');
      }
    }

    setState(() {
      _model.setProcessing(false);
      _model.setResult(
        bytes: imageBytes,
        dataUri:
            dataUri ??
            (imageBytes != null
                ? 'data:image/png;base64,${base64Encode(imageBytes)}'
                : null),
        url: imageUrl,
        prompt: text,
      );
      if (imageBytes == null &&
          dataUri == null &&
          (imageUrl?.isEmpty ?? true)) {
        _model.setInfo(
          'The API responded successfully but no image data was returned. Please check your KIE plan or try a different prompt.',
        );
      }
    });
  }

  Future<void> _saveImageToGallery() async {
    final bytes = _model.generatedImageBytes;
    final dataUri = _model.generatedImageDataUri;

    if (bytes == null && dataUri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Generate an image first before saving.')),
      );
      return;
    }

    try {
      Uint8List? imageBytes = bytes;
      if (imageBytes == null && dataUri != null) {
        final base64Part = dataUri.split(',').last;
        imageBytes = base64Decode(base64Part);
      }

      if (imageBytes != null) {
        await Gal.putImageBytes(imageBytes);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to gallery successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to decode image data for saving.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _copyPromptToClipboard() async {
    final prompt = _model.lastPrompt ?? _model.promptController?.text ?? '';
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Nothing to copy yet.')));
      return;
    }

    await Clipboard.setData(ClipboardData(text: prompt));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Prompt copied to clipboard!')));
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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: false,
          elevation: 0.0,
          leading: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 0.0, 0.0),
            child: FlutterFlowIconButton(
              borderRadius: 24.0,
              buttonSize: 44.0,
              icon: Icon(
                Icons.arrow_back,
                color: FlutterFlowTheme.of(context).primaryText,
                size: 24.0,
              ),
              onPressed: () async {
                context.pop();
              },
            ),
          ),
          title: Text(
            'Nano Banana Studio',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              font: GoogleFonts.interTight(
                fontWeight: FontWeight.bold,
                fontStyle: FlutterFlowTheme.of(
                  context,
                ).headlineMedium.fontStyle,
              ),
              color: FlutterFlowTheme.of(context).primaryText,
              letterSpacing: 0.0,
              fontWeight: FontWeight.bold,
              fontStyle: FlutterFlowTheme.of(context).headlineMedium.fontStyle,
            ),
          ),
          actions: [
            IconButton(
              onPressed: _copyPromptToClipboard,
              icon: Icon(Icons.copy_all_rounded),
              color: FlutterFlowTheme.of(context).primary,
              tooltip: 'Copy prompt',
            ),
            SizedBox(width: 8.0),
          ],
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            padding: EdgeInsetsDirectional.fromSTEB(20.0, 12.0, 20.0, 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Craft brand-new AI templates in seconds',
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                    font: GoogleFonts.interTight(
                      fontWeight: FontWeight.bold,
                      fontStyle: FlutterFlowTheme.of(
                        context,
                      ).titleLarge.fontStyle,
                    ),
                    color: FlutterFlowTheme.of(context).primaryText,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.bold,
                    fontStyle: FlutterFlowTheme.of(
                      context,
                    ).titleLarge.fontStyle,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Powered by KIE Nano Banana diffusion model through our secure proxy. Ideal for marketing creatives, storyboards, and experimental art.',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.normal,
                      fontStyle: FlutterFlowTheme.of(
                        context,
                      ).bodyMedium.fontStyle,
                    ),
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.normal,
                    fontStyle: FlutterFlowTheme.of(
                      context,
                    ).bodyMedium.fontStyle,
                  ),
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _model.promptController,
                  focusNode: _model.promptFocusNode,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Enter your image prompt',
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context).alternate,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context).primary,
                        width: 2.0,
                      ),
                    ),
                  ),
                  style: FlutterFlowTheme.of(context).bodyLarge.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontStyle: FlutterFlowTheme.of(
                        context,
                      ).bodyLarge.fontStyle,
                    ),
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w500,
                    fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                  ),
                  textInputAction: TextInputAction.newline,
                ),
                SizedBox(height: 12.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _samplePrompts
                      .map(
                        (prompt) => InkWell(
                          onTap: () => _applySamplePrompt(prompt),
                          borderRadius: BorderRadius.circular(999.0),
                          child: Container(
                            padding: EdgeInsetsDirectional.fromSTEB(
                              12.0,
                              8.0,
                              12.0,
                              8.0,
                            ),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(
                                context,
                              ).secondaryBackground,
                              borderRadius: BorderRadius.circular(999.0),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                            ),
                            child: Text(
                              prompt,
                              style: FlutterFlowTheme.of(context).bodySmall
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FlutterFlowTheme.of(
                                        context,
                                      ).bodySmall.fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(
                                      context,
                                    ).bodySmall.fontStyle,
                                  ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                SizedBox(height: 20.0),
                FFButtonWidget(
                  onPressed: _model.isProcessing
                      ? null
                      : () async {
                          await _generateImage();
                        },
                  text: _model.isProcessing
                      ? 'Generating...'
                      : 'Generate Image',
                  icon: Icon(Icons.auto_awesome, size: 18.0),
                  options: FFButtonOptions(
                    height: 48.0,
                    padding: EdgeInsetsDirectional.fromSTEB(
                      24.0,
                      0.0,
                      24.0,
                      0.0,
                    ),
                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                    ),
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                      font: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontStyle: FlutterFlowTheme.of(
                          context,
                        ).titleSmall.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.bold,
                      fontStyle: FlutterFlowTheme.of(
                        context,
                      ).titleSmall.fontStyle,
                    ),
                    elevation: 0.0,
                    borderRadius: BorderRadius.circular(16.0),
                    disabledColor: FlutterFlowTheme.of(context).alternate,
                    disabledTextColor: FlutterFlowTheme.of(
                      context,
                    ).secondaryText,
                  ),
                ),
                SizedBox(height: 24.0),
                if (_model.isProcessing)
                  Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12.0),
                        Text('Kicking off KIE Nano Banana render...'),
                      ],
                    ),
                  ),
                if (_model.errorMessage != null)
                  Container(
                    width: double.infinity,
                    margin: EdgeInsetsDirectional.only(bottom: 16.0),
                    padding: EdgeInsetsDirectional.fromSTEB(
                      16.0,
                      12.0,
                      16.0,
                      12.0,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFEFEA),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: Color(0xFFF04438)),
                    ),
                    child: Text(
                      _model.errorMessage!,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          fontStyle: FlutterFlowTheme.of(
                            context,
                          ).bodyMedium.fontStyle,
                        ),
                        color: Color(0xFFB42318),
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
                        fontStyle: FlutterFlowTheme.of(
                          context,
                        ).bodyMedium.fontStyle,
                      ),
                    ),
                  ),
                if (_model.infoMessage != null)
                  Container(
                    width: double.infinity,
                    margin: EdgeInsetsDirectional.only(bottom: 16.0),
                    padding: EdgeInsetsDirectional.fromSTEB(
                      16.0,
                      12.0,
                      16.0,
                      12.0,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFFEFF8FF),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: Color(0xFF84CAFF)),
                    ),
                    child: Text(
                      _model.infoMessage!,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          fontStyle: FlutterFlowTheme.of(
                            context,
                          ).bodyMedium.fontStyle,
                        ),
                        color: Color(0xFF175CD3),
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
                        fontStyle: FlutterFlowTheme.of(
                          context,
                        ).bodyMedium.fontStyle,
                      ),
                    ),
                  ),
                if (_model.generatedImageBytes != null ||
                    (_model.generatedImageDataUri != null &&
                        _model.generatedImageDataUri!.isNotEmpty))
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Result Preview',
                        style: FlutterFlowTheme.of(context).titleMedium
                            .override(
                              font: GoogleFonts.interTight(
                                fontWeight: FontWeight.bold,
                                fontStyle: FlutterFlowTheme.of(
                                  context,
                                ).titleMedium.fontStyle,
                              ),
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                              fontStyle: FlutterFlowTheme.of(
                                context,
                              ).titleMedium.fontStyle,
                            ),
                      ),
                      SizedBox(height: 12.0),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: _model.generatedImageBytes != null
                            ? Image.memory(
                                _model.generatedImageBytes!,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                _model.generatedImageDataUri!,
                                fit: BoxFit.cover,
                              ),
                      ),
                      SizedBox(height: 12.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FFButtonWidget(
                            onPressed: _saveImageToGallery,
                            text: 'Save to gallery',
                            icon: Icon(Icons.download_rounded, size: 18.0),
                            options: FFButtonOptions(
                              height: 44.0,
                              padding: EdgeInsetsDirectional.fromSTEB(
                                20.0,
                                0.0,
                                20.0,
                                0.0,
                              ),
                              color: FlutterFlowTheme.of(context).primary,
                              textStyle: FlutterFlowTheme.of(context).titleSmall
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FlutterFlowTheme.of(
                                        context,
                                      ).titleSmall.fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(
                                      context,
                                    ).secondaryBackground,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(
                                      context,
                                    ).titleSmall.fontStyle,
                                  ),
                              elevation: 0.0,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          if (_model.generatedImageUrl != null &&
                              _model.generatedImageUrl!.isNotEmpty)
                            Expanded(
                              child: Padding(
                                padding: EdgeInsetsDirectional.only(
                                  start: 12.0,
                                ),
                                child: SelectableText(
                                  _model.generatedImageUrl!,
                                  style: FlutterFlowTheme.of(context).bodySmall
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FlutterFlowTheme.of(
                                            context,
                                          ).bodySmall.fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).secondaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FlutterFlowTheme.of(
                                          context,
                                        ).bodySmall.fontStyle,
                                      ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
