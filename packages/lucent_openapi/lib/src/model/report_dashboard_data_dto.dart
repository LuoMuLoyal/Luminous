//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/report_finding_dto.dart';
import 'package:lucent_openapi/src/model/report_pattern_dto.dart';
import 'package:lucent_openapi/src/model/report_trend_dto.dart';
import 'package:lucent_openapi/src/model/report_metric_dto.dart';
import 'package:lucent_openapi/src/model/report_dashboard_score_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_dashboard_data_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportDashboardDataDto {
  /// Returns a new [ReportDashboardDataDto] instance.
  ReportDashboardDataDto({
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

  @JsonKey(
    name: r'range',
    required: true,
    includeIfNull: false,
    unknownEnumValue: ReportDashboardDataDtoRangeEnum.unknownDefaultOpenApi,
  )
  final ReportDashboardDataDtoRangeEnum range;

  @JsonKey(name: r'startDate', required: true, includeIfNull: false)
  final String startDate;

  @JsonKey(name: r'endDate', required: true, includeIfNull: false)
  final String endDate;

  @JsonKey(name: r'generatedAt', required: true, includeIfNull: false)
  final String generatedAt;

  @JsonKey(name: r'score', required: true, includeIfNull: false)
  final ReportDashboardScoreDto score;

  @JsonKey(name: r'metrics', required: true, includeIfNull: false)
  final List<ReportMetricDto> metrics;

  @JsonKey(name: r'trends', required: true, includeIfNull: false)
  final List<ReportTrendDto> trends;

  @JsonKey(name: r'findings', required: true, includeIfNull: false)
  final List<ReportFindingDto> findings;

  @JsonKey(name: r'patterns', required: true, includeIfNull: false)
  final List<ReportPatternDto> patterns;

  @JsonKey(name: r'aiSummaryEnabled', required: true, includeIfNull: false)
  final bool aiSummaryEnabled;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportDashboardDataDto &&
          other.range == range &&
          other.startDate == startDate &&
          other.endDate == endDate &&
          other.generatedAt == generatedAt &&
          other.score == score &&
          other.metrics == metrics &&
          other.trends == trends &&
          other.findings == findings &&
          other.patterns == patterns &&
          other.aiSummaryEnabled == aiSummaryEnabled;

  @override
  int get hashCode =>
      range.hashCode +
      startDate.hashCode +
      endDate.hashCode +
      generatedAt.hashCode +
      score.hashCode +
      metrics.hashCode +
      trends.hashCode +
      findings.hashCode +
      patterns.hashCode +
      aiSummaryEnabled.hashCode;

  factory ReportDashboardDataDto.fromJson(Map<String, dynamic> json) =>
      _$ReportDashboardDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReportDashboardDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ReportDashboardDataDtoRangeEnum {
  @JsonValue(r'last_7_days')
  last7Days(r'last_7_days'),
  @JsonValue(r'last_30_days')
  last30Days(r'last_30_days'),
  @JsonValue(r'custom')
  custom(r'custom'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ReportDashboardDataDtoRangeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
