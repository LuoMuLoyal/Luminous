// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_controller_clear_latest_conversation_v1200_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantControllerClearLatestConversationV1200Response
_$AssistantControllerClearLatestConversationV1200ResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'AssistantControllerClearLatestConversationV1200Response',
  json,
  ($checkedConvert) {
    final val = AssistantControllerClearLatestConversationV1200Response(
      code: $checkedConvert('code', (v) => v as num?),
      message: $checkedConvert('message', (v) => v as String?),
      data: $checkedConvert(
        'data',
        (v) => v == null
            ? null
            : AssistantControllerClearLatestConversationV1200ResponseData.fromJson(
                v as Map<String, dynamic>,
              ),
      ),
    );
    return val;
  },
);

Map<String, dynamic>
_$AssistantControllerClearLatestConversationV1200ResponseToJson(
  AssistantControllerClearLatestConversationV1200Response instance,
) => <String, dynamic>{
  if (instance.code != null) 'code': instance.code,
  if (instance.message != null) 'message': instance.message,
  if (instance.data?.toJson() != null) 'data': instance.data?.toJson(),
};
