// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'daily_record_summary_dto.dart';

part 'daily_record_summary_data_dto.g.dart';

@JsonSerializable()
class DailyRecordSummaryDataDto {
  const DailyRecordSummaryDataDto({required this.summaries});

  factory DailyRecordSummaryDataDto.fromJson(Map<String, Object?> json) =>
      _$DailyRecordSummaryDataDtoFromJson(json);

  final List<DailyRecordSummaryDto> summaries;

  Map<String, Object?> toJson() => _$DailyRecordSummaryDataDtoToJson(this);
}
