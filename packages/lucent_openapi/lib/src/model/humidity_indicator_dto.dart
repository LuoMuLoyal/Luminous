//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'humidity_indicator_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HumidityIndicatorDto {
  /// Returns a new [HumidityIndicatorDto] instance.
  HumidityIndicatorDto({required this.percent});

  @JsonKey(name: r'percent', required: true, includeIfNull: false)
  final num percent;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HumidityIndicatorDto && other.percent == percent;

  @override
  int get hashCode => percent.hashCode;

  factory HumidityIndicatorDto.fromJson(Map<String, dynamic> json) =>
      _$HumidityIndicatorDtoFromJson(json);

  Map<String, dynamic> toJson() => _$HumidityIndicatorDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
