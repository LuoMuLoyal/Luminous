//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/environment_snapshot_response_dto_humidity.dart';
import 'package:lucent_api/src/model/environment_snapshot_response_dto_temperature.dart';
import 'package:lucent_api/src/model/environment_snapshot_response_dto_air_quality.dart';
import 'package:lucent_api/src/model/environment_snapshot_response_dto_pollen.dart';
import 'package:lucent_api/src/model/environment_snapshot_response_dto_uv.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'environment_snapshot_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EnvironmentSnapshotResponseDto {
  /// Returns a new [EnvironmentSnapshotResponseDto] instance.
  EnvironmentSnapshotResponseDto({
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
    unknownEnumValue:
        EnvironmentSnapshotResponseDtoDataSourceEnum.unknownDefaultOpenApi,
  )
  final EnvironmentSnapshotResponseDtoDataSourceEnum dataSource;

  /// ISO-8601 timestamp for the static reference data refresh.
  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final String updatedAt;

  @JsonKey(name: r'regionHint', required: true, includeIfNull: true)
  final String? regionHint;

  @JsonKey(name: r'pollen', required: true, includeIfNull: false)
  final EnvironmentSnapshotResponseDtoPollen pollen;

  @JsonKey(name: r'uv', required: true, includeIfNull: false)
  final EnvironmentSnapshotResponseDtoUv uv;

  @JsonKey(name: r'airQuality', required: true, includeIfNull: false)
  final EnvironmentSnapshotResponseDtoAirQuality airQuality;

  @JsonKey(name: r'temperature', required: true, includeIfNull: false)
  final EnvironmentSnapshotResponseDtoTemperature temperature;

  @JsonKey(name: r'humidity', required: true, includeIfNull: false)
  final EnvironmentSnapshotResponseDtoHumidity humidity;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvironmentSnapshotResponseDto &&
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

  factory EnvironmentSnapshotResponseDto.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentSnapshotResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EnvironmentSnapshotResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum EnvironmentSnapshotResponseDtoDataSourceEnum {
  @JsonValue(r'static')
  static_(r'static'),
  @JsonValue(r'live')
  live(r'live'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const EnvironmentSnapshotResponseDtoDataSourceEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
