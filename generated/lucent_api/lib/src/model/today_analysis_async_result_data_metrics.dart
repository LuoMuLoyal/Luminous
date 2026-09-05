//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/today_analysis_async_result_data_metrics_observed_metric.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_analysis_async_result_data_metrics.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodayAnalysisAsyncResultDataMetrics {
  /// Returns a new [TodayAnalysisAsyncResultDataMetrics] instance.
  TodayAnalysisAsyncResultDataMetrics({
    required this.kind,

    required this.observedMetric,
  });

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        TodayAnalysisAsyncResultDataMetricsKindEnum.unknownDefaultOpenApi,
  )
  final TodayAnalysisAsyncResultDataMetricsKindEnum kind;

  @JsonKey(name: r'observedMetric', required: true, includeIfNull: false)
  final TodayAnalysisAsyncResultDataMetricsObservedMetric observedMetric;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayAnalysisAsyncResultDataMetrics &&
          other.kind == kind &&
          other.observedMetric == observedMetric;

  @override
  int get hashCode => kind.hashCode + observedMetric.hashCode;

  factory TodayAnalysisAsyncResultDataMetrics.fromJson(
    Map<String, dynamic> json,
  ) => _$TodayAnalysisAsyncResultDataMetricsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$TodayAnalysisAsyncResultDataMetricsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum TodayAnalysisAsyncResultDataMetricsKindEnum {
  @JsonValue(r'medication')
  medication(r'medication'),
  @JsonValue(r'water')
  water(r'water'),
  @JsonValue(r'sleep')
  sleep(r'sleep'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const TodayAnalysisAsyncResultDataMetricsKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
