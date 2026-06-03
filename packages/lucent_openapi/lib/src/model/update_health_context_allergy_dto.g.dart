// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_health_context_allergy_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateHealthContextAllergyDto _$UpdateHealthContextAllergyDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UpdateHealthContextAllergyDto', json, ($checkedConvert) {
  final val = UpdateHealthContextAllergyDto(
    kind: $checkedConvert(
      'kind',
      (v) => $enumDecodeNullable(
        _$UserAllergyKindEnumMap,
        v,
        unknownValue: UserAllergyKind.unknownDefaultOpenApi,
      ),
    ),
    label: $checkedConvert('label', (v) => v as String?),
    reaction: $checkedConvert('reaction', (v) => v),
    severity: $checkedConvert(
      'severity',
      (v) => $enumDecodeNullable(
        _$UserAllergySeverityEnumMap,
        v,
        unknownValue: UserAllergySeverity.unknownDefaultOpenApi,
      ),
    ),
    note: $checkedConvert('note', (v) => v),
    recordedAt: $checkedConvert('recordedAt', (v) => v),
    isActive: $checkedConvert('isActive', (v) => v as bool?),
  );
  return val;
});

Map<String, dynamic> _$UpdateHealthContextAllergyDtoToJson(
  UpdateHealthContextAllergyDto instance,
) => <String, dynamic>{
  if (_$UserAllergyKindEnumMap[instance.kind] != null)
    'kind': _$UserAllergyKindEnumMap[instance.kind],
  if (instance.label != null) 'label': instance.label,
  if (instance.reaction != null) 'reaction': instance.reaction,
  if (_$UserAllergySeverityEnumMap[instance.severity] != null)
    'severity': _$UserAllergySeverityEnumMap[instance.severity],
  if (instance.note != null) 'note': instance.note,
  if (instance.recordedAt != null) 'recordedAt': instance.recordedAt,
  if (instance.isActive != null) 'isActive': instance.isActive,
};

const _$UserAllergyKindEnumMap = {
  UserAllergyKind.drug: 'drug',
  UserAllergyKind.food: 'food',
  UserAllergyKind.environment: 'environment',
  UserAllergyKind.other: 'other',
  UserAllergyKind.unknownDefaultOpenApi: 'unknown_default_open_api',
};

const _$UserAllergySeverityEnumMap = {
  UserAllergySeverity.mild: 'mild',
  UserAllergySeverity.moderate: 'moderate',
  UserAllergySeverity.severe: 'severe',
  UserAllergySeverity.unknown: 'unknown',
  UserAllergySeverity.unknownDefaultOpenApi: 'unknown_default_open_api',
};
