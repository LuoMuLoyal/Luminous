import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// 在后台把识别图片编码为 base64，避免阻塞主线程。
Future<String> encodeScanImageBase64(Uint8List bytes) {
  return compute(_encodeScanImageBase64, bytes);
}

/// 在后台生成相册缩略图的字节与 base64，避免阻塞主线程。
Future<Map<String, Object>> buildAlbumThumbPayload({
  required Uint8List bytes,
  String preferredThumbBase64 = '',
}) {
  return compute(_buildAlbumThumbPayload, <String, Object>{
    'bytes': bytes,
    'preferredThumbBase64': preferredThumbBase64.trim(),
  });
}

String _encodeScanImageBase64(Uint8List bytes) {
  return base64Encode(bytes);
}

Map<String, Object> _buildAlbumThumbPayload(Map<String, Object> message) {
  final bytes = message['bytes'] as Uint8List;
  final preferredThumbBase64 =
      (message['preferredThumbBase64'] as String?)?.trim() ?? '';
  final thumbBase64 = _resolveThumbBase64(
    bytes: bytes,
    preferredThumbBase64: preferredThumbBase64,
  );

  return <String, Object>{
    'thumbBase64': thumbBase64,
    'thumbBytes': thumbBase64.isEmpty
        ? Uint8List(0)
        : Uint8List.fromList(base64Decode(thumbBase64)),
  };
}

String _resolveThumbBase64({
  required Uint8List bytes,
  required String preferredThumbBase64,
}) {
  if (preferredThumbBase64.isNotEmpty) {
    try {
      base64Decode(preferredThumbBase64);
      return preferredThumbBase64;
    } catch (_) {
      // Fall through to a locally generated thumbnail.
    }
  }
  return _generateThumbBase64(bytes);
}

String _generateThumbBase64(Uint8List bytes) {
  try {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return '';
    }

    final resized = img.copyResize(decoded, width: 240);
    final jpg = img.encodeJpg(resized, quality: 80);
    return base64Encode(jpg);
  } catch (_) {
    return '';
  }
}
