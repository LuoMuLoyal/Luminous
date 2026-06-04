// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dose_log_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DoseLogItemDto _$DoseLogItemDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DoseLogItemDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'status',
          'scheduledFor',
          'createdAt',
          'updatedAt',
        ],
      );
      final val = DoseLogItemDto(
        id: $checkedConvert('id', (v) => v as String),
        currentMedicineId: $checkedConvert('currentMedicineId', (v) => v),
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(
            _$DoseLogStatusEnumMap,
            v,
            unknownValue: DoseLogStatus.unknownDefaultOpenApi,
          ),
        ),
        scheduledFor: $checkedConvert('scheduledFor', (v) => v as String),
        doseText: $checkedConvert('doseText', (v) => v),
        note: $checkedConvert('note', (v) => v),
        source_: $checkedConvert('source', (v) => v),
        createdAt: $checkedConvert('createdAt', (v) => v as String),
        updatedAt: $checkedConvert('updatedAt', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$DoseLogItemDtoToJson(DoseLogItemDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      if (instance.currentMedicineId != null)
        'currentMedicineId': instance.currentMedicineId,
      'status': _$DoseLogStatusEnumMap[instance.status]!,
      'scheduledFor': instance.scheduledFor,
      if (instance.doseText != null) 'doseText': instance.doseText,
      if (instance.note != null) 'note': instance.note,
      if (instance.source_ != null) 'source': instance.source_,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

const _$DoseLogStatusEnumMap = {
  DoseLogStatus.taken: 'taken',
  DoseLogStatus.skipped: 'skipped',
  DoseLogStatus.missed: 'missed',
  DoseLogStatus.planned: 'planned',
  DoseLogStatus.unknownDefaultOpenApi: 'unknown_default_open_api',
};
