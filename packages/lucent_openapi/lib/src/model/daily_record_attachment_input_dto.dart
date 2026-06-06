//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/daily_record_attachment_kind.dart';
import 'package:json_annotation/json_annotation.dart';

part 'daily_record_attachment_input_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DailyRecordAttachmentInputDto {
  /// Returns a new [DailyRecordAttachmentInputDto] instance.
  DailyRecordAttachmentInputDto({
    this.kind = DailyRecordAttachmentKind.image,

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

  @JsonKey(
    defaultValue: DailyRecordAttachmentKind.image,
    name: r'kind',
    required: false,
    includeIfNull: false,
    unknownEnumValue: DailyRecordAttachmentKind.unknownDefaultOpenApi,
  )
  final DailyRecordAttachmentKind? kind;

  /// Object storage key, stable across signed URL rotations.
  @JsonKey(name: r'objectKey', required: true, includeIfNull: false)
  final String objectKey;

  /// Object storage bucket.
  @JsonKey(name: r'bucket', required: false, includeIfNull: false)
  final Object? bucket;

  /// Storage provider, e.g. s3/oss/cos/r2.
  @JsonKey(name: r'provider', required: false, includeIfNull: false)
  final Object? provider;

  /// Original file name.
  @JsonKey(name: r'fileName', required: false, includeIfNull: false)
  final Object? fileName;

  /// MIME content type.
  @JsonKey(name: r'contentType', required: false, includeIfNull: false)
  final Object? contentType;

  /// File size in bytes.
  @JsonKey(name: r'sizeBytes', required: false, includeIfNull: false)
  final Object? sizeBytes;

  /// Image width in pixels.
  @JsonKey(name: r'width', required: false, includeIfNull: false)
  final Object? width;

  /// Image height in pixels.
  @JsonKey(name: r'height', required: false, includeIfNull: false)
  final Object? height;

  /// Optional public or already-signed display URL.
  @JsonKey(name: r'publicUrl', required: false, includeIfNull: false)
  final Object? publicUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRecordAttachmentInputDto &&
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
      bucket.hashCode +
      provider.hashCode +
      fileName.hashCode +
      contentType.hashCode +
      sizeBytes.hashCode +
      width.hashCode +
      height.hashCode +
      publicUrl.hashCode;

  factory DailyRecordAttachmentInputDto.fromJson(Map<String, dynamic> json) =>
      _$DailyRecordAttachmentInputDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DailyRecordAttachmentInputDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
