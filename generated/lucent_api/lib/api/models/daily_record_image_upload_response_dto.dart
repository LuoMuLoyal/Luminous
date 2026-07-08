// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'daily_record_image_upload_dto.dart';

part 'daily_record_image_upload_response_dto.g.dart';

@JsonSerializable()
class DailyRecordImageUploadResponseDto {
  const DailyRecordImageUploadResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory DailyRecordImageUploadResponseDto.fromJson(
    Map<String, Object?> json,
  ) => _$DailyRecordImageUploadResponseDtoFromJson(json);

  final num code;
  final String message;
  final DailyRecordImageUploadDto data;

  Map<String, Object?> toJson() =>
      _$DailyRecordImageUploadResponseDtoToJson(this);
}
