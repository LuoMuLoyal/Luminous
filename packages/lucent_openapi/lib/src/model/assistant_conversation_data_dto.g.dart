// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_conversation_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantConversationDataDto _$AssistantConversationDataDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AssistantConversationDataDto', json, ($checkedConvert) {
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
  final val = AssistantConversationDataDto(
    id: $checkedConvert('id', (v) => v as String),
    title: $checkedConvert('title', (v) => v),
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(
        _$AssistantConversationDataDtoStatusEnumEnumMap,
        v,
        unknownValue:
            AssistantConversationDataDtoStatusEnum.unknownDefaultOpenApi,
      ),
    ),
    messages: $checkedConvert(
      'messages',
      (v) => (v as List<dynamic>)
          .map(
            (e) => AssistantConversationMessageDto.fromJson(
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

Map<String, dynamic> _$AssistantConversationDataDtoToJson(
  AssistantConversationDataDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'status': _$AssistantConversationDataDtoStatusEnumEnumMap[instance.status]!,
  'messages': instance.messages.map((e) => e.toJson()).toList(),
  'lastMessageAt': instance.lastMessageAt,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

const _$AssistantConversationDataDtoStatusEnumEnumMap = {
  AssistantConversationDataDtoStatusEnum.active: 'active',
  AssistantConversationDataDtoStatusEnum.archived: 'archived',
  AssistantConversationDataDtoStatusEnum.unknownDefaultOpenApi:
      'unknown_default_open_api',
};
