// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_context_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthContextDataDto _$HealthContextDataDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('HealthContextDataDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'summary',
      'profile',
      'allergies',
      'conditions',
      'currentMedicines',
    ],
  );
  final val = HealthContextDataDto(
    summary: $checkedConvert(
      'summary',
      (v) => UserHealthSummaryDto.fromJson(v as Map<String, dynamic>),
    ),
    profile: $checkedConvert(
      'profile',
      (v) => UserHealthProfileDto.fromJson(v as Map<String, dynamic>),
    ),
    allergies: $checkedConvert(
      'allergies',
      (v) => (v as List<dynamic>)
          .map((e) => UserAllergyItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    conditions: $checkedConvert(
      'conditions',
      (v) => (v as List<dynamic>)
          .map((e) => UserConditionItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    currentMedicines: $checkedConvert(
      'currentMedicines',
      (v) => (v as List<dynamic>)
          .map(
            (e) =>
                UserCurrentMedicineItemDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$HealthContextDataDtoToJson(
  HealthContextDataDto instance,
) => <String, dynamic>{
  'summary': instance.summary.toJson(),
  'profile': instance.profile.toJson(),
  'allergies': instance.allergies.map((e) => e.toJson()).toList(),
  'conditions': instance.conditions.map((e) => e.toJson()).toList(),
  'currentMedicines': instance.currentMedicines.map((e) => e.toJson()).toList(),
};
