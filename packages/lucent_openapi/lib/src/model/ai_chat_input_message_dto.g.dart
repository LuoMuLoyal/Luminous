// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_chat_input_message_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiChatInputMessageDto _$AiChatInputMessageDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AiChatInputMessageDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['role', 'content']);
  final val = AiChatInputMessageDto(
    role: $checkedConvert(
      'role',
      (v) => $enumDecode(
        _$AiChatInputMessageDtoRoleEnumEnumMap,
        v,
        unknownValue: AiChatInputMessageDtoRoleEnum.unknownDefaultOpenApi,
      ),
    ),
    content: $checkedConvert('content', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$AiChatInputMessageDtoToJson(
  AiChatInputMessageDto instance,
) => <String, dynamic>{
  'role': _$AiChatInputMessageDtoRoleEnumEnumMap[instance.role]!,
  'content': instance.content,
};

const _$AiChatInputMessageDtoRoleEnumEnumMap = {
  AiChatInputMessageDtoRoleEnum.user: 'user',
  AiChatInputMessageDtoRoleEnum.assistant: 'assistant',
  AiChatInputMessageDtoRoleEnum.unknownDefaultOpenApi:
      'unknown_default_open_api',
};
