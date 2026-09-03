//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/report_dashboard_response_dto_metrics_inner_observed_metric.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_dashboard_response_dto_metrics_inner.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportDashboardResponseDtoMetricsInner {
  /// Returns a new [ReportDashboardResponseDtoMetricsInner] instance.
  ReportDashboardResponseDtoMetricsInner({
    required this.kind,

    required this.value,

    required this.unit,

    required this.status,

    required this.delta,

    required this.direction,

    required this.sparkline,

    this.observedMetric,
  });

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        ReportDashboardResponseDtoMetricsInnerKindEnum.unknownDefaultOpenApi,
  )
  final ReportDashboardResponseDtoMetricsInnerKindEnum kind;

  @JsonKey(name: r'value', required: true, includeIfNull: false)
  final String value;

  @JsonKey(name: r'unit', required: true, includeIfNull: false)
  final String unit;

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        ReportDashboardResponseDtoMetricsInnerStatusEnum.unknownDefaultOpenApi,
  )
  final ReportDashboardResponseDtoMetricsInnerStatusEnum status;

  @JsonKey(name: r'delta', required: true, includeIfNull: false)
  final String delta;

  @JsonKey(
    name: r'direction',
    required: true,
    includeIfNull: false,
    unknownEnumValue: ReportDashboardResponseDtoMetricsInnerDirectionEnum
        .unknownDefaultOpenApi,
  )
  final ReportDashboardResponseDtoMetricsInnerDirectionEnum direction;

  @JsonKey(name: r'sparkline', required: true, includeIfNull: false)
  final List<num> sparkline;

  @JsonKey(name: r'observedMetric', required: false, includeIfNull: false)
  final ReportDashboardResponseDtoMetricsInnerObservedMetric? observedMetric;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportDashboardResponseDtoMetricsInner &&
          other.kind == kind &&
          other.value == value &&
          other.unit == unit &&
          other.status == status &&
          other.delta == delta &&
          other.direction == direction &&
          other.sparkline == sparkline &&
          other.observedMetric == observedMetric;

  @override
  int get hashCode =>
      kind.hashCode +
      value.hashCode +
      unit.hashCode +
      status.hashCode +
      delta.hashCode +
      direction.hashCode +
      sparkline.hashCode +
      observedMetric.hashCode;

  factory ReportDashboardResponseDtoMetricsInner.fromJson(
    Map<String, dynamic> json,
  ) => _$ReportDashboardResponseDtoMetricsInnerFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ReportDashboardResponseDtoMetricsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ReportDashboardResponseDtoMetricsInnerKindEnum {
  @JsonValue(r'medication')
  medication(r'medication'),
  @JsonValue(r'water')
  water(r'water'),
  @JsonValue(r'sleep')
  sleep(r'sleep'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ReportDashboardResponseDtoMetricsInnerKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum ReportDashboardResponseDtoMetricsInnerStatusEnum {
  @JsonValue(r'good')
  good(r'good'),
  @JsonValue(r'stable')
  stable(r'stable'),
  @JsonValue(r'needs_attention')
  needsAttention(r'needs_attention'),
  @JsonValue(r'insufficient_data')
  insufficientData(r'insufficient_data'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ReportDashboardResponseDtoMetricsInnerStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum ReportDashboardResponseDtoMetricsInnerDirectionEnum {
  @JsonValue(r'up')
  up(r'up'),
  @JsonValue(r'down')
  down(r'down'),
  @JsonValue(r'flat')
  flat(r'flat'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ReportDashboardResponseDtoMetricsInnerDirectionEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
