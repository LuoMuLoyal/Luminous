// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_current_medicine_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateCurrentMedicineDto _$CreateCurrentMedicineDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreateCurrentMedicineDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['source', 'displayName']);
  final val = CreateCurrentMedicineDto(
    source_: $checkedConvert(
      'source',
      (v) => $enumDecode(
        _$MedicineSourceEnumMap,
        v,
        unknownValue: MedicineSource.unknownDefaultOpenApi,
      ),
    ),
    sourceRefId: $checkedConvert('sourceRefId', (v) => v as String?),
    displayName: $checkedConvert('displayName', (v) => v as String),
    strengthText: $checkedConvert('strengthText', (v) => v as String?),
    doseText: $checkedConvert('doseText', (v) => v as String?),
    route: $checkedConvert('route', (v) => v as String?),
    startedAt: $checkedConvert('startedAt', (v) => v),
    endedAt: $checkedConvert('endedAt', (v) => v),
    note: $checkedConvert('note', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$CreateCurrentMedicineDtoToJson(
  CreateCurrentMedicineDto instance,
) => <String, dynamic>{
  'source': _$MedicineSourceEnumMap[instance.source_]!,
  if (instance.sourceRefId != null) 'sourceRefId': instance.sourceRefId,
  'displayName': instance.displayName,
  if (instance.strengthText != null) 'strengthText': instance.strengthText,
  if (instance.doseText != null) 'doseText': instance.doseText,
  if (instance.route != null) 'route': instance.route,
  if (instance.startedAt != null) 'startedAt': instance.startedAt,
  if (instance.endedAt != null) 'endedAt': instance.endedAt,
  if (instance.note != null) 'note': instance.note,
};

const _$MedicineSourceEnumMap = {
  MedicineSource.drugbank: 'drugbank',
  MedicineSource.cn: 'cn',
  MedicineSource.manual: 'manual',
  MedicineSource.unknownDefaultOpenApi: 'unknown_default_open_api',
};
