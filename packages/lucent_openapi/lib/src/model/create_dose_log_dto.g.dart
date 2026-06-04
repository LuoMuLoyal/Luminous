// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_dose_log_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateDoseLogDto _$CreateDoseLogDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CreateDoseLogDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['status', 'scheduledFor']);
      final val = CreateDoseLogDto(
        currentMedicineId: $checkedConvert(
          'currentMedicineId',
          (v) => v as String?,
        ),
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(
            _$DoseLogStatusEnumMap,
            v,
            unknownValue: DoseLogStatus.unknownDefaultOpenApi,
          ),
        ),
        scheduledFor: $checkedConvert('scheduledFor', (v) => v as String),
        doseText: $checkedConvert('doseText', (v) => v as String?),
        note: $checkedConvert('note', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$CreateDoseLogDtoToJson(CreateDoseLogDto instance) =>
    <String, dynamic>{
      if (instance.currentMedicineId != null)
        'currentMedicineId': instance.currentMedicineId,
      'status': _$DoseLogStatusEnumMap[instance.status]!,
      'scheduledFor': instance.scheduledFor,
      if (instance.doseText != null) 'doseText': instance.doseText,
      if (instance.note != null) 'note': instance.note,
    };

const _$DoseLogStatusEnumMap = {
  DoseLogStatus.taken: 'taken',
  DoseLogStatus.skipped: 'skipped',
  DoseLogStatus.missed: 'missed',
  DoseLogStatus.planned: 'planned',
  DoseLogStatus.unknownDefaultOpenApi: 'unknown_default_open_api',
};
