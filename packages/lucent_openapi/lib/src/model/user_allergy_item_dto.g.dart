// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_allergy_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserAllergyItemDto _$UserAllergyItemDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UserAllergyItemDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'kind',
          'label',
          'reaction',
          'severity',
          'isActive',
          'note',
          'extras',
          'recordedAt',
          'createdAt',
          'updatedAt',
        ],
      );
      final val = UserAllergyItemDto(
        id: $checkedConvert('id', (v) => v as String),
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(
            _$UserAllergyKindEnumMap,
            v,
            unknownValue: UserAllergyKind.unknownDefaultOpenApi,
          ),
        ),
        label: $checkedConvert('label', (v) => v as String),
        reaction: $checkedConvert('reaction', (v) => v),
        severity: $checkedConvert(
          'severity',
          (v) => $enumDecodeNullable(
            _$UserAllergySeverityEnumMap,
            v,
            unknownValue: UserAllergySeverity.unknownDefaultOpenApi,
          ),
        ),
        isActive: $checkedConvert('isActive', (v) => v as bool),
        note: $checkedConvert('note', (v) => v),
        extras: $checkedConvert(
          'extras',
          (v) => (v as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as Object),
          ),
        ),
        recordedAt: $checkedConvert('recordedAt', (v) => v),
        createdAt: $checkedConvert('createdAt', (v) => v as String),
        updatedAt: $checkedConvert('updatedAt', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$UserAllergyItemDtoToJson(UserAllergyItemDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': _$UserAllergyKindEnumMap[instance.kind]!,
      'label': instance.label,
      'reaction': instance.reaction,
      'severity': _$UserAllergySeverityEnumMap[instance.severity],
      'isActive': instance.isActive,
      'note': instance.note,
      'extras': instance.extras,
      'recordedAt': instance.recordedAt,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
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
