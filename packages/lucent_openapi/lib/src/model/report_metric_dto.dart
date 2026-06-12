//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'report_metric_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportMetricDto {
  /// Returns a new [ReportMetricDto] instance.
  ReportMetricDto({
    required this.kind,

    required this.value,

    required this.unit,

    required this.status,

    required this.delta,

    required this.direction,

    required this.sparkline,
  });

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue: ReportMetricDtoKindEnum.unknownDefaultOpenApi,
  )
  final ReportMetricDtoKindEnum kind;

  @JsonKey(name: r'value', required: true, includeIfNull: false)
  final String value;

  @JsonKey(name: r'unit', required: true, includeIfNull: false)
  final String unit;

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue: ReportMetricDtoStatusEnum.unknownDefaultOpenApi,
  )
  final ReportMetricDtoStatusEnum status;

  @JsonKey(name: r'delta', required: true, includeIfNull: false)
  final String delta;

  @JsonKey(
    name: r'direction',
    required: true,
    includeIfNull: false,
    unknownEnumValue: ReportMetricDtoDirectionEnum.unknownDefaultOpenApi,
  )
  final ReportMetricDtoDirectionEnum direction;

  @JsonKey(name: r'sparkline', required: true, includeIfNull: false)
  final List<num> sparkline;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportMetricDto &&
          other.kind == kind &&
          other.value == value &&
          other.unit == unit &&
          other.status == status &&
          other.delta == delta &&
          other.direction == direction &&
          other.sparkline == sparkline;

  @override
  int get hashCode =>
      kind.hashCode +
      value.hashCode +
      unit.hashCode +
      status.hashCode +
      delta.hashCode +
      direction.hashCode +
      sparkline.hashCode;

  factory ReportMetricDto.fromJson(Map<String, dynamic> json) =>
      _$ReportMetricDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReportMetricDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ReportMetricDtoKindEnum {
  @JsonValue(r'medication')
  medication(r'medication'),
  @JsonValue(r'water')
  water(r'water'),
  @JsonValue(r'sleep')
  sleep(r'sleep'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ReportMetricDtoKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum ReportMetricDtoStatusEnum {
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

  const ReportMetricDtoStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum ReportMetricDtoDirectionEnum {
  @JsonValue(r'up')
  up(r'up'),
  @JsonValue(r'down')
  down(r'down'),
  @JsonValue(r'flat')
  flat(r'flat'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ReportMetricDtoDirectionEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
