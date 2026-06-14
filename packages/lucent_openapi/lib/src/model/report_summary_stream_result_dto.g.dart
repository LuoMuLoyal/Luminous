// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_summary_stream_result_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportSummaryStreamResultDto _$ReportSummaryStreamResultDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ReportSummaryStreamResultDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['event', 'data']);
  final val = ReportSummaryStreamResultDto(
    event: $checkedConvert(
      'event',
      (v) => $enumDecode(
        _$ReportSummaryStreamResultDtoEventEnumEnumMap,
        v,
        unknownValue:
            ReportSummaryStreamResultDtoEventEnum.unknownDefaultOpenApi,
      ),
    ),
    data: $checkedConvert(
      'data',
      (v) =>
          (v as Map<String, dynamic>).map((k, e) => MapEntry(k, e as Object)),
    ),
  );
  return val;
});

Map<String, dynamic> _$ReportSummaryStreamResultDtoToJson(
  ReportSummaryStreamResultDto instance,
) => <String, dynamic>{
  'event': _$ReportSummaryStreamResultDtoEventEnumEnumMap[instance.event]!,
  'data': instance.data,
};

const _$ReportSummaryStreamResultDtoEventEnumEnumMap = {
  ReportSummaryStreamResultDtoEventEnum.summary: 'summary',
  ReportSummaryStreamResultDtoEventEnum.result: 'result',
  ReportSummaryStreamResultDtoEventEnum.error: 'error',
  ReportSummaryStreamResultDtoEventEnum.done: 'done',
  ReportSummaryStreamResultDtoEventEnum.unknownDefaultOpenApi:
      'unknown_default_open_api',
};
