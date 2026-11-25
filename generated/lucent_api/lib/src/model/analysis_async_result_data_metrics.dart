//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/analysis_async_result_data_metrics_observed_metric.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'analysis_async_result_data_metrics.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AnalysisAsyncResultDataMetrics {
  /// Returns a new [AnalysisAsyncResultDataMetrics] instance.
  AnalysisAsyncResultDataMetrics({
    required this.kind,

    required this.observedMetric,
  });

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        AnalysisAsyncResultDataMetricsKindEnum.unknownDefaultOpenApi,
  )
  final AnalysisAsyncResultDataMetricsKindEnum kind;

  @JsonKey(name: r'observedMetric', required: true, includeIfNull: false)
  final AnalysisAsyncResultDataMetricsObservedMetric observedMetric;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisAsyncResultDataMetrics &&
          other.kind == kind &&
          other.observedMetric == observedMetric;

  @override
  int get hashCode => kind.hashCode + observedMetric.hashCode;

  factory AnalysisAsyncResultDataMetrics.fromJson(Map<String, dynamic> json) =>
      _$AnalysisAsyncResultDataMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisAsyncResultDataMetricsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum AnalysisAsyncResultDataMetricsKindEnum {
  @JsonValue(r'medication')
  medication(r'medication'),
  @JsonValue(r'water')
  water(r'water'),
  @JsonValue(r'sleep')
  sleep(r'sleep'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const AnalysisAsyncResultDataMetricsKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
