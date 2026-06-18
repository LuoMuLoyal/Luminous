// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_controller_clear_latest_conversation_v1200_response_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantControllerClearLatestConversationV1200ResponseData
_$AssistantControllerClearLatestConversationV1200ResponseDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'AssistantControllerClearLatestConversationV1200ResponseData',
  json,
  ($checkedConvert) {
    final val = AssistantControllerClearLatestConversationV1200ResponseData(
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
_$AssistantControllerClearLatestConversationV1200ResponseDataToJson(
  AssistantControllerClearLatestConversationV1200ResponseData instance,
) => <String, dynamic>{
  if (instance.cleared != null) 'cleared': instance.cleared,
  if (instance.archivedConversationId != null)
    'archivedConversationId': instance.archivedConversationId,
};
