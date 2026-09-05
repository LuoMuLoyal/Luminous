//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/report_dashboard_response_metrics_observed_metric.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_dashboard_response_metrics.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportDashboardResponseMetrics {
  /// Returns a new [ReportDashboardResponseMetrics] instance.
  ReportDashboardResponseMetrics({
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
        ReportDashboardResponseMetricsKindEnum.unknownDefaultOpenApi,
  )
  final ReportDashboardResponseMetricsKindEnum kind;

  @JsonKey(name: r'value', required: true, includeIfNull: false)
  final String value;

  @JsonKey(name: r'unit', required: true, includeIfNull: false)
  final String unit;

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        ReportDashboardResponseMetricsStatusEnum.unknownDefaultOpenApi,
  )
  final ReportDashboardResponseMetricsStatusEnum status;

  @JsonKey(name: r'delta', required: true, includeIfNull: false)
  final String delta;

  @JsonKey(
    name: r'direction',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        ReportDashboardResponseMetricsDirectionEnum.unknownDefaultOpenApi,
  )
  final ReportDashboardResponseMetricsDirectionEnum direction;

  @JsonKey(name: r'sparkline', required: true, includeIfNull: false)
  final List<num> sparkline;

  @JsonKey(name: r'observedMetric', required: false, includeIfNull: false)
  final ReportDashboardResponseMetricsObservedMetric? observedMetric;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportDashboardResponseMetrics &&
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

  factory ReportDashboardResponseMetrics.fromJson(Map<String, dynamic> json) =>
      _$ReportDashboardResponseMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$ReportDashboardResponseMetricsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ReportDashboardResponseMetricsKindEnum {
  @JsonValue(r'medication')
  medication(r'medication'),
  @JsonValue(r'water')
  water(r'water'),
  @JsonValue(r'sleep')
  sleep(r'sleep'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ReportDashboardResponseMetricsKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum ReportDashboardResponseMetricsStatusEnum {
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

  const ReportDashboardResponseMetricsStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum ReportDashboardResponseMetricsDirectionEnum {
  @JsonValue(r'up')
  up(r'up'),
  @JsonValue(r'down')
  down(r'down'),
  @JsonValue(r'flat')
  flat(r'flat'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ReportDashboardResponseMetricsDirectionEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
