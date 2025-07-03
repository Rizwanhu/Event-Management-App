import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Fallback image service for when Firebase Storage is not available
class ImageFallbackService {
  static final ImageFallbackService _instance = ImageFallbackService._internal();
  factory ImageFallbackService() => _instance;
  ImageFallbackService._internal();

  /// Convert images to base64 strings for storage in Firestore
  /// (Use only for small images as Firestore has size limits)
  Future<List<String>> convertImagesToBase64(List<XFile> images) async {
    List<String> base64Images = [];
    
    try {
      for (int i = 0; i < images.length; i++) {
        final image = images[i];
        
        // Read image bytes
        final bytes = await image.readAsBytes();
        
        // Convert to base64 (only for small images < 100KB)
        if (bytes.length < 100000) {
          final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
          base64Images.add(base64String);
        } else {
          print('Skipping large image ${i + 1} (${bytes.length} bytes)');
        }
      }
      
      return base64Images;
    } catch (e) {
      print('Error converting images to base64: $e');
      return [];
    }
  }

  /// Check if image upload is likely to work
  static bool canUploadImages() {
    // For now, assume mobile can always upload
    // Web requires CORS configuration
    return !kIsWeb;
  }

  /// Get a placeholder image URL
  static String getPlaceholderImageUrl() {
    return 'https://via.placeholder.com/300x200/CCCCCC/FFFFFF?text=Event+Image';
  }
}

/// Base64 encoding function for web compatibility
String base64Encode(List<int> bytes) {
  const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  int len = bytes.length;
  if (len == 0) {
    return '';
  }
  final List<String> out = <String>[];
  int i = 0;
  int o = 0;
  while (i < len) {
    final int triple = (bytes[i++] << 16) |
        (i < len ? bytes[i++] << 8 : 0) |
        (i < len ? bytes[i++] : 0);

    out.add(chars[(triple >> 18) & 63]);
    out.add(chars[(triple >> 12) & 63]);
    out.add(chars[(triple >> 6) & 63]);
    out.add(chars[triple & 63]);
    o += 4;
  }
  if (len % 3 > 0) {
    for (int j = 0; j < 3 - (len % 3); j++) {
      out[out.length - 1 - j] = '=';
    }
  }
  return out.join();
}
