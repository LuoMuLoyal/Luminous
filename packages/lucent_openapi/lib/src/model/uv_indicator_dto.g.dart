// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'uv_indicator_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UvIndicatorDto _$UvIndicatorDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UvIndicatorDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['index', 'level']);
      final val = UvIndicatorDto(
        index: $checkedConvert('index', (v) => v as num),
        level: $checkedConvert(
          'level',
          (v) => $enumDecode(
            _$UvLevelEnumMap,
            v,
            unknownValue: UvLevel.unknownDefaultOpenApi,
          ),
        ),
      );
      return val;
    });

Map<String, dynamic> _$UvIndicatorDtoToJson(UvIndicatorDto instance) =>
    <String, dynamic>{
      'index': instance.index,
      'level': _$UvLevelEnumMap[instance.level]!,
    };

const _$UvLevelEnumMap = {
  UvLevel.low: 'low',
  UvLevel.moderate: 'moderate',
  UvLevel.high: 'high',
  UvLevel.veryHigh: 'very_high',
  UvLevel.extreme: 'extreme',
  UvLevel.unknownDefaultOpenApi: 'unknown_default_open_api',
};
