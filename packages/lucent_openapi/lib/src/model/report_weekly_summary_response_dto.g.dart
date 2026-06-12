// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_weekly_summary_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportWeeklySummaryResponseDto _$ReportWeeklySummaryResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ReportWeeklySummaryResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
  final val = ReportWeeklySummaryResponseDto(
    code: $checkedConvert('code', (v) => v as num),
    message: $checkedConvert('message', (v) => v as String),
    data: $checkedConvert(
      'data',
      (v) => ReportWeeklySummaryDataDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ReportWeeklySummaryResponseDtoToJson(
  ReportWeeklySummaryResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data.toJson(),
};
