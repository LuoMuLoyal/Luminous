// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_dose_log_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateDoseLogDto _$UpdateDoseLogDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UpdateDoseLogDto', json, ($checkedConvert) {
      final val = UpdateDoseLogDto(
        status: $checkedConvert(
          'status',
          (v) => $enumDecodeNullable(
            _$DoseLogStatusEnumMap,
            v,
            unknownValue: DoseLogStatus.unknownDefaultOpenApi,
          ),
        ),
        doseText: $checkedConvert('doseText', (v) => v),
        note: $checkedConvert('note', (v) => v),
      );
      return val;
    });

Map<String, dynamic> _$UpdateDoseLogDtoToJson(UpdateDoseLogDto instance) =>
    <String, dynamic>{
      if (_$DoseLogStatusEnumMap[instance.status] != null)
        'status': _$DoseLogStatusEnumMap[instance.status],
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
