//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/analysis_refresh_ready_data_analysis_metrics_observed_metric.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'analysis_refresh_ready_data_analysis_metrics.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AnalysisRefreshReadyDataAnalysisMetrics {
  /// Returns a new [AnalysisRefreshReadyDataAnalysisMetrics] instance.
  AnalysisRefreshReadyDataAnalysisMetrics({
    required this.kind,

    required this.observedMetric,
  });

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        AnalysisRefreshReadyDataAnalysisMetricsKindEnum.unknownDefaultOpenApi,
  )
  final AnalysisRefreshReadyDataAnalysisMetricsKindEnum kind;

  @JsonKey(name: r'observedMetric', required: true, includeIfNull: false)
  final AnalysisRefreshReadyDataAnalysisMetricsObservedMetric observedMetric;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisRefreshReadyDataAnalysisMetrics &&
          other.kind == kind &&
          other.observedMetric == observedMetric;

  @override
  int get hashCode => kind.hashCode + observedMetric.hashCode;

  factory AnalysisRefreshReadyDataAnalysisMetrics.fromJson(
    Map<String, dynamic> json,
  ) => _$AnalysisRefreshReadyDataAnalysisMetricsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AnalysisRefreshReadyDataAnalysisMetricsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum AnalysisRefreshReadyDataAnalysisMetricsKindEnum {
  @JsonValue(r'medication')
  medication(r'medication'),
  @JsonValue(r'water')
  water(r'water'),
  @JsonValue(r'sleep')
  sleep(r'sleep'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const AnalysisRefreshReadyDataAnalysisMetricsKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
