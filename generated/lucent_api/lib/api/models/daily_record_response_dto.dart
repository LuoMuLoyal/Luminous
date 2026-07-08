// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'daily_record_item_dto.dart';

part 'daily_record_response_dto.g.dart';

@JsonSerializable()
class DailyRecordResponseDto {
  const DailyRecordResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory DailyRecordResponseDto.fromJson(Map<String, Object?> json) =>
      _$DailyRecordResponseDtoFromJson(json);

  final num code;
  final String message;
  final DailyRecordItemDto data;

  Map<String, Object?> toJson() => _$DailyRecordResponseDtoToJson(this);
}
