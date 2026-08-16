//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/daily_record_attachment_kind.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'daily_record_attachment_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DailyRecordAttachmentDto {
  /// Returns a new [DailyRecordAttachmentDto] instance.
  DailyRecordAttachmentDto({
    required this.id,

    required this.kind,

    required this.objectKey,

    this.bucket,

    this.provider,

    this.fileName,

    this.contentType,

    this.sizeBytes,

    this.width,

    this.height,

    this.publicUrl,

    required this.createdAt,
  });

  /// Attachment id.
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue: DailyRecordAttachmentKind.unknownDefaultOpenApi,
  )
  final DailyRecordAttachmentKind kind;

  /// Object storage key.
  @JsonKey(name: r'objectKey', required: true, includeIfNull: false)
  final String objectKey;

  /// Object storage bucket.
  @JsonKey(name: r'bucket', required: false, includeIfNull: false)
  final String? bucket;

  /// Storage provider.
  @JsonKey(name: r'provider', required: false, includeIfNull: false)
  final String? provider;

  /// Original file name.
  @JsonKey(name: r'fileName', required: false, includeIfNull: false)
  final String? fileName;

  /// MIME content type.
  @JsonKey(name: r'contentType', required: false, includeIfNull: false)
  final String? contentType;

  /// File size in bytes.
  @JsonKey(name: r'sizeBytes', required: false, includeIfNull: false)
  final num? sizeBytes;

  /// Image width in pixels.
  @JsonKey(name: r'width', required: false, includeIfNull: false)
  final num? width;

  /// Image height in pixels.
  @JsonKey(name: r'height', required: false, includeIfNull: false)
  final num? height;

  /// Public or signed display URL.
  @JsonKey(name: r'publicUrl', required: false, includeIfNull: false)
  final String? publicUrl;

  /// Created at (ISO 8601).
  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final String createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRecordAttachmentDto &&
          other.id == id &&
          other.kind == kind &&
          other.objectKey == objectKey &&
          other.bucket == bucket &&
          other.provider == provider &&
          other.fileName == fileName &&
          other.contentType == contentType &&
          other.sizeBytes == sizeBytes &&
          other.width == width &&
          other.height == height &&
          other.publicUrl == publicUrl &&
          other.createdAt == createdAt;

  @override
  int get hashCode =>
      id.hashCode +
      kind.hashCode +
      objectKey.hashCode +
      (bucket == null ? 0 : bucket.hashCode) +
      (provider == null ? 0 : provider.hashCode) +
      (fileName == null ? 0 : fileName.hashCode) +
      (contentType == null ? 0 : contentType.hashCode) +
      (sizeBytes == null ? 0 : sizeBytes.hashCode) +
      (width == null ? 0 : width.hashCode) +
      (height == null ? 0 : height.hashCode) +
      (publicUrl == null ? 0 : publicUrl.hashCode) +
      createdAt.hashCode;

  factory DailyRecordAttachmentDto.fromJson(Map<String, dynamic> json) =>
      _$DailyRecordAttachmentDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DailyRecordAttachmentDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
