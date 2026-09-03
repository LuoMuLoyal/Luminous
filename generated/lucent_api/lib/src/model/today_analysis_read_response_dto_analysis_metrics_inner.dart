//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/today_suggestions_response_dto_primary_observed_metric.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_analysis_read_response_dto_analysis_metrics_inner.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodayAnalysisReadResponseDtoAnalysisMetricsInner {
  /// Returns a new [TodayAnalysisReadResponseDtoAnalysisMetricsInner] instance.
  TodayAnalysisReadResponseDtoAnalysisMetricsInner({
    required this.kind,

    required this.observedMetric,
  });

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue: TodayAnalysisReadResponseDtoAnalysisMetricsInnerKindEnum
        .unknownDefaultOpenApi,
  )
  final TodayAnalysisReadResponseDtoAnalysisMetricsInnerKindEnum kind;

  @JsonKey(name: r'observedMetric', required: true, includeIfNull: false)
  final TodaySuggestionsResponseDtoPrimaryObservedMetric observedMetric;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayAnalysisReadResponseDtoAnalysisMetricsInner &&
          other.kind == kind &&
          other.observedMetric == observedMetric;

  @override
  int get hashCode => kind.hashCode + observedMetric.hashCode;

  factory TodayAnalysisReadResponseDtoAnalysisMetricsInner.fromJson(
    Map<String, dynamic> json,
  ) => _$TodayAnalysisReadResponseDtoAnalysisMetricsInnerFromJson(json);

  Map<String, dynamic> toJson() =>
      _$TodayAnalysisReadResponseDtoAnalysisMetricsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum TodayAnalysisReadResponseDtoAnalysisMetricsInnerKindEnum {
  @JsonValue(r'medication')
  medication(r'medication'),
  @JsonValue(r'water')
  water(r'water'),
  @JsonValue(r'sleep')
  sleep(r'sleep'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const TodayAnalysisReadResponseDtoAnalysisMetricsInnerKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
