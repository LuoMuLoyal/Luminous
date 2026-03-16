import 'package:flutter/services.dart';

class GallerySaver {
  GallerySaver._();

  static const MethodChannel _channel = MethodChannel('com.dev.luminous/gallery');

  /// Saves image bytes to system gallery (Android via MediaStore).
  /// Returns a content Uri string when successful.
  static Future<String?> saveImage(
    Uint8List bytes, {
    String? fileName,
    String mimeType = 'image/jpeg',
  }) async {
    try {
      return await _channel.invokeMethod<String>('saveImage', <String, dynamic>{
        'bytes': bytes,
        'fileName': fileName,
        'mimeType': mimeType,
      });
    } on PlatformException {
      rethrow;
    }
  }
}
