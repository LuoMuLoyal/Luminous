// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_health_profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserHealthProfileDto _$UserHealthProfileDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UserHealthProfileDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'birthDate',
      'sexAtBirth',
      'heightCm',
      'bloodType',
      'locale',
      'timezone',
      'unitSystem',
      'onboardingCompletedAt',
      'extras',
    ],
  );
  final val = UserHealthProfileDto(
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
    bloodType: $checkedConvert('bloodType', (v) => v),
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
    onboardingCompletedAt: $checkedConvert('onboardingCompletedAt', (v) => v),
    extras: $checkedConvert(
      'extras',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as Object)),
    ),
  );
  return val;
});

Map<String, dynamic> _$UserHealthProfileDtoToJson(
  UserHealthProfileDto instance,
) => <String, dynamic>{
  'birthDate': instance.birthDate,
  'sexAtBirth': _$SexAtBirthEnumMap[instance.sexAtBirth],
  'heightCm': instance.heightCm,
  'bloodType': instance.bloodType,
  'locale': instance.locale,
  'timezone': instance.timezone,
  'unitSystem': _$UnitSystemEnumMap[instance.unitSystem],
  'onboardingCompletedAt': instance.onboardingCompletedAt,
  'extras': instance.extras,
};

const _$SexAtBirthEnumMap = {
  SexAtBirth.female: 'female',
  SexAtBirth.male: 'male',
  SexAtBirth.intersex: 'intersex',
  SexAtBirth.unknown: 'unknown',
  SexAtBirth.unknownDefaultOpenApi: 'unknown_default_open_api',
};

const _$UnitSystemEnumMap = {
  UnitSystem.metric: 'metric',
  UnitSystem.imperial: 'imperial',
  UnitSystem.unknownDefaultOpenApi: 'unknown_default_open_api',
};
