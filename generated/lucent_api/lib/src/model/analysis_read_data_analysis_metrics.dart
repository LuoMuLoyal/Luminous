//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/analysis_read_data_analysis_metrics_observed_metric.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'analysis_read_data_analysis_metrics.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AnalysisReadDataAnalysisMetrics {
  /// Returns a new [AnalysisReadDataAnalysisMetrics] instance.
  AnalysisReadDataAnalysisMetrics({
    required this.kind,

    required this.observedMetric,
  });

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        AnalysisReadDataAnalysisMetricsKindEnum.unknownDefaultOpenApi,
  )
  final AnalysisReadDataAnalysisMetricsKindEnum kind;

  @JsonKey(name: r'observedMetric', required: true, includeIfNull: false)
  final AnalysisReadDataAnalysisMetricsObservedMetric observedMetric;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisReadDataAnalysisMetrics &&
          other.kind == kind &&
          other.observedMetric == observedMetric;

  @override
  int get hashCode => kind.hashCode + observedMetric.hashCode;

  factory AnalysisReadDataAnalysisMetrics.fromJson(Map<String, dynamic> json) =>
      _$AnalysisReadDataAnalysisMetricsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AnalysisReadDataAnalysisMetricsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum AnalysisReadDataAnalysisMetricsKindEnum {
  @JsonValue(r'medication')
  medication(r'medication'),
  @JsonValue(r'water')
  water(r'water'),
  @JsonValue(r'sleep')
  sleep(r'sleep'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const AnalysisReadDataAnalysisMetricsKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
