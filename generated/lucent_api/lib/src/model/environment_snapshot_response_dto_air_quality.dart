//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'environment_snapshot_response_dto_air_quality.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EnvironmentSnapshotResponseDtoAirQuality {
  /// Returns a new [EnvironmentSnapshotResponseDtoAirQuality] instance.
  EnvironmentSnapshotResponseDtoAirQuality({
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
    unknownEnumValue:
        EnvironmentSnapshotResponseDtoAirQualityLevelEnum.unknownDefaultOpenApi,
  )
  final EnvironmentSnapshotResponseDtoAirQualityLevelEnum level;

  @JsonKey(name: r'primaryPollutant', required: true, includeIfNull: true)
  final String? primaryPollutant;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvironmentSnapshotResponseDtoAirQuality &&
          other.aqi == aqi &&
          other.level == level &&
          other.primaryPollutant == primaryPollutant;

  @override
  int get hashCode =>
      aqi.hashCode +
      level.hashCode +
      (primaryPollutant == null ? 0 : primaryPollutant.hashCode);

  factory EnvironmentSnapshotResponseDtoAirQuality.fromJson(
    Map<String, dynamic> json,
  ) => _$EnvironmentSnapshotResponseDtoAirQualityFromJson(json);

  Map<String, dynamic> toJson() =>
      _$EnvironmentSnapshotResponseDtoAirQualityToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum EnvironmentSnapshotResponseDtoAirQualityLevelEnum {
  @JsonValue(r'good')
  good(r'good'),
  @JsonValue(r'moderate')
  moderate(r'moderate'),
  @JsonValue(r'unhealthy_sensitive')
  unhealthySensitive(r'unhealthy_sensitive'),
  @JsonValue(r'unhealthy')
  unhealthy(r'unhealthy'),
  @JsonValue(r'very_unhealthy')
  veryUnhealthy(r'very_unhealthy'),
  @JsonValue(r'hazardous')
  hazardous(r'hazardous'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const EnvironmentSnapshotResponseDtoAirQualityLevelEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
