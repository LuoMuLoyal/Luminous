// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'daily_record_attachment_kind.dart';

part 'daily_record_attachment_input_dto.g.dart';

@JsonSerializable()
class DailyRecordAttachmentInputDto {
  const DailyRecordAttachmentInputDto({
    required this.objectKey,
    this.bucket,
    this.provider,
    this.fileName,
    this.contentType,
    this.sizeBytes,
    this.width,
    this.height,
    this.publicUrl,
    this.kind = DailyRecordAttachmentKind.image,
  });

  factory DailyRecordAttachmentInputDto.fromJson(Map<String, Object?> json) =>
      _$DailyRecordAttachmentInputDtoFromJson(json);

  final DailyRecordAttachmentKind kind;

  /// Object storage key, stable across signed URL rotations.
  final String objectKey;

  /// Object storage bucket.
  final String? bucket;

  /// Storage provider, currently tencent-cos.
  final String? provider;

  /// Original file name.
  final String? fileName;

  /// MIME content type.
  final String? contentType;

  /// File size in bytes.
  final num? sizeBytes;

  /// Image width in pixels.
  final num? width;

  /// Image height in pixels.
  final num? height;

  /// Optional public or already-signed display URL.
  final String? publicUrl;

  Map<String, Object?> toJson() => _$DailyRecordAttachmentInputDtoToJson(this);
}
