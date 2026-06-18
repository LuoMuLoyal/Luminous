// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_chat_conversation_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiChatConversationSummaryDto _$AiChatConversationSummaryDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AiChatConversationSummaryDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'title',
      'status',
      'lastMessageAt',
      'createdAt',
      'updatedAt',
    ],
  );
  final val = AiChatConversationSummaryDto(
    id: $checkedConvert('id', (v) => v as String),
    title: $checkedConvert('title', (v) => v),
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(
        _$AiChatConversationSummaryDtoStatusEnumEnumMap,
        v,
        unknownValue:
            AiChatConversationSummaryDtoStatusEnum.unknownDefaultOpenApi,
      ),
    ),
    lastMessageAt: $checkedConvert('lastMessageAt', (v) => v),
    createdAt: $checkedConvert('createdAt', (v) => v as String),
    updatedAt: $checkedConvert('updatedAt', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$AiChatConversationSummaryDtoToJson(
  AiChatConversationSummaryDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'status': _$AiChatConversationSummaryDtoStatusEnumEnumMap[instance.status]!,
  'lastMessageAt': instance.lastMessageAt,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

const _$AiChatConversationSummaryDtoStatusEnumEnumMap = {
  AiChatConversationSummaryDtoStatusEnum.active: 'active',
  AiChatConversationSummaryDtoStatusEnum.archived: 'archived',
  AiChatConversationSummaryDtoStatusEnum.unknownDefaultOpenApi:
      'unknown_default_open_api',
};
