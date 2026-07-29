import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// Content types accepted for daily-record image attachments.
const allowedImageContentTypes = <String>{
  'image/jpeg',
  'image/png',
  'image/webp',
  'image/gif',
};

/// A picked-and-compressed image awaiting upload.
class PendingDailyRecordImage {
  const PendingDailyRecordImage({
    required this.bytes,
    required this.fileName,
    required this.contentType,
  });

  final Uint8List bytes;
  final String fileName;
  final String contentType;
}

/// Resolves the MIME content type for an [XFile], falling back to the
/// file extension when the MIME type is missing or unsupported.
String? resolveImageContentType(XFile image) {
  final mimeType = image.mimeType?.trim().toLowerCase();
  if (allowedImageContentTypes.contains(mimeType)) return mimeType;

  final name = image.name.toLowerCase();
  if (name.endsWith('.jpg') || name.endsWith('.jpeg')) return 'image/jpeg';
  if (name.endsWith('.png')) return 'image/png';
  if (name.endsWith('.webp')) return 'image/webp';
  if (name.endsWith('.gif')) return 'image/gif';
  return null;
}
