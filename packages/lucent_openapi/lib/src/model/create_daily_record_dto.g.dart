// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_daily_record_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateDailyRecordDto _$CreateDailyRecordDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreateDailyRecordDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['kind', 'occurredAt']);
  final val = CreateDailyRecordDto(
    kind: $checkedConvert(
      'kind',
      (v) => $enumDecode(
        _$DailyRecordKindEnumMap,
        v,
        unknownValue: DailyRecordKind.unknownDefaultOpenApi,
      ),
    ),
    occurredAt: $checkedConvert('occurredAt', (v) => v as String),
    title: $checkedConvert('title', (v) => v as String?),
    value: $checkedConvert('value', (v) => v as String?),
    unit: $checkedConvert('unit', (v) => v as String?),
    note: $checkedConvert('note', (v) => v as String?),
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

Map<String, dynamic> _$CreateDailyRecordDtoToJson(
  CreateDailyRecordDto instance,
) => <String, dynamic>{
  'kind': _$DailyRecordKindEnumMap[instance.kind]!,
  'occurredAt': instance.occurredAt,
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
