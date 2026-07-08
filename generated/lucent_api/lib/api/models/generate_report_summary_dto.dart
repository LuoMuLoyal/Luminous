// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'generate_report_summary_dto_range_range.dart';

part 'generate_report_summary_dto.g.dart';

@JsonSerializable()
class GenerateReportSummaryDto {
  const GenerateReportSummaryDto({this.range, this.startDate, this.endDate});

  factory GenerateReportSummaryDto.fromJson(Map<String, Object?> json) =>
      _$GenerateReportSummaryDtoFromJson(json);

  /// Supported report summary aggregation range.
  final GenerateReportSummaryDtoRangeRange? range;

  /// Required when range is "custom". ISO 8601 date string (YYYY-MM-DD).
  final String? startDate;

  /// Required when range is "custom". ISO 8601 date string (YYYY-MM-DD).
  final String? endDate;

  Map<String, Object?> toJson() => _$GenerateReportSummaryDtoToJson(this);
}
