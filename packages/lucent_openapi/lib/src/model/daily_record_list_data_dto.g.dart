// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_record_list_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyRecordListDataDto _$DailyRecordListDataDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DailyRecordListDataDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['items', 'total']);
  final val = DailyRecordListDataDto(
    items: $checkedConvert(
      'items',
      (v) => (v as List<dynamic>)
          .map((e) => DailyRecordItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    total: $checkedConvert('total', (v) => v as num),
  );
  return val;
});

Map<String, dynamic> _$DailyRecordListDataDtoToJson(
  DailyRecordListDataDto instance,
) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'total': instance.total,
};
