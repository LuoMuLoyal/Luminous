//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'daily_record_image_upload_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DailyRecordImageUploadResponse {
  /// Returns a new [DailyRecordImageUploadResponse] instance.
  DailyRecordImageUploadResponse({
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

  /// Signed PUT URL for direct object storage upload.
  @JsonKey(name: r'uploadUrl', required: true, includeIfNull: false)
  final String uploadUrl;

  /// Headers that must be sent with the PUT upload.
  @JsonKey(name: r'headers', required: true, includeIfNull: false)
  final Map<String, String> headers;

  /// Optional public/CDN URL when a public base URL is configured.
  @JsonKey(name: r'publicUrl', required: true, includeIfNull: true)
  final String? publicUrl;

  /// Signed URL expiry timestamp (ISO 8601).
  @JsonKey(name: r'expiresAt', required: true, includeIfNull: false)
  final String expiresAt;

  /// Maximum accepted upload size in bytes.
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'maxSizeBytes', required: true, includeIfNull: false)
  final int maxSizeBytes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRecordImageUploadResponse &&
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
      (publicUrl == null ? 0 : publicUrl.hashCode) +
      expiresAt.hashCode +
      maxSizeBytes.hashCode;

  factory DailyRecordImageUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$DailyRecordImageUploadResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DailyRecordImageUploadResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
