// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_record_summary_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyRecordSummaryResponseDto _$DailyRecordSummaryResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DailyRecordSummaryResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
  final val = DailyRecordSummaryResponseDto(
    code: $checkedConvert('code', (v) => v as num),
    message: $checkedConvert('message', (v) => v as String),
    data: $checkedConvert(
      'data',
      (v) => DailyRecordSummaryDataDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$DailyRecordSummaryResponseDtoToJson(
  DailyRecordSummaryResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data.toJson(),
};
