//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'daily_record_list_response_items_attachments.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DailyRecordListResponseItemsAttachments {
  /// Returns a new [DailyRecordListResponseItemsAttachments] instance.
  DailyRecordListResponseItemsAttachments({
    required this.id,

    required this.kind,

    required this.objectKey,

    required this.bucket,

    required this.provider,

    required this.fileName,

    required this.contentType,

    required this.sizeBytes,

    required this.width,

    required this.height,

    required this.publicUrl,

    required this.createdAt,
  });

  /// Attachment id.
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        DailyRecordListResponseItemsAttachmentsKindEnum.unknownDefaultOpenApi,
  )
  final DailyRecordListResponseItemsAttachmentsKindEnum kind;

  /// Object storage key.
  @JsonKey(name: r'objectKey', required: true, includeIfNull: false)
  final String objectKey;

  /// Object storage bucket.
  @JsonKey(name: r'bucket', required: true, includeIfNull: true)
  final String? bucket;

  /// Storage provider.
  @JsonKey(name: r'provider', required: true, includeIfNull: true)
  final String? provider;

  /// Original file name.
  @JsonKey(name: r'fileName', required: true, includeIfNull: true)
  final String? fileName;

  /// MIME content type.
  @JsonKey(name: r'contentType', required: true, includeIfNull: true)
  final String? contentType;

  /// File size in bytes.
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'sizeBytes', required: true, includeIfNull: true)
  final int? sizeBytes;

  /// Image width in pixels.
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'width', required: true, includeIfNull: true)
  final int? width;

  /// Image height in pixels.
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'height', required: true, includeIfNull: true)
  final int? height;

  /// Public or signed display URL.
  @JsonKey(name: r'publicUrl', required: true, includeIfNull: true)
  final String? publicUrl;

  /// Created at (ISO 8601).
  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final String createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRecordListResponseItemsAttachments &&
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

  factory DailyRecordListResponseItemsAttachments.fromJson(
    Map<String, dynamic> json,
  ) => _$DailyRecordListResponseItemsAttachmentsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$DailyRecordListResponseItemsAttachmentsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum DailyRecordListResponseItemsAttachmentsKindEnum {
  @JsonValue(r'image')
  image(r'image'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const DailyRecordListResponseItemsAttachmentsKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
