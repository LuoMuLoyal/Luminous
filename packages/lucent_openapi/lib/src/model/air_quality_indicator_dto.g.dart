// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'air_quality_indicator_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AirQualityIndicatorDto _$AirQualityIndicatorDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AirQualityIndicatorDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['aqi', 'level', 'primaryPollutant']);
  final val = AirQualityIndicatorDto(
    aqi: $checkedConvert('aqi', (v) => v as num),
    level: $checkedConvert(
      'level',
      (v) => $enumDecode(
        _$AirQualityLevelEnumMap,
        v,
        unknownValue: AirQualityLevel.unknownDefaultOpenApi,
      ),
    ),
    primaryPollutant: $checkedConvert('primaryPollutant', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$AirQualityIndicatorDtoToJson(
  AirQualityIndicatorDto instance,
) => <String, dynamic>{
  'aqi': instance.aqi,
  'level': _$AirQualityLevelEnumMap[instance.level]!,
  'primaryPollutant': instance.primaryPollutant,
};

const _$AirQualityLevelEnumMap = {
  AirQualityLevel.good: 'good',
  AirQualityLevel.moderate: 'moderate',
  AirQualityLevel.unhealthySensitive: 'unhealthy_sensitive',
  AirQualityLevel.unhealthy: 'unhealthy',
  AirQualityLevel.veryUnhealthy: 'very_unhealthy',
  AirQualityLevel.hazardous: 'hazardous',
  AirQualityLevel.unknownDefaultOpenApi: 'unknown_default_open_api',
};
