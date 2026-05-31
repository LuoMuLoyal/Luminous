// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_health_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserHealthSummaryDto _$UserHealthSummaryDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UserHealthSummaryDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'age',
      'onboardingCompleted',
      'activeAllergyCount',
      'conditionCount',
      'currentMedicineCount',
      'missingCoreProfileFields',
    ],
  );
  final val = UserHealthSummaryDto(
    age: $checkedConvert('age', (v) => v),
    onboardingCompleted: $checkedConvert(
      'onboardingCompleted',
      (v) => v as bool,
    ),
    activeAllergyCount: $checkedConvert('activeAllergyCount', (v) => v as num),
    conditionCount: $checkedConvert('conditionCount', (v) => v as num),
    currentMedicineCount: $checkedConvert(
      'currentMedicineCount',
      (v) => v as num,
    ),
    missingCoreProfileFields: $checkedConvert(
      'missingCoreProfileFields',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$UserHealthSummaryDtoToJson(
  UserHealthSummaryDto instance,
) => <String, dynamic>{
  'age': instance.age,
  'onboardingCompleted': instance.onboardingCompleted,
  'activeAllergyCount': instance.activeAllergyCount,
  'conditionCount': instance.conditionCount,
  'currentMedicineCount': instance.currentMedicineCount,
  'missingCoreProfileFields': instance.missingCoreProfileFields,
};
