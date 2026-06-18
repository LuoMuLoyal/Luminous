// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_stream_result_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantStreamResultDto _$AssistantStreamResultDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AssistantStreamResultDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['event', 'data']);
  final val = AssistantStreamResultDto(
    event: $checkedConvert(
      'event',
      (v) => $enumDecode(
        _$AssistantStreamResultDtoEventEnumEnumMap,
        v,
        unknownValue: AssistantStreamResultDtoEventEnum.unknownDefaultOpenApi,
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

Map<String, dynamic> _$AssistantStreamResultDtoToJson(
  AssistantStreamResultDto instance,
) => <String, dynamic>{
  'event': _$AssistantStreamResultDtoEventEnumEnumMap[instance.event]!,
  'data': instance.data,
};

const _$AssistantStreamResultDtoEventEnumEnumMap = {
  AssistantStreamResultDtoEventEnum.chunk: 'chunk',
  AssistantStreamResultDtoEventEnum.result: 'result',
  AssistantStreamResultDtoEventEnum.error: 'error',
  AssistantStreamResultDtoEventEnum.done: 'done',
  AssistantStreamResultDtoEventEnum.unknownDefaultOpenApi:
      'unknown_default_open_api',
};
