//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/report_dashboard_response_dto_patterns_inner.dart';
import 'package:lucent_api/src/model/report_dashboard_response_dto_findings_inner.dart';
import 'package:lucent_api/src/model/report_dashboard_response_dto_metrics_inner.dart';
import 'package:lucent_api/src/model/report_dashboard_response_dto_trends_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_dashboard_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportDashboardResponseDto {
  /// Returns a new [ReportDashboardResponseDto] instance.
  ReportDashboardResponseDto({
    required this.range,

    required this.startDate,

    required this.endDate,

    required this.generatedAt,

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
    unknownEnumValue: ReportDashboardResponseDtoRangeEnum.unknownDefaultOpenApi,
  )
  final ReportDashboardResponseDtoRangeEnum range;

  @JsonKey(name: r'startDate', required: true, includeIfNull: false)
  final String startDate;

  @JsonKey(name: r'endDate', required: true, includeIfNull: false)
  final String endDate;

  @JsonKey(name: r'generatedAt', required: true, includeIfNull: false)
  final String generatedAt;

  @JsonKey(name: r'metrics', required: true, includeIfNull: false)
  final List<ReportDashboardResponseDtoMetricsInner> metrics;

  @JsonKey(name: r'trends', required: true, includeIfNull: false)
  final List<ReportDashboardResponseDtoTrendsInner> trends;

  @JsonKey(name: r'findings', required: true, includeIfNull: false)
  final List<ReportDashboardResponseDtoFindingsInner> findings;

  @JsonKey(name: r'patterns', required: true, includeIfNull: false)
  final List<ReportDashboardResponseDtoPatternsInner> patterns;

  @JsonKey(name: r'aiSummaryEnabled', required: true, includeIfNull: false)
  final bool aiSummaryEnabled;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportDashboardResponseDto &&
          other.range == range &&
          other.startDate == startDate &&
          other.endDate == endDate &&
          other.generatedAt == generatedAt &&
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
      metrics.hashCode +
      trends.hashCode +
      findings.hashCode +
      patterns.hashCode +
      aiSummaryEnabled.hashCode;

  factory ReportDashboardResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ReportDashboardResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReportDashboardResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ReportDashboardResponseDtoRangeEnum {
  @JsonValue(r'last_7_days')
  last7Days(r'last_7_days'),
  @JsonValue(r'last_30_days')
  last30Days(r'last_30_days'),
  @JsonValue(r'custom')
  custom(r'custom'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ReportDashboardResponseDtoRangeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
