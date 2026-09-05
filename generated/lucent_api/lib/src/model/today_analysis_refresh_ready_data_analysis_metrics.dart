//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/today_analysis_refresh_ready_data_analysis_metrics_observed_metric.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_analysis_refresh_ready_data_analysis_metrics.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodayAnalysisRefreshReadyDataAnalysisMetrics {
  /// Returns a new [TodayAnalysisRefreshReadyDataAnalysisMetrics] instance.
  TodayAnalysisRefreshReadyDataAnalysisMetrics({
    required this.kind,

    required this.observedMetric,
  });

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue: TodayAnalysisRefreshReadyDataAnalysisMetricsKindEnum
        .unknownDefaultOpenApi,
  )
  final TodayAnalysisRefreshReadyDataAnalysisMetricsKindEnum kind;

  @JsonKey(name: r'observedMetric', required: true, includeIfNull: false)
  final TodayAnalysisRefreshReadyDataAnalysisMetricsObservedMetric
  observedMetric;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayAnalysisRefreshReadyDataAnalysisMetrics &&
          other.kind == kind &&
          other.observedMetric == observedMetric;

  @override
  int get hashCode => kind.hashCode + observedMetric.hashCode;

  factory TodayAnalysisRefreshReadyDataAnalysisMetrics.fromJson(
    Map<String, dynamic> json,
  ) => _$TodayAnalysisRefreshReadyDataAnalysisMetricsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$TodayAnalysisRefreshReadyDataAnalysisMetricsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum TodayAnalysisRefreshReadyDataAnalysisMetricsKindEnum {
  @JsonValue(r'medication')
  medication(r'medication'),
  @JsonValue(r'water')
  water(r'water'),
  @JsonValue(r'sleep')
  sleep(r'sleep'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const TodayAnalysisRefreshReadyDataAnalysisMetricsKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
