// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_record_summary_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyRecordSummaryDataDto _$DailyRecordSummaryDataDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DailyRecordSummaryDataDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['summaries']);
  final val = DailyRecordSummaryDataDto(
    summaries: $checkedConvert(
      'summaries',
      (v) => (v as List<dynamic>)
          .map((e) => DailyRecordSummaryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$DailyRecordSummaryDataDtoToJson(
  DailyRecordSummaryDataDto instance,
) => <String, dynamic>{
  'summaries': instance.summaries.map((e) => e.toJson()).toList(),
};
