import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Client for the backend proxy that wraps KIE Nano Banana image prompt API.
class KieNanoBananaService {
  static const String _defaultApiDomain = 'web-production-a7698.up.railway.app';
  static const String _apiDomain = String.fromEnvironment(
    'API_DOMAIN',
    defaultValue: _defaultApiDomain,
  );

  static String get _baseUrl {
    if (kIsWeb) {
      final origin = Uri.base.origin;
      return '$origin/api/kie';
    }
    return 'https://$_apiDomain/api/kie';
  }

  /// Generate image using KIE Nano Banana via backend proxy.
  static Future<KieNanoBananaResult> generateImage({
    required String prompt,
    String? outputFormat,
    String? imageSize,
    int? numImages,
    List<String>? imageUrls,
    Map<String, dynamic>? options,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/nano-banana'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'prompt': prompt,
              if (outputFormat != null) 'output_format': outputFormat,
              if (imageSize != null) 'image_size': imageSize,
              if (numImages != null) 'num_images': numImages,
              if (imageUrls != null && imageUrls.isNotEmpty)
                'image_urls': imageUrls,
              if (options != null) ...options,
            }),
          )
          .timeout(const Duration(seconds: 90));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && (body['success'] == true)) {
        final raw = (body['kie_response'] ?? body) as Map<String, dynamic>;
        return KieNanoBananaResult.fromJson(raw);
      }

      final errorMessage =
          body['error']?.toString() ??
          'KIE Nano Banana request failed (${response.statusCode})';

      return KieNanoBananaResult.failure(errorMessage);
    } catch (e) {
      debugPrint('❌ KIE Nano Banana error: $e');
      return KieNanoBananaResult.failure('Failed to call KIE Nano Banana: $e');
    }
  }
}

class KieNanoBananaResult {
  final bool success;
  final String? imageDataUri;
  final String? imageBase64;
  final String? imageUrl;
  final String? message;
  final Map<String, dynamic>? raw;

  const KieNanoBananaResult({
    required this.success,
    this.imageDataUri,
    this.imageBase64,
    this.imageUrl,
    this.message,
    this.raw,
  });

  factory KieNanoBananaResult.fromJson(Map<String, dynamic> json) {
    String? dataUri;
    String? base64;

    final rawImage = json['image'] ?? json['image_base64'] ?? json['result'];

    if (rawImage == null && json['images'] is List && json['images'].isNotEmpty) {
      final firstImage = json['images'].first;
      if (firstImage is Map<String, dynamic>) {
        if (firstImage['base64'] is String && (firstImage['base64'] as String).isNotEmpty) {
          base64 = firstImage['base64'];
          dataUri = 'data:image/png;base64,$base64';
        }
      }
    }

    if (rawImage is String && rawImage.isNotEmpty) {
      if (rawImage.startsWith('data:')) {
        dataUri = rawImage;
      } else {
        base64 = rawImage;
        dataUri = 'data:image/png;base64,$rawImage';
      }
    }

    String? url = json['image_url'] ?? json['url'] ?? json['result_url'];
    if ((url == null || url.isEmpty) && json['images'] is List && json['images'].isNotEmpty) {
      final firstImage = json['images'].first;
      if (firstImage is Map<String, dynamic> && firstImage['url'] is String) {
        url = firstImage['url'] as String;
      }
    }

    return KieNanoBananaResult(
      success: true,
      imageDataUri: dataUri,
      imageBase64: base64,
      imageUrl: url is String ? url : null,
      message: json['message']?.toString(),
      raw: json,
    );
  }

  factory KieNanoBananaResult.failure(String message) =>
      KieNanoBananaResult(success: false, message: message);

  Uint8List? get imageBytes {
    final dataString = imageDataUri;
    if (dataString == null || dataString.isEmpty) return null;

    final base64Part = dataString.contains(',')
        ? dataString.split(',').last
        : dataString;

    try {
      return base64Decode(base64Part);
    } catch (_) {
      return null;
    }
  }
}
