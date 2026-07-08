// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'daily_record_list_data_dto.dart';

part 'daily_record_list_response_dto.g.dart';

@JsonSerializable()
class DailyRecordListResponseDto {
  const DailyRecordListResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory DailyRecordListResponseDto.fromJson(Map<String, Object?> json) =>
      _$DailyRecordListResponseDtoFromJson(json);

  final num code;
  final String message;
  final DailyRecordListDataDto data;

  Map<String, Object?> toJson() => _$DailyRecordListResponseDtoToJson(this);
}
