//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_daily_record_request_attachments.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateDailyRecordRequestAttachments {
  /// Returns a new [CreateDailyRecordRequestAttachments] instance.
  CreateDailyRecordRequestAttachments({
    this.kind,

    required this.objectKey,

    this.bucket,

    this.provider,

    this.fileName,

    this.contentType,

    this.sizeBytes,

    this.width,

    this.height,

    this.publicUrl,
  });

  /// Attachment kind. Defaults to \"image\".
  @JsonKey(
    name: r'kind',
    required: false,
    includeIfNull: false,
    unknownEnumValue:
        CreateDailyRecordRequestAttachmentsKindEnum.unknownDefaultOpenApi,
  )
  final CreateDailyRecordRequestAttachmentsKindEnum? kind;

  /// Object storage key, stable across signed URL rotations.
  @JsonKey(name: r'objectKey', required: true, includeIfNull: false)
  final String objectKey;

  /// Object storage bucket.
  @JsonKey(name: r'bucket', required: false, includeIfNull: false)
  final String? bucket;

  /// Storage provider (e.g. tencent-cos, s3).
  @JsonKey(name: r'provider', required: false, includeIfNull: false)
  final String? provider;

  /// Original file name.
  @JsonKey(name: r'fileName', required: false, includeIfNull: false)
  final String? fileName;

  /// MIME content type.
  @JsonKey(name: r'contentType', required: false, includeIfNull: false)
  final String? contentType;

  /// File size in bytes.
  // minimum: 0
  // maximum: 50000000
  @JsonKey(name: r'sizeBytes', required: false, includeIfNull: false)
  final int? sizeBytes;

  /// Image width in pixels.
  // minimum: 0
  // maximum: 100000
  @JsonKey(name: r'width', required: false, includeIfNull: false)
  final int? width;

  /// Image height in pixels.
  // minimum: 0
  // maximum: 100000
  @JsonKey(name: r'height', required: false, includeIfNull: false)
  final int? height;

  /// Optional public or already-signed display URL.
  @JsonKey(name: r'publicUrl', required: false, includeIfNull: false)
  final String? publicUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateDailyRecordRequestAttachments &&
          other.kind == kind &&
          other.objectKey == objectKey &&
          other.bucket == bucket &&
          other.provider == provider &&
          other.fileName == fileName &&
          other.contentType == contentType &&
          other.sizeBytes == sizeBytes &&
          other.width == width &&
          other.height == height &&
          other.publicUrl == publicUrl;

  @override
  int get hashCode =>
      kind.hashCode +
      objectKey.hashCode +
      (bucket == null ? 0 : bucket.hashCode) +
      (provider == null ? 0 : provider.hashCode) +
      (fileName == null ? 0 : fileName.hashCode) +
      (contentType == null ? 0 : contentType.hashCode) +
      (sizeBytes == null ? 0 : sizeBytes.hashCode) +
      (width == null ? 0 : width.hashCode) +
      (height == null ? 0 : height.hashCode) +
      (publicUrl == null ? 0 : publicUrl.hashCode);

  factory CreateDailyRecordRequestAttachments.fromJson(
    Map<String, dynamic> json,
  ) => _$CreateDailyRecordRequestAttachmentsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CreateDailyRecordRequestAttachmentsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Attachment kind. Defaults to \"image\".
enum CreateDailyRecordRequestAttachmentsKindEnum {
  @JsonValue(r'image')
  image(r'image'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const CreateDailyRecordRequestAttachmentsKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
