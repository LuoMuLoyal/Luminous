//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/report_dashboard_response_patterns.dart';
import 'package:lucent_api/src/model/report_dashboard_response_findings.dart';
import 'package:lucent_api/src/model/report_dashboard_response_trends.dart';
import 'package:lucent_api/src/model/report_dashboard_response_metrics.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_dashboard_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportDashboardResponse {
  /// Returns a new [ReportDashboardResponse] instance.
  ReportDashboardResponse({
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
    unknownEnumValue: ReportDashboardResponseRangeEnum.unknownDefaultOpenApi,
  )
  final ReportDashboardResponseRangeEnum range;

  @JsonKey(name: r'startDate', required: true, includeIfNull: false)
  final String startDate;

  @JsonKey(name: r'endDate', required: true, includeIfNull: false)
  final String endDate;

  @JsonKey(name: r'generatedAt', required: true, includeIfNull: false)
  final String generatedAt;

  @JsonKey(name: r'metrics', required: true, includeIfNull: false)
  final List<ReportDashboardResponseMetrics> metrics;

  @JsonKey(name: r'trends', required: true, includeIfNull: false)
  final List<ReportDashboardResponseTrends> trends;

  @JsonKey(name: r'findings', required: true, includeIfNull: false)
  final List<ReportDashboardResponseFindings> findings;

  @JsonKey(name: r'patterns', required: true, includeIfNull: false)
  final List<ReportDashboardResponsePatterns> patterns;

  @JsonKey(name: r'aiSummaryEnabled', required: true, includeIfNull: false)
  final bool aiSummaryEnabled;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportDashboardResponse &&
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

  factory ReportDashboardResponse.fromJson(Map<String, dynamic> json) =>
      _$ReportDashboardResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ReportDashboardResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ReportDashboardResponseRangeEnum {
  @JsonValue(r'last_7_days')
  last7Days(r'last_7_days'),
  @JsonValue(r'last_30_days')
  last30Days(r'last_30_days'),
  @JsonValue(r'custom')
  custom(r'custom'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ReportDashboardResponseRangeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
