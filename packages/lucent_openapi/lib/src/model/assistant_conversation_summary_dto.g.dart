// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_conversation_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantConversationSummaryDto _$AssistantConversationSummaryDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AssistantConversationSummaryDto', json, ($checkedConvert) {
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
  final val = AssistantConversationSummaryDto(
    id: $checkedConvert('id', (v) => v as String),
    title: $checkedConvert('title', (v) => v),
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(
        _$AssistantConversationSummaryDtoStatusEnumEnumMap,
        v,
        unknownValue:
            AssistantConversationSummaryDtoStatusEnum.unknownDefaultOpenApi,
      ),
    ),
    lastMessageAt: $checkedConvert('lastMessageAt', (v) => v),
    createdAt: $checkedConvert('createdAt', (v) => v as String),
    updatedAt: $checkedConvert('updatedAt', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$AssistantConversationSummaryDtoToJson(
  AssistantConversationSummaryDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'status':
      _$AssistantConversationSummaryDtoStatusEnumEnumMap[instance.status]!,
  'lastMessageAt': instance.lastMessageAt,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

const _$AssistantConversationSummaryDtoStatusEnumEnumMap = {
  AssistantConversationSummaryDtoStatusEnum.active: 'active',
  AssistantConversationSummaryDtoStatusEnum.archived: 'archived',
  AssistantConversationSummaryDtoStatusEnum.unknownDefaultOpenApi:
      'unknown_default_open_api',
};
