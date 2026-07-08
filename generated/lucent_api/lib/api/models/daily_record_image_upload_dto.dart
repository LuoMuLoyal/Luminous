// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'daily_record_image_upload_dto.g.dart';

@JsonSerializable()
class DailyRecordImageUploadDto {
  const DailyRecordImageUploadDto({
    required this.provider,
    required this.bucket,
    required this.objectKey,
    required this.uploadUrl,
    required this.headers,
    required this.publicUrl,
    required this.expiresAt,
    required this.maxSizeBytes,
  });

  factory DailyRecordImageUploadDto.fromJson(Map<String, Object?> json) =>
      _$DailyRecordImageUploadDtoFromJson(json);

  final String provider;
  final String bucket;
  final String objectKey;

  /// Signed PUT URL for direct COS upload.
  final String uploadUrl;

  /// Headers that must be sent with the PUT upload.
  final dynamic headers;

  /// Optional public/CDN URL when TENCENT_COS_PUBLIC_BASE_URL is configured.
  final dynamic publicUrl;

  /// Signed URL expiry timestamp (ISO 8601).
  final String expiresAt;

  /// Maximum accepted upload size in bytes.
  final num maxSizeBytes;

  Map<String, Object?> toJson() => _$DailyRecordImageUploadDtoToJson(this);
}
