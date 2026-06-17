// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_chat_stream_result_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiChatStreamResultDto _$AiChatStreamResultDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AiChatStreamResultDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['event', 'data']);
  final val = AiChatStreamResultDto(
    event: $checkedConvert(
      'event',
      (v) => $enumDecode(
        _$AiChatStreamResultDtoEventEnumEnumMap,
        v,
        unknownValue: AiChatStreamResultDtoEventEnum.unknownDefaultOpenApi,
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

Map<String, dynamic> _$AiChatStreamResultDtoToJson(
  AiChatStreamResultDto instance,
) => <String, dynamic>{
  'event': _$AiChatStreamResultDtoEventEnumEnumMap[instance.event]!,
  'data': instance.data,
};

const _$AiChatStreamResultDtoEventEnumEnumMap = {
  AiChatStreamResultDtoEventEnum.chunk: 'chunk',
  AiChatStreamResultDtoEventEnum.result: 'result',
  AiChatStreamResultDtoEventEnum.error: 'error',
  AiChatStreamResultDtoEventEnum.done: 'done',
  AiChatStreamResultDtoEventEnum.unknownDefaultOpenApi:
      'unknown_default_open_api',
};
