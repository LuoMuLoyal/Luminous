// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'report_dashboard_score_dto_status_status.dart';

part 'report_dashboard_score_dto.g.dart';

@JsonSerializable()
class ReportDashboardScoreDto {
  const ReportDashboardScoreDto({
    required this.value,
    required this.maxValue,
    required this.status,
    required this.summary,
  });

  factory ReportDashboardScoreDto.fromJson(Map<String, Object?> json) =>
      _$ReportDashboardScoreDtoFromJson(json);

  final num value;
  final num maxValue;
  final ReportDashboardScoreDtoStatusStatus status;
  final String summary;

  Map<String, Object?> toJson() => _$ReportDashboardScoreDtoToJson(this);
}
