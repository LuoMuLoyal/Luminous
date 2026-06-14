// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_analysis_stream_result_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodayAnalysisStreamResultDto _$TodayAnalysisStreamResultDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('TodayAnalysisStreamResultDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['event', 'data']);
  final val = TodayAnalysisStreamResultDto(
    event: $checkedConvert(
      'event',
      (v) => $enumDecode(
        _$TodayAnalysisStreamResultDtoEventEnumEnumMap,
        v,
        unknownValue:
            TodayAnalysisStreamResultDtoEventEnum.unknownDefaultOpenApi,
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

Map<String, dynamic> _$TodayAnalysisStreamResultDtoToJson(
  TodayAnalysisStreamResultDto instance,
) => <String, dynamic>{
  'event': _$TodayAnalysisStreamResultDtoEventEnumEnumMap[instance.event]!,
  'data': instance.data,
};

const _$TodayAnalysisStreamResultDtoEventEnumEnumMap = {
  TodayAnalysisStreamResultDtoEventEnum.summary: 'summary',
  TodayAnalysisStreamResultDtoEventEnum.result: 'result',
  TodayAnalysisStreamResultDtoEventEnum.error: 'error',
  TodayAnalysisStreamResultDtoEventEnum.done: 'done',
  TodayAnalysisStreamResultDtoEventEnum.unknownDefaultOpenApi:
      'unknown_default_open_api',
};
