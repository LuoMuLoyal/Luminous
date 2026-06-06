// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temperature_indicator_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TemperatureIndicatorDto _$TemperatureIndicatorDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('TemperatureIndicatorDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['celsius', 'feelsLike']);
  final val = TemperatureIndicatorDto(
    celsius: $checkedConvert('celsius', (v) => v as num),
    feelsLike: $checkedConvert('feelsLike', (v) => v as num),
  );
  return val;
});

Map<String, dynamic> _$TemperatureIndicatorDtoToJson(
  TemperatureIndicatorDto instance,
) => <String, dynamic>{
  'celsius': instance.celsius,
  'feelsLike': instance.feelsLike,
};
