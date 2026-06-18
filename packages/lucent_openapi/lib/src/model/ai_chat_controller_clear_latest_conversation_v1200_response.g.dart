// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_chat_controller_clear_latest_conversation_v1200_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiChatControllerClearLatestConversationV1200Response
_$AiChatControllerClearLatestConversationV1200ResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'AiChatControllerClearLatestConversationV1200Response',
  json,
  ($checkedConvert) {
    final val = AiChatControllerClearLatestConversationV1200Response(
      code: $checkedConvert('code', (v) => v as num?),
      message: $checkedConvert('message', (v) => v as String?),
      data: $checkedConvert(
        'data',
        (v) => v == null
            ? null
            : AiChatControllerClearLatestConversationV1200ResponseData.fromJson(
                v as Map<String, dynamic>,
              ),
      ),
    );
    return val;
  },
);

Map<String, dynamic>
_$AiChatControllerClearLatestConversationV1200ResponseToJson(
  AiChatControllerClearLatestConversationV1200Response instance,
) => <String, dynamic>{
  if (instance.code != null) 'code': instance.code,
  if (instance.message != null) 'message': instance.message,
  if (instance.data?.toJson() != null) 'data': instance.data?.toJson(),
};
