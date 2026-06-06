//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'temperature_indicator_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TemperatureIndicatorDto {
  /// Returns a new [TemperatureIndicatorDto] instance.
  TemperatureIndicatorDto({required this.celsius, required this.feelsLike});

  @JsonKey(name: r'celsius', required: true, includeIfNull: false)
  final num celsius;

  @JsonKey(name: r'feelsLike', required: true, includeIfNull: false)
  final num feelsLike;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemperatureIndicatorDto &&
          other.celsius == celsius &&
          other.feelsLike == feelsLike;

  @override
  int get hashCode => celsius.hashCode + feelsLike.hashCode;

  factory TemperatureIndicatorDto.fromJson(Map<String, dynamic> json) =>
      _$TemperatureIndicatorDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TemperatureIndicatorDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
