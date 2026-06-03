// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_health_context_allergy_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateHealthContextAllergyDto _$CreateHealthContextAllergyDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreateHealthContextAllergyDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['kind', 'label']);
  final val = CreateHealthContextAllergyDto(
    kind: $checkedConvert(
      'kind',
      (v) => $enumDecode(
        _$UserAllergyKindEnumMap,
        v,
        unknownValue: UserAllergyKind.unknownDefaultOpenApi,
      ),
    ),
    label: $checkedConvert('label', (v) => v as String),
    reaction: $checkedConvert('reaction', (v) => v as String?),
    severity: $checkedConvert(
      'severity',
      (v) => $enumDecodeNullable(
        _$UserAllergySeverityEnumMap,
        v,
        unknownValue: UserAllergySeverity.unknownDefaultOpenApi,
      ),
    ),
    note: $checkedConvert('note', (v) => v as String?),
    recordedAt: $checkedConvert('recordedAt', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$CreateHealthContextAllergyDtoToJson(
  CreateHealthContextAllergyDto instance,
) => <String, dynamic>{
  'kind': _$UserAllergyKindEnumMap[instance.kind]!,
  'label': instance.label,
  if (instance.reaction != null) 'reaction': instance.reaction,
  if (_$UserAllergySeverityEnumMap[instance.severity] != null)
    'severity': _$UserAllergySeverityEnumMap[instance.severity],
  if (instance.note != null) 'note': instance.note,
  if (instance.recordedAt != null) 'recordedAt': instance.recordedAt,
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
