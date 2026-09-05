//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/report_summary_response_low_risk_action.dart';
import 'package:lucent_api/src/model/report_summary_response_observed_pattern.dart';
import 'package:lucent_api/src/model/report_summary_response_coverage.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_summary_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportSummaryResponse {
  /// Returns a new [ReportSummaryResponse] instance.
  ReportSummaryResponse({
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
    unknownEnumValue: ReportSummaryResponseRangeEnum.unknownDefaultOpenApi,
  )
  final ReportSummaryResponseRangeEnum range;

  @JsonKey(name: r'startDate', required: true, includeIfNull: false)
  final String startDate;

  @JsonKey(name: r'endDate', required: true, includeIfNull: false)
  final String endDate;

  @JsonKey(name: r'generatedAt', required: true, includeIfNull: false)
  final String generatedAt;

  @JsonKey(name: r'summary', required: true, includeIfNull: false)
  final String summary;

  @JsonKey(name: r'coverage', required: true, includeIfNull: false)
  final ReportSummaryResponseCoverage coverage;

  @JsonKey(name: r'observedPattern', required: true, includeIfNull: true)
  final ReportSummaryResponseObservedPattern? observedPattern;

  @JsonKey(name: r'lowRiskAction', required: true, includeIfNull: true)
  final ReportSummaryResponseLowRiskAction? lowRiskAction;

  @JsonKey(name: r'disclaimer', required: true, includeIfNull: false)
  final String disclaimer;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportSummaryResponse &&
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

  factory ReportSummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$ReportSummaryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ReportSummaryResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ReportSummaryResponseRangeEnum {
  @JsonValue(r'last_7_days')
  last7Days(r'last_7_days'),
  @JsonValue(r'last_30_days')
  last30Days(r'last_30_days'),
  @JsonValue(r'custom')
  custom(r'custom'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ReportSummaryResponseRangeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
