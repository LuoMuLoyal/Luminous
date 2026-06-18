// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_chat_controller_clear_latest_conversation_v1200_response_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiChatControllerClearLatestConversationV1200ResponseData
_$AiChatControllerClearLatestConversationV1200ResponseDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'AiChatControllerClearLatestConversationV1200ResponseData',
  json,
  ($checkedConvert) {
    final val = AiChatControllerClearLatestConversationV1200ResponseData(
      cleared: $checkedConvert('cleared', (v) => v as bool?),
      archivedConversationId: $checkedConvert(
        'archivedConversationId',
        (v) => v as String?,
      ),
    );
    return val;
  },
);

Map<String, dynamic>
_$AiChatControllerClearLatestConversationV1200ResponseDataToJson(
  AiChatControllerClearLatestConversationV1200ResponseData instance,
) => <String, dynamic>{
  if (instance.cleared != null) 'cleared': instance.cleared,
  if (instance.archivedConversationId != null)
    'archivedConversationId': instance.archivedConversationId,
};
