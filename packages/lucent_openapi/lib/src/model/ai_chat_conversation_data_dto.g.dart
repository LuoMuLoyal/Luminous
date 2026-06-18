// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_chat_conversation_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiChatConversationDataDto _$AiChatConversationDataDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AiChatConversationDataDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'title',
      'status',
      'messages',
      'lastMessageAt',
      'createdAt',
      'updatedAt',
    ],
  );
  final val = AiChatConversationDataDto(
    id: $checkedConvert('id', (v) => v as String),
    title: $checkedConvert('title', (v) => v),
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(
        _$AiChatConversationDataDtoStatusEnumEnumMap,
        v,
        unknownValue: AiChatConversationDataDtoStatusEnum.unknownDefaultOpenApi,
      ),
    ),
    messages: $checkedConvert(
      'messages',
      (v) => (v as List<dynamic>)
          .map(
            (e) => AiChatConversationMessageDto.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    ),
    lastMessageAt: $checkedConvert('lastMessageAt', (v) => v),
    createdAt: $checkedConvert('createdAt', (v) => v as String),
    updatedAt: $checkedConvert('updatedAt', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$AiChatConversationDataDtoToJson(
  AiChatConversationDataDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'status': _$AiChatConversationDataDtoStatusEnumEnumMap[instance.status]!,
  'messages': instance.messages.map((e) => e.toJson()).toList(),
  'lastMessageAt': instance.lastMessageAt,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

const _$AiChatConversationDataDtoStatusEnumEnumMap = {
  AiChatConversationDataDtoStatusEnum.active: 'active',
  AiChatConversationDataDtoStatusEnum.archived: 'archived',
  AiChatConversationDataDtoStatusEnum.unknownDefaultOpenApi:
      'unknown_default_open_api',
};
