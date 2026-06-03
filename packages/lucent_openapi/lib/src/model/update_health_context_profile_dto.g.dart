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
    birthDate: $checkedConvert('birthDate', (v) => v),
    sexAtBirth: $checkedConvert(
      'sexAtBirth',
      (v) => $enumDecodeNullable(
        _$SexAtBirthEnumMap,
        v,
        unknownValue: SexAtBirth.unknownDefaultOpenApi,
      ),
    ),
    heightCm: $checkedConvert('heightCm', (v) => v),
    pregnancyState: $checkedConvert(
      'pregnancyState',
      (v) => $enumDecodeNullable(
        _$PregnancyStateEnumMap,
        v,
        unknownValue: PregnancyState.unknownDefaultOpenApi,
      ),
    ),
    lactationState: $checkedConvert(
      'lactationState',
      (v) => $enumDecodeNullable(
        _$LactationStateEnumMap,
        v,
        unknownValue: LactationState.unknownDefaultOpenApi,
      ),
    ),
    bloodType: $checkedConvert('bloodType', (v) => v),
    onboardingCompleted: $checkedConvert(
      'onboardingCompleted',
      (v) => v as bool?,
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
  if (instance.birthDate != null) 'birthDate': instance.birthDate,
  if (_$SexAtBirthEnumMap[instance.sexAtBirth] != null)
    'sexAtBirth': _$SexAtBirthEnumMap[instance.sexAtBirth],
  if (instance.heightCm != null) 'heightCm': instance.heightCm,
  if (_$PregnancyStateEnumMap[instance.pregnancyState] != null)
    'pregnancyState': _$PregnancyStateEnumMap[instance.pregnancyState],
  if (_$LactationStateEnumMap[instance.lactationState] != null)
    'lactationState': _$LactationStateEnumMap[instance.lactationState],
  if (instance.bloodType != null) 'bloodType': instance.bloodType,
  if (instance.onboardingCompleted != null)
    'onboardingCompleted': instance.onboardingCompleted,
};

const _$UnitSystemEnumMap = {
  UnitSystem.metric: 'metric',
  UnitSystem.imperial: 'imperial',
  UnitSystem.unknownDefaultOpenApi: 'unknown_default_open_api',
};

const _$SexAtBirthEnumMap = {
  SexAtBirth.female: 'female',
  SexAtBirth.male: 'male',
  SexAtBirth.intersex: 'intersex',
  SexAtBirth.unknown: 'unknown',
  SexAtBirth.unknownDefaultOpenApi: 'unknown_default_open_api',
};

const _$PregnancyStateEnumMap = {
  PregnancyState.notApplicable: 'not_applicable',
  PregnancyState.unknown: 'unknown',
  PregnancyState.notPregnant: 'not_pregnant',
  PregnancyState.pregnant: 'pregnant',
  PregnancyState.trying: 'trying',
  PregnancyState.postpartum: 'postpartum',
  PregnancyState.unknownDefaultOpenApi: 'unknown_default_open_api',
};

const _$LactationStateEnumMap = {
  LactationState.notApplicable: 'not_applicable',
  LactationState.unknown: 'unknown',
  LactationState.no: 'no',
  LactationState.yes: 'yes',
  LactationState.unknownDefaultOpenApi: 'unknown_default_open_api',
};
