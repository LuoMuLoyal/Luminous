// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_conversation_message_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantConversationMessageDto _$AssistantConversationMessageDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AssistantConversationMessageDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['role', 'content', 'usedTools', 'createdAt'],
  );
  final val = AssistantConversationMessageDto(
    role: $checkedConvert(
      'role',
      (v) => $enumDecode(
        _$AssistantConversationMessageDtoRoleEnumEnumMap,
        v,
        unknownValue:
            AssistantConversationMessageDtoRoleEnum.unknownDefaultOpenApi,
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

Map<String, dynamic> _$AssistantConversationMessageDtoToJson(
  AssistantConversationMessageDto instance,
) => <String, dynamic>{
  'role': _$AssistantConversationMessageDtoRoleEnumEnumMap[instance.role]!,
  'content': instance.content,
  'usedTools': instance.usedTools,
  'createdAt': instance.createdAt,
};

const _$AssistantConversationMessageDtoRoleEnumEnumMap = {
  AssistantConversationMessageDtoRoleEnum.user: 'user',
  AssistantConversationMessageDtoRoleEnum.assistant: 'assistant',
  AssistantConversationMessageDtoRoleEnum.unknownDefaultOpenApi:
      'unknown_default_open_api',
};
