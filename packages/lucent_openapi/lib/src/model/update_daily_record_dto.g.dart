// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_daily_record_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateDailyRecordDto _$UpdateDailyRecordDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UpdateDailyRecordDto', json, ($checkedConvert) {
  final val = UpdateDailyRecordDto(
    kind: $checkedConvert(
      'kind',
      (v) => $enumDecodeNullable(
        _$DailyRecordKindEnumMap,
        v,
        unknownValue: DailyRecordKind.unknownDefaultOpenApi,
      ),
    ),
    occurredAt: $checkedConvert('occurredAt', (v) => v as String?),
    occurredTime: $checkedConvert('occurredTime', (v) => v),
    title: $checkedConvert('title', (v) => v),
    value: $checkedConvert('value', (v) => v),
    unit: $checkedConvert('unit', (v) => v),
    note: $checkedConvert('note', (v) => v),
    payload: $checkedConvert('payload', (v) => v),
    attachments: $checkedConvert(
      'attachments',
      (v) => (v as List<dynamic>?)
          ?.map(
            (e) => DailyRecordAttachmentInputDto.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$UpdateDailyRecordDtoToJson(
  UpdateDailyRecordDto instance,
) => <String, dynamic>{
  if (_$DailyRecordKindEnumMap[instance.kind] != null)
    'kind': _$DailyRecordKindEnumMap[instance.kind],
  if (instance.occurredAt != null) 'occurredAt': instance.occurredAt,
  if (instance.occurredTime != null) 'occurredTime': instance.occurredTime,
  if (instance.title != null) 'title': instance.title,
  if (instance.value != null) 'value': instance.value,
  if (instance.unit != null) 'unit': instance.unit,
  if (instance.note != null) 'note': instance.note,
  if (instance.payload != null) 'payload': instance.payload,
  if (instance.attachments?.map((e) => e.toJson()).toList() != null)
    'attachments': instance.attachments?.map((e) => e.toJson()).toList(),
};

const _$DailyRecordKindEnumMap = {
  DailyRecordKind.water: 'water',
  DailyRecordKind.meal: 'meal',
  DailyRecordKind.vital: 'vital',
  DailyRecordKind.mood: 'mood',
  DailyRecordKind.symptom: 'symptom',
  DailyRecordKind.activity: 'activity',
  DailyRecordKind.note: 'note',
  DailyRecordKind.sleep: 'sleep',
  DailyRecordKind.unknownDefaultOpenApi: 'unknown_default_open_api',
};
