// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stream_assistant_messages_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StreamAssistantMessagesDto _$StreamAssistantMessagesDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('StreamAssistantMessagesDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['messages']);
  final val = StreamAssistantMessagesDto(
    messages: $checkedConvert(
      'messages',
      (v) => (v as List<dynamic>)
          .map(
            (e) => AssistantInputMessageDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$StreamAssistantMessagesDtoToJson(
  StreamAssistantMessagesDto instance,
) => <String, dynamic>{
  'messages': instance.messages.map((e) => e.toJson()).toList(),
};
