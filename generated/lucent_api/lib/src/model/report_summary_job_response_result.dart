//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/report_summary_job_response_result_observed_pattern.dart';
import 'package:lucent_api/src/model/report_summary_job_response_result_coverage.dart';
import 'package:lucent_api/src/model/report_summary_job_response_result_low_risk_action.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_summary_job_response_result.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportSummaryJobResponseResult {
  /// Returns a new [ReportSummaryJobResponseResult] instance.
  ReportSummaryJobResponseResult({
    required this.range,

    required this.startDate,

    required this.endDate,

    required this.generatedAt,

    required this.summary,

    required this.coverage,

    required this.observedPattern,

    required this.lowRiskAction,

    required this.disclaimer,
  });

  @JsonKey(
    name: r'range',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        ReportSummaryJobResponseResultRangeEnum.unknownDefaultOpenApi,
  )
  final ReportSummaryJobResponseResultRangeEnum range;

  @JsonKey(name: r'startDate', required: true, includeIfNull: false)
  final String startDate;

  @JsonKey(name: r'endDate', required: true, includeIfNull: false)
  final String endDate;

  @JsonKey(name: r'generatedAt', required: true, includeIfNull: false)
  final String generatedAt;

  @JsonKey(name: r'summary', required: true, includeIfNull: false)
  final String summary;

  @JsonKey(name: r'coverage', required: true, includeIfNull: false)
  final ReportSummaryJobResponseResultCoverage coverage;

  @JsonKey(name: r'observedPattern', required: true, includeIfNull: true)
  final ReportSummaryJobResponseResultObservedPattern? observedPattern;

  @JsonKey(name: r'lowRiskAction', required: true, includeIfNull: true)
  final ReportSummaryJobResponseResultLowRiskAction? lowRiskAction;

  @JsonKey(name: r'disclaimer', required: true, includeIfNull: false)
  final String disclaimer;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportSummaryJobResponseResult &&
          other.range == range &&
          other.startDate == startDate &&
          other.endDate == endDate &&
          other.generatedAt == generatedAt &&
          other.summary == summary &&
          other.coverage == coverage &&
          other.observedPattern == observedPattern &&
          other.lowRiskAction == lowRiskAction &&
          other.disclaimer == disclaimer;

  @override
  int get hashCode =>
      range.hashCode +
      startDate.hashCode +
      endDate.hashCode +
      generatedAt.hashCode +
      summary.hashCode +
      coverage.hashCode +
      (observedPattern == null ? 0 : observedPattern.hashCode) +
      (lowRiskAction == null ? 0 : lowRiskAction.hashCode) +
      disclaimer.hashCode;

  factory ReportSummaryJobResponseResult.fromJson(Map<String, dynamic> json) =>
      _$ReportSummaryJobResponseResultFromJson(json);

  Map<String, dynamic> toJson() => _$ReportSummaryJobResponseResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ReportSummaryJobResponseResultRangeEnum {
  @JsonValue(r'last_7_days')
  last7Days(r'last_7_days'),
  @JsonValue(r'last_30_days')
  last30Days(r'last_30_days'),
  @JsonValue(r'custom')
  custom(r'custom'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ReportSummaryJobResponseResultRangeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
