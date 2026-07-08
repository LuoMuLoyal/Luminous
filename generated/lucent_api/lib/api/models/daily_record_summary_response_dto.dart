// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'daily_record_summary_data_dto.dart';

part 'daily_record_summary_response_dto.g.dart';

@JsonSerializable()
class DailyRecordSummaryResponseDto {
  const DailyRecordSummaryResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory DailyRecordSummaryResponseDto.fromJson(Map<String, Object?> json) =>
      _$DailyRecordSummaryResponseDtoFromJson(json);

  final num code;
  final String message;
  final DailyRecordSummaryDataDto data;

  Map<String, Object?> toJson() => _$DailyRecordSummaryResponseDtoToJson(this);
}
