// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_current_medicine_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserCurrentMedicineItemDto _$UserCurrentMedicineItemDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UserCurrentMedicineItemDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'source',
      'sourceRefId',
      'displayName',
      'strengthText',
      'doseText',
      'route',
      'startedAt',
      'endedAt',
      'isCurrent',
      'note',
      'sourcePayload',
      'createdAt',
      'updatedAt',
    ],
  );
  final val = UserCurrentMedicineItemDto(
    id: $checkedConvert('id', (v) => v as String),
    source_: $checkedConvert(
      'source',
      (v) => $enumDecode(
        _$MedicineSourceEnumMap,
        v,
        unknownValue: MedicineSource.unknownDefaultOpenApi,
      ),
    ),
    sourceRefId: $checkedConvert('sourceRefId', (v) => v),
    displayName: $checkedConvert('displayName', (v) => v as String),
    strengthText: $checkedConvert('strengthText', (v) => v),
    doseText: $checkedConvert('doseText', (v) => v),
    route: $checkedConvert('route', (v) => v),
    startedAt: $checkedConvert('startedAt', (v) => v),
    endedAt: $checkedConvert('endedAt', (v) => v),
    isCurrent: $checkedConvert('isCurrent', (v) => v as bool),
    note: $checkedConvert('note', (v) => v),
    sourcePayload: $checkedConvert(
      'sourcePayload',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as Object)),
    ),
    createdAt: $checkedConvert('createdAt', (v) => v as String),
    updatedAt: $checkedConvert('updatedAt', (v) => v as String),
  );
  return val;
}, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$UserCurrentMedicineItemDtoToJson(
  UserCurrentMedicineItemDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'source': _$MedicineSourceEnumMap[instance.source_]!,
  'sourceRefId': instance.sourceRefId,
  'displayName': instance.displayName,
  'strengthText': instance.strengthText,
  'doseText': instance.doseText,
  'route': instance.route,
  'startedAt': instance.startedAt,
  'endedAt': instance.endedAt,
  'isCurrent': instance.isCurrent,
  'note': instance.note,
  'sourcePayload': instance.sourcePayload,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

const _$MedicineSourceEnumMap = {
  MedicineSource.drugbank: 'drugbank',
  MedicineSource.cn: 'cn',
  MedicineSource.manual: 'manual',
  MedicineSource.unknownDefaultOpenApi: 'unknown_default_open_api',
};
