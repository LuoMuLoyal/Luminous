// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_chat_conversation_message_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiChatConversationMessageDto _$AiChatConversationMessageDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AiChatConversationMessageDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['role', 'content', 'usedTools', 'createdAt'],
  );
  final val = AiChatConversationMessageDto(
    role: $checkedConvert(
      'role',
      (v) => $enumDecode(
        _$AiChatConversationMessageDtoRoleEnumEnumMap,
        v,
        unknownValue:
            AiChatConversationMessageDtoRoleEnum.unknownDefaultOpenApi,
      ),
    ),
    content: $checkedConvert('content', (v) => v as String),
    usedTools: $checkedConvert(
      'usedTools',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    createdAt: $checkedConvert('createdAt', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$AiChatConversationMessageDtoToJson(
  AiChatConversationMessageDto instance,
) => <String, dynamic>{
  'role': _$AiChatConversationMessageDtoRoleEnumEnumMap[instance.role]!,
  'content': instance.content,
  'usedTools': instance.usedTools,
  'createdAt': instance.createdAt,
};

const _$AiChatConversationMessageDtoRoleEnumEnumMap = {
  AiChatConversationMessageDtoRoleEnum.user: 'user',
  AiChatConversationMessageDtoRoleEnum.assistant: 'assistant',
  AiChatConversationMessageDtoRoleEnum.unknownDefaultOpenApi:
      'unknown_default_open_api',
};
