// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'create_daily_record_image_upload_dto.g.dart';

@JsonSerializable()
class CreateDailyRecordImageUploadDto {
  const CreateDailyRecordImageUploadDto({
    required this.contentType,
    required this.sizeBytes,
    this.fileName,
  });

  factory CreateDailyRecordImageUploadDto.fromJson(Map<String, Object?> json) =>
      _$CreateDailyRecordImageUploadDtoFromJson(json);

  /// Image MIME content type.
  final String contentType;

  /// File size in bytes.
  final num sizeBytes;

  /// Original file name.
  final String? fileName;

  Map<String, Object?> toJson() =>
      _$CreateDailyRecordImageUploadDtoToJson(this);
}
