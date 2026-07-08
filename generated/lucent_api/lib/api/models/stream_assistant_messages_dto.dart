// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'assistant_input_message_dto.dart';

part 'stream_assistant_messages_dto.g.dart';

@JsonSerializable()
class StreamAssistantMessagesDto {
  const StreamAssistantMessagesDto({required this.messages});

  factory StreamAssistantMessagesDto.fromJson(Map<String, Object?> json) =>
      _$StreamAssistantMessagesDtoFromJson(json);

  /// Conversation window ending with the latest user message to answer.
  final List<AssistantInputMessageDto> messages;

  Map<String, Object?> toJson() => _$StreamAssistantMessagesDtoToJson(this);
}
