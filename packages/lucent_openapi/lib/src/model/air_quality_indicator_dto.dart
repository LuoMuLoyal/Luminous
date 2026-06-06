//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/air_quality_level.dart';
import 'package:json_annotation/json_annotation.dart';

part 'air_quality_indicator_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AirQualityIndicatorDto {
  /// Returns a new [AirQualityIndicatorDto] instance.
  AirQualityIndicatorDto({
    required this.aqi,

    required this.level,

    required this.primaryPollutant,
  });

  @JsonKey(name: r'aqi', required: true, includeIfNull: false)
  final num aqi;

  @JsonKey(
    name: r'level',
    required: true,
    includeIfNull: false,
    unknownEnumValue: AirQualityLevel.unknownDefaultOpenApi,
  )
  final AirQualityLevel level;

  @JsonKey(name: r'primaryPollutant', required: true, includeIfNull: true)
  final String? primaryPollutant;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AirQualityIndicatorDto &&
          other.aqi == aqi &&
          other.level == level &&
          other.primaryPollutant == primaryPollutant;

  @override
  int get hashCode =>
      aqi.hashCode +
      level.hashCode +
      (primaryPollutant == null ? 0 : primaryPollutant.hashCode);

  factory AirQualityIndicatorDto.fromJson(Map<String, dynamic> json) =>
      _$AirQualityIndicatorDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AirQualityIndicatorDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
