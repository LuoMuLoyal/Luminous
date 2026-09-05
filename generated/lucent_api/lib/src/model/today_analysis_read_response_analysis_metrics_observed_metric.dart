//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_analysis_read_response_analysis_metrics_observed_metric.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodayAnalysisReadResponseAnalysisMetricsObservedMetric {
  /// Returns a new [TodayAnalysisReadResponseAnalysisMetricsObservedMetric] instance.
  TodayAnalysisReadResponseAnalysisMetricsObservedMetric({
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

  @JsonKey(
    name: r'state',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        TodayAnalysisReadResponseAnalysisMetricsObservedMetricStateEnum
            .unknownDefaultOpenApi,
  )
  final TodayAnalysisReadResponseAnalysisMetricsObservedMetricStateEnum state;

  @JsonKey(
    name: r'coverage',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        TodayAnalysisReadResponseAnalysisMetricsObservedMetricCoverageEnum
            .unknownDefaultOpenApi,
  )
  final TodayAnalysisReadResponseAnalysisMetricsObservedMetricCoverageEnum
  coverage;

  @JsonKey(name: r'sources', required: true, includeIfNull: false)
  final List<TodayAnalysisReadResponseAnalysisMetricsObservedMetricSourcesEnum>
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
      other is TodayAnalysisReadResponseAnalysisMetricsObservedMetric &&
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

  factory TodayAnalysisReadResponseAnalysisMetricsObservedMetric.fromJson(
    Map<String, dynamic> json,
  ) => _$TodayAnalysisReadResponseAnalysisMetricsObservedMetricFromJson(json);

  Map<String, dynamic> toJson() =>
      _$TodayAnalysisReadResponseAnalysisMetricsObservedMetricToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum TodayAnalysisReadResponseAnalysisMetricsObservedMetricStateEnum {
  @JsonValue(r'observed')
  observed(r'observed'),
  @JsonValue(r'unknown')
  unknown(r'unknown'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const TodayAnalysisReadResponseAnalysisMetricsObservedMetricStateEnum(
    this.value,
  );

  final String value;

  @override
  String toString() => value;
}

enum TodayAnalysisReadResponseAnalysisMetricsObservedMetricCoverageEnum {
  @JsonValue(r'sufficient')
  sufficient(r'sufficient'),
  @JsonValue(r'partial')
  partial(r'partial'),
  @JsonValue(r'none')
  none(r'none'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const TodayAnalysisReadResponseAnalysisMetricsObservedMetricCoverageEnum(
    this.value,
  );

  final String value;

  @override
  String toString() => value;
}

enum TodayAnalysisReadResponseAnalysisMetricsObservedMetricSourcesEnum {
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

  const TodayAnalysisReadResponseAnalysisMetricsObservedMetricSourcesEnum(
    this.value,
  );

  final String value;

  @override
  String toString() => value;
}
