// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_chat_conversation_list_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiChatConversationListResponseDto _$AiChatConversationListResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AiChatConversationListResponseDto', json, (
  $checkedConvert,
) {
  $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
  final val = AiChatConversationListResponseDto(
    code: $checkedConvert('code', (v) => v as num),
    message: $checkedConvert('message', (v) => v as String),
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map(
            (e) => AiChatConversationSummaryDto.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$AiChatConversationListResponseDtoToJson(
  AiChatConversationListResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data.map((e) => e.toJson()).toList(),
};
