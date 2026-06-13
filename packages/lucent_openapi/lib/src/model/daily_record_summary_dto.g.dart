// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_record_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyRecordSummaryDto _$DailyRecordSummaryDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DailyRecordSummaryDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['kind', 'count']);
  final val = DailyRecordSummaryDto(
    kind: $checkedConvert(
      'kind',
      (v) => $enumDecode(
        _$DailyRecordKindEnumMap,
        v,
        unknownValue: DailyRecordKind.unknownDefaultOpenApi,
      ),
    ),
    count: $checkedConvert('count', (v) => v as num),
    latest: $checkedConvert(
      'latest',
      (v) => v == null
          ? null
          : DailyRecordItemDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$DailyRecordSummaryDtoToJson(
  DailyRecordSummaryDto instance,
) => <String, dynamic>{
  'kind': _$DailyRecordKindEnumMap[instance.kind]!,
  'count': instance.count,
  if (instance.latest?.toJson() != null) 'latest': instance.latest?.toJson(),
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
