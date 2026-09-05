//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/today_analysis_data_metrics_observed_metric.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_analysis_data_metrics.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodayAnalysisDataMetrics {
  /// Returns a new [TodayAnalysisDataMetrics] instance.
  TodayAnalysisDataMetrics({required this.kind, required this.observedMetric});

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue: TodayAnalysisDataMetricsKindEnum.unknownDefaultOpenApi,
  )
  final TodayAnalysisDataMetricsKindEnum kind;

  @JsonKey(name: r'observedMetric', required: true, includeIfNull: false)
  final TodayAnalysisDataMetricsObservedMetric observedMetric;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayAnalysisDataMetrics &&
          other.kind == kind &&
          other.observedMetric == observedMetric;

  @override
  int get hashCode => kind.hashCode + observedMetric.hashCode;

  factory TodayAnalysisDataMetrics.fromJson(Map<String, dynamic> json) =>
      _$TodayAnalysisDataMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$TodayAnalysisDataMetricsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum TodayAnalysisDataMetricsKindEnum {
  @JsonValue(r'medication')
  medication(r'medication'),
  @JsonValue(r'water')
  water(r'water'),
  @JsonValue(r'sleep')
  sleep(r'sleep'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const TodayAnalysisDataMetricsKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
