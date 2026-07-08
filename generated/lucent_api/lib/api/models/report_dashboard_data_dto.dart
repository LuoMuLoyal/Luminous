// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'report_dashboard_data_dto_range_range.dart';
import 'report_dashboard_score_dto.dart';
import 'report_finding_dto.dart';
import 'report_metric_dto.dart';
import 'report_pattern_dto.dart';
import 'report_trend_dto.dart';

part 'report_dashboard_data_dto.g.dart';

@JsonSerializable()
class ReportDashboardDataDto {
  const ReportDashboardDataDto({
    required this.range,
    required this.startDate,
    required this.endDate,
    required this.generatedAt,
    required this.score,
    required this.metrics,
    required this.trends,
    required this.findings,
    required this.patterns,
    required this.aiSummaryEnabled,
  });

  factory ReportDashboardDataDto.fromJson(Map<String, Object?> json) =>
      _$ReportDashboardDataDtoFromJson(json);

  final ReportDashboardDataDtoRangeRange range;
  final String startDate;
  final String endDate;
  final String generatedAt;
  final ReportDashboardScoreDto score;
  final List<ReportMetricDto> metrics;
  final List<ReportTrendDto> trends;
  final List<ReportFindingDto> findings;
  final List<ReportPatternDto> patterns;
  final bool aiSummaryEnabled;

  Map<String, Object?> toJson() => _$ReportDashboardDataDtoToJson(this);
}
