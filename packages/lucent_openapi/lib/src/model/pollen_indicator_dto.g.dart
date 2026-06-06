// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pollen_indicator_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PollenIndicatorDto _$PollenIndicatorDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PollenIndicatorDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['level', 'primaryType', 'value', 'unit'],
      );
      final val = PollenIndicatorDto(
        level: $checkedConvert(
          'level',
          (v) => $enumDecode(
            _$PollenLevelEnumMap,
            v,
            unknownValue: PollenLevel.unknownDefaultOpenApi,
          ),
        ),
        primaryType: $checkedConvert('primaryType', (v) => v as String?),
        value: $checkedConvert('value', (v) => v as num?),
        unit: $checkedConvert('unit', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$PollenIndicatorDtoToJson(PollenIndicatorDto instance) =>
    <String, dynamic>{
      'level': _$PollenLevelEnumMap[instance.level]!,
      'primaryType': instance.primaryType,
      'value': instance.value,
      'unit': instance.unit,
    };

const _$PollenLevelEnumMap = {
  PollenLevel.low: 'low',
  PollenLevel.medium: 'medium',
  PollenLevel.high: 'high',
  PollenLevel.unknownDefaultOpenApi: 'unknown_default_open_api',
};
