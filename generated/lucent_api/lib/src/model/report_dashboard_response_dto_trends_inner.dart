//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/report_dashboard_response_dto_metrics_inner_observed_metric.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_dashboard_response_dto_trends_inner.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportDashboardResponseDtoTrendsInner {
  /// Returns a new [ReportDashboardResponseDtoTrendsInner] instance.
  ReportDashboardResponseDtoTrendsInner({
    required this.kind,

    required this.unit,

    required this.currentValue,

    required this.values,

    this.observedMetric,
  });

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        ReportDashboardResponseDtoTrendsInnerKindEnum.unknownDefaultOpenApi,
  )
  final ReportDashboardResponseDtoTrendsInnerKindEnum kind;

  @JsonKey(name: r'unit', required: true, includeIfNull: false)
  final String unit;

  @JsonKey(name: r'currentValue', required: true, includeIfNull: false)
  final String currentValue;

  /// Observed values only — unknown days are omitted, not zero-filled. BREAKING (since 2026-08-29): values.length no longer matches the date window length; use observedMetric.observedCount/expectedCount to align dates.
  @JsonKey(name: r'values', required: true, includeIfNull: false)
  final List<num> values;

  @JsonKey(name: r'observedMetric', required: false, includeIfNull: false)
  final ReportDashboardResponseDtoMetricsInnerObservedMetric? observedMetric;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportDashboardResponseDtoTrendsInner &&
          other.kind == kind &&
          other.unit == unit &&
          other.currentValue == currentValue &&
          other.values == values &&
          other.observedMetric == observedMetric;

  @override
  int get hashCode =>
      kind.hashCode +
      unit.hashCode +
      currentValue.hashCode +
      values.hashCode +
      observedMetric.hashCode;

  factory ReportDashboardResponseDtoTrendsInner.fromJson(
    Map<String, dynamic> json,
  ) => _$ReportDashboardResponseDtoTrendsInnerFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ReportDashboardResponseDtoTrendsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ReportDashboardResponseDtoTrendsInnerKindEnum {
  @JsonValue(r'medication')
  medication(r'medication'),
  @JsonValue(r'water')
  water(r'water'),
  @JsonValue(r'sleep')
  sleep(r'sleep'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ReportDashboardResponseDtoTrendsInnerKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
