import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:luminous/core/logger/log_level.dart';

/// Image compression utility for upload scenarios.
///
/// Reduces image dimensions and quality before network upload to save
/// bandwidth and storage. All outputs are JPEG regardless of input format.
class ImageCompressor {
  const ImageCompressor._();

  /// Compresses image bytes for daily-record attachment uploads.
  ///
  /// - Resizes to max 1280 px on the longest side (maintains aspect ratio).
  /// - JPEG quality 85 %.
  /// - Falls back to original bytes on any failure (including Web, where
  ///   the platform plugin may be unavailable).
  static Future<Uint8List> compressForUpload(
    Uint8List bytes, {
    int maxWidth = 1280,
    int maxHeight = 1280,
    int quality = 85,
  }) async {
    return _compress(
      bytes,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      quality: quality,
    );
  }

  /// Compresses image bytes for AI medicine-recognition uploads.
  ///
  /// Higher resolution than [compressForUpload] to preserve text/detail
  /// for cloud AI models.
  /// - Resizes to max 1920 px on the longest side.
  /// - JPEG quality 90 %.
  static Future<Uint8List> compressForAiRecognition(
    Uint8List bytes, {
    int maxWidth = 1920,
    int maxHeight = 1920,
    int quality = 90,
  }) async {
    return _compress(
      bytes,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      quality: quality,
    );
  }

  static Future<Uint8List> _compress(
    Uint8List bytes, {
    required int maxWidth,
    required int maxHeight,
    required int quality,
  }) async {
    if (kIsWeb) {
      // flutter_image_compress has no stable web backend; return original.
      appTalker.debug('Image compression skipped on Web (no plugin backend)');
      return bytes;
    }

    try {
      final result = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: maxWidth,
        minHeight: maxHeight,
        quality: quality,
        format: CompressFormat.jpeg,
      );
      return result;
    } catch (e, st) {
      // Compression failed — upload original bytes rather than blocking the user.
      appTalker.warning('Image compression failed, using original: $e', e, st);
      return bytes;
    }
  }
}
