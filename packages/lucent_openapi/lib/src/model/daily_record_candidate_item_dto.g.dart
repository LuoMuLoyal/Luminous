// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_record_candidate_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyRecordCandidateItemDto _$DailyRecordCandidateItemDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DailyRecordCandidateItemDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['kind', 'occurredAt', 'rationale']);
  final val = DailyRecordCandidateItemDto(
    kind: $checkedConvert(
      'kind',
      (v) => $enumDecode(
        _$DailyRecordCandidateKindEnumMap,
        v,
        unknownValue: DailyRecordCandidateKind.unknownDefaultOpenApi,
      ),
    ),
    occurredAt: $checkedConvert('occurredAt', (v) => v as String),
    title: $checkedConvert('title', (v) => v),
    value: $checkedConvert('value', (v) => v),
    unit: $checkedConvert('unit', (v) => v),
    note: $checkedConvert('note', (v) => v),
    payload: $checkedConvert(
      'payload',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as Object)),
    ),
    rationale: $checkedConvert('rationale', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$DailyRecordCandidateItemDtoToJson(
  DailyRecordCandidateItemDto instance,
) => <String, dynamic>{
  'kind': _$DailyRecordCandidateKindEnumMap[instance.kind]!,
  'occurredAt': instance.occurredAt,
  if (instance.title != null) 'title': instance.title,
  if (instance.value != null) 'value': instance.value,
  if (instance.unit != null) 'unit': instance.unit,
  if (instance.note != null) 'note': instance.note,
  if (instance.payload != null) 'payload': instance.payload,
  'rationale': instance.rationale,
};

const _$DailyRecordCandidateKindEnumMap = {
  DailyRecordCandidateKind.water: 'water',
  DailyRecordCandidateKind.meal: 'meal',
  DailyRecordCandidateKind.symptom: 'symptom',
  DailyRecordCandidateKind.note: 'note',
  DailyRecordCandidateKind.sleep: 'sleep',
  DailyRecordCandidateKind.unknownDefaultOpenApi: 'unknown_default_open_api',
};
