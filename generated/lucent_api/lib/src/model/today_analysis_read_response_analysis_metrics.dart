//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/today_analysis_read_response_analysis_metrics_observed_metric.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_analysis_read_response_analysis_metrics.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodayAnalysisReadResponseAnalysisMetrics {
  /// Returns a new [TodayAnalysisReadResponseAnalysisMetrics] instance.
  TodayAnalysisReadResponseAnalysisMetrics({
    required this.kind,

    required this.observedMetric,
  });

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        TodayAnalysisReadResponseAnalysisMetricsKindEnum.unknownDefaultOpenApi,
  )
  final TodayAnalysisReadResponseAnalysisMetricsKindEnum kind;

  @JsonKey(name: r'observedMetric', required: true, includeIfNull: false)
  final TodayAnalysisReadResponseAnalysisMetricsObservedMetric observedMetric;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayAnalysisReadResponseAnalysisMetrics &&
          other.kind == kind &&
          other.observedMetric == observedMetric;

  @override
  int get hashCode => kind.hashCode + observedMetric.hashCode;

  factory TodayAnalysisReadResponseAnalysisMetrics.fromJson(
    Map<String, dynamic> json,
  ) => _$TodayAnalysisReadResponseAnalysisMetricsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$TodayAnalysisReadResponseAnalysisMetricsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum TodayAnalysisReadResponseAnalysisMetricsKindEnum {
  @JsonValue(r'medication')
  medication(r'medication'),
  @JsonValue(r'water')
  water(r'water'),
  @JsonValue(r'sleep')
  sleep(r'sleep'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const TodayAnalysisReadResponseAnalysisMetricsKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
