// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'daily_record_attachment_kind.dart';

part 'daily_record_attachment_dto.g.dart';

@JsonSerializable()
class DailyRecordAttachmentDto {
  const DailyRecordAttachmentDto({
    required this.id,
    required this.kind,
    required this.objectKey,
    required this.createdAt,
    this.bucket,
    this.provider,
    this.fileName,
    this.contentType,
    this.sizeBytes,
    this.width,
    this.height,
    this.publicUrl,
  });

  factory DailyRecordAttachmentDto.fromJson(Map<String, Object?> json) =>
      _$DailyRecordAttachmentDtoFromJson(json);

  /// Attachment id.
  final String id;
  final DailyRecordAttachmentKind kind;

  /// Object storage key.
  final String objectKey;

  /// Object storage bucket.
  final String? bucket;

  /// Storage provider.
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

  /// Public or signed display URL.
  final String? publicUrl;

  /// Created at (ISO 8601).
  final String createdAt;

  Map<String, Object?> toJson() => _$DailyRecordAttachmentDtoToJson(this);
}
