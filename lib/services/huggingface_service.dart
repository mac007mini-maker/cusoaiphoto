import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

class HuggingfaceService {
  // API base URL from environment variable or fallback to Railway production domain
  // Railway domain: web-production-a7698.up.railway.app (STABLE - never changes!)
  static const String _defaultApiDomain = 'web-production-a7698.up.railway.app';
  static const String _apiDomain = String.fromEnvironment('API_DOMAIN', defaultValue: _defaultApiDomain);
  
  static String get baseUrl {
    if (kIsWeb) {
      final origin = Uri.base.origin;
      return '$origin/api/huggingface';
    } else {
      // For mobile/desktop: Use configurable API domain
      // Build with: flutter build apk --dart-define=API_DOMAIN=your-railway-domain.up.railway.app
      return 'https://$_apiDomain/api/huggingface';
    }
  }
  
  static String get aiBaseUrl {
    if (kIsWeb) {
      final origin = Uri.base.origin;
      return '$origin/api/ai';
    } else {
      // For mobile/desktop: Use configurable API domain
      // Build with: flutter build apk --dart-define=API_DOMAIN=your-railway-domain.up.railway.app
      return 'https://$_apiDomain/api/ai';
    }
  }
  
  static String get proxyBaseUrl {
    if (kIsWeb) {
      final origin = Uri.base.origin;
      return '$origin/api';
    } else {
      return 'https://$_apiDomain/api';
    }
  }
  
  static Future<Uint8List> downloadImageViaProxy(String replicateUrl) async {
    try {
      final encodedUrl = Uri.encodeComponent(replicateUrl);
      final proxyUrl = '$proxyBaseUrl/proxy-image?url=$encodedUrl';
      
      debugPrint('🔗 Proxy URL: $proxyUrl');
      debugPrint('⬇️ Downloading via proxy: ${replicateUrl.substring(0, 80)}...');
      
      final response = await http.get(
        Uri.parse(proxyUrl),
      ).timeout(const Duration(seconds: 120));
      
      if (response.statusCode != 200) {
        debugPrint('❌ Proxy failed: HTTP ${response.statusCode}');
        throw Exception('Proxy download failed: HTTP ${response.statusCode}');
      }
      
      debugPrint('✅ Downloaded ${response.bodyBytes.length} bytes via proxy');
      return response.bodyBytes;
    } catch (e) {
      debugPrint('❌ Proxy error: $e');
      throw Exception('Failed to download image via proxy: $e');
    }
  }

  static Future<String> generateText({
    required String prompt,
    String model = 'mistralai/Mistral-7B-Instruct-v0.2',
    int maxTokens = 250,
    double temperature = 0.7,
    double topP = 0.9,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/text-generation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'prompt': prompt,
          'model': model,
          'max_tokens': maxTokens,
          'temperature': temperature,
          'top_p': topP,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['result'] is List) {
          return data['result'][0]['generated_text'] ?? '';
        }
        return data['result'].toString();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception('Failed to generate text: $e');
    }
  }

  static Future<String> generateImage({
    required String prompt,
    String model = 'stabilityai/stable-diffusion-2',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/text-to-image'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'prompt': prompt,
          'model': model,
        }),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['image'];
        }
        throw Exception('Image generation failed');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception('Failed to generate image: $e');
    }
  }

  static Future<String> faceSwap({
    required Uint8List targetImageBytes,
    required Uint8List sourceFaceBytes,
  }) async {
    try {
      // Convert images to base64 with MIME type detection
      String targetMimeType = 'image/jpeg';
      String sourceMimeType = 'image/jpeg';
      
      // Detect target image MIME type
      if (targetImageBytes.length >= 4) {
        if (targetImageBytes[0] == 0x89 && targetImageBytes[1] == 0x50) {
          targetMimeType = 'image/png';
        } else if (targetImageBytes[0] == 0xFF && targetImageBytes[1] == 0xD8) {
          targetMimeType = 'image/jpeg';
        } else if (targetImageBytes[0] == 0x47 && targetImageBytes[1] == 0x49) {
          targetMimeType = 'image/gif';
        }
      }
      
      // Detect source image MIME type
      if (sourceFaceBytes.length >= 4) {
        if (sourceFaceBytes[0] == 0x89 && sourceFaceBytes[1] == 0x50) {
          sourceMimeType = 'image/png';
        } else if (sourceFaceBytes[0] == 0xFF && sourceFaceBytes[1] == 0xD8) {
          sourceMimeType = 'image/jpeg';
        } else if (sourceFaceBytes[0] == 0x47 && sourceFaceBytes[1] == 0x49) {
          sourceMimeType = 'image/gif';
        }
      }
      
      final targetBase64 = 'data:$targetMimeType;base64,${base64Encode(targetImageBytes)}';
      final sourceBase64 = 'data:$sourceMimeType;base64,${base64Encode(sourceFaceBytes)}';
      
      final response = await http.post(
        Uri.parse('$aiBaseUrl/face-swap'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'target_image': targetBase64,
          'source_face': sourceBase64,
        }),
      ).timeout(const Duration(seconds: 120));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final resultUrl = data['url'];
          if (resultUrl == null || resultUrl.toString().isEmpty) {
            throw Exception('Empty URL from face swap API');
          }
          return resultUrl.toString();
        }
        throw Exception(data['error'] ?? 'Face swap failed');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception('Failed to swap faces: $e');
    }
  }

  static Future<String> fixOldPhoto({
    required Uint8List imageBytes,
    String version = 'v1.3',
  }) async {
    try {
      final base64Image = base64Encode(imageBytes);
      
      String mimeType = 'image/jpeg';
      if (imageBytes.length >= 4) {
        if (imageBytes[0] == 0x89 && imageBytes[1] == 0x50 && imageBytes[2] == 0x4E && imageBytes[3] == 0x47) {
          mimeType = 'image/png';
        } else if (imageBytes[0] == 0xFF && imageBytes[1] == 0xD8) {
          mimeType = 'image/jpeg';
        } else if (imageBytes[0] == 0x47 && imageBytes[1] == 0x49 && imageBytes[2] == 0x46) {
          mimeType = 'image/gif';
        } else if (imageBytes[0] == 0x52 && imageBytes[1] == 0x49 && imageBytes[2] == 0x46 && imageBytes[3] == 0x46) {
          mimeType = 'image/webp';
        }
      }
      
      final response = await http.post(
        Uri.parse('$aiBaseUrl/fix-old-photo'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'image': 'data:$mimeType;base64,$base64Image',
          'version': version,
        }),
      ).timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final resultUrl = data['url'];
          if (resultUrl == null || resultUrl.toString().isEmpty) {
            throw Exception('Empty URL from fix old photo API');
          }
          return resultUrl.toString();
        }
        throw Exception(data['error'] ?? 'Photo restoration failed');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception('Failed to restore photo: $e');
    }
  }

  static Future<String> hdImage({
    required Uint8List imageBytes,
    int scale = 4,
  }) async {
    try {
      final base64Image = base64Encode(imageBytes);
      
      String mimeType = 'image/jpeg';
      if (imageBytes.length >= 4) {
        if (imageBytes[0] == 0x89 && imageBytes[1] == 0x50 && imageBytes[2] == 0x4E && imageBytes[3] == 0x47) {
          mimeType = 'image/png';
        } else if (imageBytes[0] == 0xFF && imageBytes[1] == 0xD8) {
          mimeType = 'image/jpeg';
        } else if (imageBytes[0] == 0x47 && imageBytes[1] == 0x49 && imageBytes[2] == 0x46) {
          mimeType = 'image/gif';
        } else if (imageBytes[0] == 0x52 && imageBytes[1] == 0x49 && imageBytes[2] == 0x46 && imageBytes[3] == 0x46) {
          mimeType = 'image/webp';
        }
      }
      
      final response = await http.post(
        Uri.parse('$aiBaseUrl/hd-image'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'image': 'data:$mimeType;base64,$base64Image',
          'scale': scale,
        }),
      ).timeout(const Duration(seconds: 180));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final resultUrl = data['url'];
          if (resultUrl == null || resultUrl.toString().isEmpty) {
            throw Exception('Empty URL from HD image API');
          }
          return resultUrl.toString();
        }
        throw Exception(data['error'] ?? 'HD enhancement failed');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception('Failed to enhance image: $e');
    }
  }

  static Future<String> cartoonify({
    required Uint8List imageBytes,
    String style = 'cartoon',
    double styleDegree = 0.5,
  }) async {
    try {
      final base64Image = base64Encode(imageBytes);
      
      String mimeType = 'image/jpeg';
      if (imageBytes.length >= 4) {
        if (imageBytes[0] == 0x89 && imageBytes[1] == 0x50 && imageBytes[2] == 0x4E && imageBytes[3] == 0x47) {
          mimeType = 'image/png';
        } else if (imageBytes[0] == 0xFF && imageBytes[1] == 0xD8) {
          mimeType = 'image/jpeg';
        } else if (imageBytes[0] == 0x47 && imageBytes[1] == 0x49 && imageBytes[2] == 0x46) {
          mimeType = 'image/gif';
        } else if (imageBytes[0] == 0x52 && imageBytes[1] == 0x49 && imageBytes[2] == 0x46 && imageBytes[3] == 0x46) {
          mimeType = 'image/webp';
        }
      }
      
      final response = await http.post(
        Uri.parse('$aiBaseUrl/cartoonify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'image': 'data:$mimeType;base64,$base64Image',
          'style': style,
          'style_degree': styleDegree,
        }),
      ).timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final resultUrl = data['url'];
          if (resultUrl == null || resultUrl.toString().isEmpty) {
            throw Exception('Empty URL from cartoonify API');
          }
          return resultUrl.toString();
        }
        throw Exception(data['error'] ?? 'Cartoonify failed');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception('Failed to cartoonify image: $e');
    }
  }
}
