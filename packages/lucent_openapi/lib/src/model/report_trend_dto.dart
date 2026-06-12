//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'report_trend_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportTrendDto {
  /// Returns a new [ReportTrendDto] instance.
  ReportTrendDto({
    required this.kind,

    required this.unit,

    required this.currentValue,

    required this.values,
  });

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue: ReportTrendDtoKindEnum.unknownDefaultOpenApi,
  )
  final ReportTrendDtoKindEnum kind;

  @JsonKey(name: r'unit', required: true, includeIfNull: false)
  final String unit;

  @JsonKey(name: r'currentValue', required: true, includeIfNull: false)
  final String currentValue;

  @JsonKey(name: r'values', required: true, includeIfNull: false)
  final List<num> values;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportTrendDto &&
          other.kind == kind &&
          other.unit == unit &&
          other.currentValue == currentValue &&
          other.values == values;

  @override
  int get hashCode =>
      kind.hashCode + unit.hashCode + currentValue.hashCode + values.hashCode;

  factory ReportTrendDto.fromJson(Map<String, dynamic> json) =>
      _$ReportTrendDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReportTrendDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ReportTrendDtoKindEnum {
  @JsonValue(r'medication')
  medication(r'medication'),
  @JsonValue(r'water')
  water(r'water'),
  @JsonValue(r'sleep')
  sleep(r'sleep'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ReportTrendDtoKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
