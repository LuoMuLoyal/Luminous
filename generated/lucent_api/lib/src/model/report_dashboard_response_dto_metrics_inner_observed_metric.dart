//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_dashboard_response_dto_metrics_inner_observed_metric.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportDashboardResponseDtoMetricsInnerObservedMetric {
  /// Returns a new [ReportDashboardResponseDtoMetricsInnerObservedMetric] instance.
  ReportDashboardResponseDtoMetricsInnerObservedMetric({
    required this.value,

    required this.state,

    required this.coverage,

    required this.sources,

    required this.observedCount,

    required this.expectedCount,

    required this.windowStart,

    required this.windowEnd,
  });

  @JsonKey(name: r'value', required: true, includeIfNull: true)
  final num? value;

  /// Whether at least one observation exists. See coverage for the proportion of observed vs expected days.
  @JsonKey(
    name: r'state',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        ReportDashboardResponseDtoMetricsInnerObservedMetricStateEnum
            .unknownDefaultOpenApi,
  )
  final ReportDashboardResponseDtoMetricsInnerObservedMetricStateEnum state;

  @JsonKey(
    name: r'coverage',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        ReportDashboardResponseDtoMetricsInnerObservedMetricCoverageEnum
            .unknownDefaultOpenApi,
  )
  final ReportDashboardResponseDtoMetricsInnerObservedMetricCoverageEnum
  coverage;

  @JsonKey(name: r'sources', required: true, includeIfNull: false)
  final List<ReportDashboardResponseDtoMetricsInnerObservedMetricSourcesEnum>
  sources;

  @JsonKey(name: r'observedCount', required: true, includeIfNull: false)
  final num observedCount;

  @JsonKey(name: r'expectedCount', required: true, includeIfNull: true)
  final num? expectedCount;

  @JsonKey(name: r'windowStart', required: true, includeIfNull: false)
  final String windowStart;

  @JsonKey(name: r'windowEnd', required: true, includeIfNull: false)
  final String windowEnd;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportDashboardResponseDtoMetricsInnerObservedMetric &&
          other.value == value &&
          other.state == state &&
          other.coverage == coverage &&
          other.sources == sources &&
          other.observedCount == observedCount &&
          other.expectedCount == expectedCount &&
          other.windowStart == windowStart &&
          other.windowEnd == windowEnd;

  @override
  int get hashCode =>
      (value == null ? 0 : value.hashCode) +
      state.hashCode +
      coverage.hashCode +
      sources.hashCode +
      observedCount.hashCode +
      (expectedCount == null ? 0 : expectedCount.hashCode) +
      windowStart.hashCode +
      windowEnd.hashCode;

  factory ReportDashboardResponseDtoMetricsInnerObservedMetric.fromJson(
    Map<String, dynamic> json,
  ) => _$ReportDashboardResponseDtoMetricsInnerObservedMetricFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ReportDashboardResponseDtoMetricsInnerObservedMetricToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Whether at least one observation exists. See coverage for the proportion of observed vs expected days.
enum ReportDashboardResponseDtoMetricsInnerObservedMetricStateEnum {
  @JsonValue(r'observed')
  observed(r'observed'),
  @JsonValue(r'unknown')
  unknown(r'unknown'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ReportDashboardResponseDtoMetricsInnerObservedMetricStateEnum(
    this.value,
  );

  final String value;

  @override
  String toString() => value;
}

enum ReportDashboardResponseDtoMetricsInnerObservedMetricCoverageEnum {
  @JsonValue(r'sufficient')
  sufficient(r'sufficient'),
  @JsonValue(r'partial')
  partial(r'partial'),
  @JsonValue(r'none')
  none(r'none'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ReportDashboardResponseDtoMetricsInnerObservedMetricCoverageEnum(
    this.value,
  );

  final String value;

  @override
  String toString() => value;
}

enum ReportDashboardResponseDtoMetricsInnerObservedMetricSourcesEnum {
  @JsonValue(r'manual')
  manual(r'manual'),
  @JsonValue(r'health_platform')
  healthPlatform(r'health_platform'),
  @JsonValue(r'reminder_plan')
  reminderPlan(r'reminder_plan'),
  @JsonValue(r'derived')
  derived(r'derived'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ReportDashboardResponseDtoMetricsInnerObservedMetricSourcesEnum(
    this.value,
  );

  final String value;

  @override
  String toString() => value;
}
