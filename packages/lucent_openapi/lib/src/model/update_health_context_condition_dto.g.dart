// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_health_context_condition_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateHealthContextConditionDto _$UpdateHealthContextConditionDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UpdateHealthContextConditionDto', json, ($checkedConvert) {
  final val = UpdateHealthContextConditionDto(
    label: $checkedConvert('label', (v) => v as String?),
    status: $checkedConvert(
      'status',
      (v) => $enumDecodeNullable(
        _$UserConditionStatusEnumMap,
        v,
        unknownValue: UserConditionStatus.unknownDefaultOpenApi,
      ),
    ),
    diagnosedAt: $checkedConvert('diagnosedAt', (v) => v),
    note: $checkedConvert('note', (v) => v),
  );
  return val;
});

Map<String, dynamic> _$UpdateHealthContextConditionDtoToJson(
  UpdateHealthContextConditionDto instance,
) => <String, dynamic>{
  if (instance.label != null) 'label': instance.label,
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
