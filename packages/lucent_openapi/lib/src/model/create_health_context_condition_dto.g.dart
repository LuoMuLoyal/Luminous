// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_health_context_condition_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateHealthContextConditionDto _$CreateHealthContextConditionDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreateHealthContextConditionDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['label']);
  final val = CreateHealthContextConditionDto(
    label: $checkedConvert('label', (v) => v as String),
    status: $checkedConvert(
      'status',
      (v) => $enumDecodeNullable(
        _$UserConditionStatusEnumMap,
        v,
        unknownValue: UserConditionStatus.unknownDefaultOpenApi,
      ),
    ),
    diagnosedAt: $checkedConvert('diagnosedAt', (v) => v),
    note: $checkedConvert('note', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$CreateHealthContextConditionDtoToJson(
  CreateHealthContextConditionDto instance,
) => <String, dynamic>{
  'label': instance.label,
  if (_$UserConditionStatusEnumMap[instance.status] != null)
    'status': _$UserConditionStatusEnumMap[instance.status],
  if (instance.diagnosedAt != null) 'diagnosedAt': instance.diagnosedAt,
  if (instance.note != null) 'note': instance.note,
};

const _$UserConditionStatusEnumMap = {
  UserConditionStatus.active: 'active',
  UserConditionStatus.resolved: 'resolved',
  UserConditionStatus.suspected: 'suspected',
  UserConditionStatus.unknownDefaultOpenApi: 'unknown_default_open_api',
};
