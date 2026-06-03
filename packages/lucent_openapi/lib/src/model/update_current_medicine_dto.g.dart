// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_current_medicine_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateCurrentMedicineDto _$UpdateCurrentMedicineDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UpdateCurrentMedicineDto', json, ($checkedConvert) {
  final val = UpdateCurrentMedicineDto(
    source_: $checkedConvert(
      'source',
      (v) => $enumDecodeNullable(
        _$MedicineSourceEnumMap,
        v,
        unknownValue: MedicineSource.unknownDefaultOpenApi,
      ),
    ),
    sourceRefId: $checkedConvert('sourceRefId', (v) => v),
    displayName: $checkedConvert('displayName', (v) => v as String?),
    strengthText: $checkedConvert('strengthText', (v) => v),
    doseText: $checkedConvert('doseText', (v) => v),
    route: $checkedConvert('route', (v) => v),
    startedAt: $checkedConvert('startedAt', (v) => v),
    endedAt: $checkedConvert('endedAt', (v) => v),
    note: $checkedConvert('note', (v) => v),
    isCurrent: $checkedConvert('isCurrent', (v) => v as bool?),
  );
  return val;
}, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$UpdateCurrentMedicineDtoToJson(
  UpdateCurrentMedicineDto instance,
) => <String, dynamic>{
  if (_$MedicineSourceEnumMap[instance.source_] != null)
    'source': _$MedicineSourceEnumMap[instance.source_],
  if (instance.sourceRefId != null) 'sourceRefId': instance.sourceRefId,
  if (instance.displayName != null) 'displayName': instance.displayName,
  if (instance.strengthText != null) 'strengthText': instance.strengthText,
  if (instance.doseText != null) 'doseText': instance.doseText,
  if (instance.route != null) 'route': instance.route,
  if (instance.startedAt != null) 'startedAt': instance.startedAt,
  if (instance.endedAt != null) 'endedAt': instance.endedAt,
  if (instance.note != null) 'note': instance.note,
  if (instance.isCurrent != null) 'isCurrent': instance.isCurrent,
};

const _$MedicineSourceEnumMap = {
  MedicineSource.drugbank: 'drugbank',
  MedicineSource.cn: 'cn',
  MedicineSource.manual: 'manual',
  MedicineSource.unknownDefaultOpenApi: 'unknown_default_open_api',
};
