// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_condition_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserConditionItemDto _$UserConditionItemDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UserConditionItemDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'label',
      'status',
      'diagnosedAt',
      'resolvedAt',
      'note',
      'extras',
      'createdAt',
      'updatedAt',
    ],
  );
  final val = UserConditionItemDto(
    id: $checkedConvert('id', (v) => v as String),
    label: $checkedConvert('label', (v) => v as String),
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(
        _$UserConditionStatusEnumMap,
        v,
        unknownValue: UserConditionStatus.unknownDefaultOpenApi,
      ),
    ),
    diagnosedAt: $checkedConvert('diagnosedAt', (v) => v),
    resolvedAt: $checkedConvert('resolvedAt', (v) => v),
    note: $checkedConvert('note', (v) => v),
    extras: $checkedConvert(
      'extras',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as Object)),
    ),
    createdAt: $checkedConvert('createdAt', (v) => v as String),
    updatedAt: $checkedConvert('updatedAt', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$UserConditionItemDtoToJson(
  UserConditionItemDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'status': _$UserConditionStatusEnumMap[instance.status]!,
  'diagnosedAt': instance.diagnosedAt,
  'resolvedAt': instance.resolvedAt,
  'note': instance.note,
  'extras': instance.extras,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

const _$UserConditionStatusEnumMap = {
  UserConditionStatus.active: 'active',
  UserConditionStatus.resolved: 'resolved',
  UserConditionStatus.suspected: 'suspected',
  UserConditionStatus.unknownDefaultOpenApi: 'unknown_default_open_api',
};
