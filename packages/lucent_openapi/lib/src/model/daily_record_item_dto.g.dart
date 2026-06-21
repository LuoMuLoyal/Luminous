// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_record_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyRecordItemDto _$DailyRecordItemDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DailyRecordItemDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'kind',
          'occurredAt',
          'attachments',
          'createdAt',
          'updatedAt',
        ],
      );
      final val = DailyRecordItemDto(
        id: $checkedConvert('id', (v) => v as String),
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(
            _$DailyRecordKindEnumMap,
            v,
            unknownValue: DailyRecordKind.unknownDefaultOpenApi,
          ),
        ),
        occurredAt: $checkedConvert('occurredAt', (v) => v as String),
        occurredTime: $checkedConvert('occurredTime', (v) => v),
        title: $checkedConvert('title', (v) => v),
        value: $checkedConvert('value', (v) => v),
        unit: $checkedConvert('unit', (v) => v),
        note: $checkedConvert('note', (v) => v),
        source_: $checkedConvert('source', (v) => v),
        payload: $checkedConvert('payload', (v) => v),
        attachments: $checkedConvert(
          'attachments',
          (v) => (v as List<dynamic>)
              .map(
                (e) => DailyRecordAttachmentDto.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList(),
        ),
        createdAt: $checkedConvert('createdAt', (v) => v as String),
        updatedAt: $checkedConvert('updatedAt', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$DailyRecordItemDtoToJson(DailyRecordItemDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': _$DailyRecordKindEnumMap[instance.kind]!,
      'occurredAt': instance.occurredAt,
      if (instance.occurredTime != null) 'occurredTime': instance.occurredTime,
      if (instance.title != null) 'title': instance.title,
      if (instance.value != null) 'value': instance.value,
      if (instance.unit != null) 'unit': instance.unit,
      if (instance.note != null) 'note': instance.note,
      if (instance.source_ != null) 'source': instance.source_,
      if (instance.payload != null) 'payload': instance.payload,
      'attachments': instance.attachments.map((e) => e.toJson()).toList(),
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
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
