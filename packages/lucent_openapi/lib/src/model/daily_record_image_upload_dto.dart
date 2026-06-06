//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'daily_record_image_upload_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DailyRecordImageUploadDto {
  /// Returns a new [DailyRecordImageUploadDto] instance.
  DailyRecordImageUploadDto({
    required this.provider,

    required this.bucket,

    required this.objectKey,

    required this.uploadUrl,

    required this.headers,

    required this.publicUrl,

    required this.expiresAt,

    required this.maxSizeBytes,
  });

  @JsonKey(name: r'provider', required: true, includeIfNull: false)
  final String provider;

  @JsonKey(name: r'bucket', required: true, includeIfNull: false)
  final String bucket;

  @JsonKey(name: r'objectKey', required: true, includeIfNull: false)
  final String objectKey;

  /// Signed PUT URL for direct COS upload.
  @JsonKey(name: r'uploadUrl', required: true, includeIfNull: false)
  final String uploadUrl;

  /// Headers that must be sent with the PUT upload.
  @JsonKey(name: r'headers', required: true, includeIfNull: false)
  final Object headers;

  /// Optional public/CDN URL when TENCENT_COS_PUBLIC_BASE_URL is configured.
  @JsonKey(name: r'publicUrl', required: true, includeIfNull: false)
  final Object publicUrl;

  /// Signed URL expiry timestamp (ISO 8601).
  @JsonKey(name: r'expiresAt', required: true, includeIfNull: false)
  final String expiresAt;

  /// Maximum accepted upload size in bytes.
  @JsonKey(name: r'maxSizeBytes', required: true, includeIfNull: false)
  final num maxSizeBytes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRecordImageUploadDto &&
          other.provider == provider &&
          other.bucket == bucket &&
          other.objectKey == objectKey &&
          other.uploadUrl == uploadUrl &&
          other.headers == headers &&
          other.publicUrl == publicUrl &&
          other.expiresAt == expiresAt &&
          other.maxSizeBytes == maxSizeBytes;

  @override
  int get hashCode =>
      provider.hashCode +
      bucket.hashCode +
      objectKey.hashCode +
      uploadUrl.hashCode +
      headers.hashCode +
      publicUrl.hashCode +
      expiresAt.hashCode +
      maxSizeBytes.hashCode;

  factory DailyRecordImageUploadDto.fromJson(Map<String, dynamic> json) =>
      _$DailyRecordImageUploadDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DailyRecordImageUploadDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
