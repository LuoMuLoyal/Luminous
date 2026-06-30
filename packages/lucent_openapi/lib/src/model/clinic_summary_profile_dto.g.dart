// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinic_summary_profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClinicSummaryProfileDto _$ClinicSummaryProfileDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ClinicSummaryProfileDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['nickname', 'sexAtBirth']);
  final val = ClinicSummaryProfileDto(
    nickname: $checkedConvert('nickname', (v) => v as String),
    age: $checkedConvert('age', (v) => v),
    sexAtBirth: $checkedConvert('sexAtBirth', (v) => v as Object),
    bloodType: $checkedConvert('bloodType', (v) => v),
  );
  return val;
});

Map<String, dynamic> _$ClinicSummaryProfileDtoToJson(
  ClinicSummaryProfileDto instance,
) => <String, dynamic>{
  'nickname': instance.nickname,
  if (instance.age != null) 'age': instance.age,
  'sexAtBirth': instance.sexAtBirth,
  if (instance.bloodType != null) 'bloodType': instance.bloodType,
};
