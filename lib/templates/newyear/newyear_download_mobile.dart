import 'dart:typed_data';
import 'dart:io';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

/// Mobile implementation of download - saves DIRECTLY to Gallery/Photos
/// Uses `gal` package to ensure images appear immediately in Gallery
Future<void> downloadImage(Uint8List bytes, String filename) async {
  try {
    // Check if gal package has required permissions
    final hasAccess = await Gal.hasAccess();
    
    if (!hasAccess) {
      // Request gallery access permission
      final granted = await Gal.requestAccess();
      if (!granted) {
        throw Exception(
          'Gallery access denied. Please enable photos/gallery permission in Settings to save images.'
        );
      }
    }
    
    // Create temp file (gal requires file path, not bytes directly)
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/$filename');
    await tempFile.writeAsBytes(bytes);
    
    // Save to Gallery/Photos using gal package
    // This automatically triggers MediaScanner and shows in Gallery immediately
    await Gal.putImage(tempFile.path, album: 'VisoAI');
    
    print('✅ Image saved to Gallery/Photos: VisoAI/$filename');
    
    // Clean up temp file
    try {
      await tempFile.delete();
    } catch (e) {
      print('⚠️ Could not delete temp file: $e');
    }
    
  } catch (e) {
    print('❌ Error saving to Gallery: $e');
    
    // Fallback: save to app documents directory (for very old devices)
    try {
      final directory = await getApplicationDocumentsDirectory();
      final visoFolder = Directory('${directory.path}/VisoAI');
      if (!await visoFolder.exists()) {
        await visoFolder.create(recursive: true);
      }
      
      final filePath = '${visoFolder.path}/$filename';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      print('📁 Fallback: Image saved to app folder: $filePath');
      
      throw Exception('Saved to app folder only. Please check Files app.');
    } catch (fallbackError) {
      print('❌ All save methods failed: $fallbackError');
      rethrow;
    }
  }
}
