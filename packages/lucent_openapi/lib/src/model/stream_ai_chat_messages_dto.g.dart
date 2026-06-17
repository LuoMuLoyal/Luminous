// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stream_ai_chat_messages_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StreamAiChatMessagesDto _$StreamAiChatMessagesDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('StreamAiChatMessagesDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['messages']);
  final val = StreamAiChatMessagesDto(
    messages: $checkedConvert(
      'messages',
      (v) => (v as List<dynamic>)
          .map((e) => AiChatInputMessageDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$StreamAiChatMessagesDtoToJson(
  StreamAiChatMessagesDto instance,
) => <String, dynamic>{
  'messages': instance.messages.map((e) => e.toJson()).toList(),
};
