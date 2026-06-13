// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_summary_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportSummaryResponseDto _$ReportSummaryResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ReportSummaryResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
  final val = ReportSummaryResponseDto(
    code: $checkedConvert('code', (v) => v as num),
    message: $checkedConvert('message', (v) => v as String),
    data: $checkedConvert(
      'data',
      (v) => ReportSummaryDataDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ReportSummaryResponseDtoToJson(
  ReportSummaryResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data.toJson(),
};
