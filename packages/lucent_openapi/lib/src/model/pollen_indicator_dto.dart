//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/pollen_level.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pollen_indicator_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PollenIndicatorDto {
  /// Returns a new [PollenIndicatorDto] instance.
  PollenIndicatorDto({
    required this.level,

    required this.primaryType,

    required this.value,

    required this.unit,
  });

  @JsonKey(
    name: r'level',
    required: true,
    includeIfNull: false,
    unknownEnumValue: PollenLevel.unknownDefaultOpenApi,
  )
  final PollenLevel level;

  @JsonKey(name: r'primaryType', required: true, includeIfNull: true)
  final String? primaryType;

  @JsonKey(name: r'value', required: true, includeIfNull: true)
  final num? value;

  @JsonKey(name: r'unit', required: true, includeIfNull: true)
  final String? unit;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PollenIndicatorDto &&
          other.level == level &&
          other.primaryType == primaryType &&
          other.value == value &&
          other.unit == unit;

  @override
  int get hashCode =>
      level.hashCode +
      (primaryType == null ? 0 : primaryType.hashCode) +
      (value == null ? 0 : value.hashCode) +
      (unit == null ? 0 : unit.hashCode);

  factory PollenIndicatorDto.fromJson(Map<String, dynamic> json) =>
      _$PollenIndicatorDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PollenIndicatorDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
