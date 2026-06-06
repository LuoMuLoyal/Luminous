//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/temperature_indicator_dto.dart';
import 'package:lucent_openapi/src/model/uv_indicator_dto.dart';
import 'package:lucent_openapi/src/model/air_quality_indicator_dto.dart';
import 'package:lucent_openapi/src/model/humidity_indicator_dto.dart';
import 'package:lucent_openapi/src/model/pollen_indicator_dto.dart';
import 'package:lucent_openapi/src/model/environment_data_source.dart';
import 'package:json_annotation/json_annotation.dart';

part 'environment_snapshot_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EnvironmentSnapshotDto {
  /// Returns a new [EnvironmentSnapshotDto] instance.
  EnvironmentSnapshotDto({
    required this.dataSource,

    required this.updatedAt,

    required this.regionHint,

    required this.pollen,

    required this.uv,

    required this.airQuality,

    required this.temperature,

    required this.humidity,
  });

  @JsonKey(
    name: r'dataSource',
    required: true,
    includeIfNull: false,
    unknownEnumValue: EnvironmentDataSource.unknownDefaultOpenApi,
  )
  final EnvironmentDataSource dataSource;

  /// ISO-8601 timestamp for the static reference data refresh.
  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final String updatedAt;

  @JsonKey(name: r'regionHint', required: true, includeIfNull: true)
  final String? regionHint;

  @JsonKey(name: r'pollen', required: true, includeIfNull: false)
  final PollenIndicatorDto pollen;

  @JsonKey(name: r'uv', required: true, includeIfNull: false)
  final UvIndicatorDto uv;

  @JsonKey(name: r'airQuality', required: true, includeIfNull: false)
  final AirQualityIndicatorDto airQuality;

  @JsonKey(name: r'temperature', required: true, includeIfNull: false)
  final TemperatureIndicatorDto temperature;

  @JsonKey(name: r'humidity', required: true, includeIfNull: false)
  final HumidityIndicatorDto humidity;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvironmentSnapshotDto &&
          other.dataSource == dataSource &&
          other.updatedAt == updatedAt &&
          other.regionHint == regionHint &&
          other.pollen == pollen &&
          other.uv == uv &&
          other.airQuality == airQuality &&
          other.temperature == temperature &&
          other.humidity == humidity;

  @override
  int get hashCode =>
      dataSource.hashCode +
      updatedAt.hashCode +
      (regionHint == null ? 0 : regionHint.hashCode) +
      pollen.hashCode +
      uv.hashCode +
      airQuality.hashCode +
      temperature.hashCode +
      humidity.hashCode;

  factory EnvironmentSnapshotDto.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentSnapshotDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EnvironmentSnapshotDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
