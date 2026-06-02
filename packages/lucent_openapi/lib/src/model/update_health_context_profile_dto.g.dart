// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_health_context_profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateHealthContextProfileDto _$UpdateHealthContextProfileDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UpdateHealthContextProfileDto', json, ($checkedConvert) {
  final val = UpdateHealthContextProfileDto(
    locale: $checkedConvert('locale', (v) => v),
    timezone: $checkedConvert('timezone', (v) => v),
    unitSystem: $checkedConvert(
      'unitSystem',
      (v) => $enumDecodeNullable(
        _$UnitSystemEnumMap,
        v,
        unknownValue: UnitSystem.unknownDefaultOpenApi,
      ),
    ),
  );
  return val;
});

Map<String, dynamic> _$UpdateHealthContextProfileDtoToJson(
  UpdateHealthContextProfileDto instance,
) => <String, dynamic>{
  if (instance.locale != null) 'locale': instance.locale,
  if (instance.timezone != null) 'timezone': instance.timezone,
  if (_$UnitSystemEnumMap[instance.unitSystem] != null)
    'unitSystem': _$UnitSystemEnumMap[instance.unitSystem],
};

const _$UnitSystemEnumMap = {
  UnitSystem.metric: 'metric',
  UnitSystem.imperial: 'imperial',
  UnitSystem.unknownDefaultOpenApi: 'unknown_default_open_api',
};
