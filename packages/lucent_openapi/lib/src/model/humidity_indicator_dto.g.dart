// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'humidity_indicator_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HumidityIndicatorDto _$HumidityIndicatorDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('HumidityIndicatorDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['percent']);
  final val = HumidityIndicatorDto(
    percent: $checkedConvert('percent', (v) => v as num),
  );
  return val;
});

Map<String, dynamic> _$HumidityIndicatorDtoToJson(
  HumidityIndicatorDto instance,
) => <String, dynamic>{'percent': instance.percent};
