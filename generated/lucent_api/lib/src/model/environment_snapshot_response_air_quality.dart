//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'environment_snapshot_response_air_quality.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EnvironmentSnapshotResponseAirQuality {
  /// Returns a new [EnvironmentSnapshotResponseAirQuality] instance.
  EnvironmentSnapshotResponseAirQuality({
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
        EnvironmentSnapshotResponseAirQualityLevelEnum.unknownDefaultOpenApi,
  )
  final EnvironmentSnapshotResponseAirQualityLevelEnum level;

  @JsonKey(name: r'primaryPollutant', required: true, includeIfNull: true)
  final String? primaryPollutant;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvironmentSnapshotResponseAirQuality &&
          other.aqi == aqi &&
          other.level == level &&
          other.primaryPollutant == primaryPollutant;

  @override
  int get hashCode =>
      aqi.hashCode +
      level.hashCode +
      (primaryPollutant == null ? 0 : primaryPollutant.hashCode);

  factory EnvironmentSnapshotResponseAirQuality.fromJson(
    Map<String, dynamic> json,
  ) => _$EnvironmentSnapshotResponseAirQualityFromJson(json);

  Map<String, dynamic> toJson() =>
      _$EnvironmentSnapshotResponseAirQualityToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum EnvironmentSnapshotResponseAirQualityLevelEnum {
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

  const EnvironmentSnapshotResponseAirQualityLevelEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
