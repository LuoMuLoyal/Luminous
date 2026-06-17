//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/ai_chat_input_message_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stream_ai_chat_messages_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class StreamAiChatMessagesDto {
  /// Returns a new [StreamAiChatMessagesDto] instance.
  StreamAiChatMessagesDto({required this.messages});

  /// Conversation window ending with the latest user message to answer.
  @JsonKey(name: r'messages', required: true, includeIfNull: false)
  final List<AiChatInputMessageDto> messages;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreamAiChatMessagesDto && other.messages == messages;

  @override
  int get hashCode => messages.hashCode;

  factory StreamAiChatMessagesDto.fromJson(Map<String, dynamic> json) =>
      _$StreamAiChatMessagesDtoFromJson(json);

  Map<String, dynamic> toJson() => _$StreamAiChatMessagesDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
