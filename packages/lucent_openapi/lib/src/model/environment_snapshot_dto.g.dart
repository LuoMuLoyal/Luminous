// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environment_snapshot_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnvironmentSnapshotDto _$EnvironmentSnapshotDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('EnvironmentSnapshotDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'dataSource',
      'updatedAt',
      'regionHint',
      'pollen',
      'uv',
      'airQuality',
      'temperature',
      'humidity',
    ],
  );
  final val = EnvironmentSnapshotDto(
    dataSource: $checkedConvert(
      'dataSource',
      (v) => $enumDecode(
        _$EnvironmentDataSourceEnumMap,
        v,
        unknownValue: EnvironmentDataSource.unknownDefaultOpenApi,
      ),
    ),
    updatedAt: $checkedConvert('updatedAt', (v) => v as String),
    regionHint: $checkedConvert('regionHint', (v) => v as String?),
    pollen: $checkedConvert(
      'pollen',
      (v) => PollenIndicatorDto.fromJson(v as Map<String, dynamic>),
    ),
    uv: $checkedConvert(
      'uv',
      (v) => UvIndicatorDto.fromJson(v as Map<String, dynamic>),
    ),
    airQuality: $checkedConvert(
      'airQuality',
      (v) => AirQualityIndicatorDto.fromJson(v as Map<String, dynamic>),
    ),
    temperature: $checkedConvert(
      'temperature',
      (v) => TemperatureIndicatorDto.fromJson(v as Map<String, dynamic>),
    ),
    humidity: $checkedConvert(
      'humidity',
      (v) => HumidityIndicatorDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$EnvironmentSnapshotDtoToJson(
  EnvironmentSnapshotDto instance,
) => <String, dynamic>{
  'dataSource': _$EnvironmentDataSourceEnumMap[instance.dataSource]!,
  'updatedAt': instance.updatedAt,
  'regionHint': instance.regionHint,
  'pollen': instance.pollen.toJson(),
  'uv': instance.uv.toJson(),
  'airQuality': instance.airQuality.toJson(),
  'temperature': instance.temperature.toJson(),
  'humidity': instance.humidity.toJson(),
};

const _$EnvironmentDataSourceEnumMap = {
  EnvironmentDataSource.static_: 'static',
  EnvironmentDataSource.live: 'live',
  EnvironmentDataSource.unknownDefaultOpenApi: 'unknown_default_open_api',
};
