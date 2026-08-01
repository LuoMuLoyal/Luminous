//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/assistant_input_message_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stream_assistant_messages_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class StreamAssistantMessagesDto {
  /// Returns a new [StreamAssistantMessagesDto] instance.
  StreamAssistantMessagesDto({required this.messages, this.conversationId});

  /// Conversation window ending with the latest user message to answer.
  @JsonKey(name: r'messages', required: true, includeIfNull: false)
  final List<AssistantInputMessageDto> messages;

  /// Optional persisted conversation id used as the LangGraph thread id. When absent the conversation runs statelessly (no checkpoint / no in-graph review).
  @JsonKey(name: r'conversationId', required: false, includeIfNull: false)
  final String? conversationId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreamAssistantMessagesDto &&
          other.messages == messages &&
          other.conversationId == conversationId;

  @override
  int get hashCode => messages.hashCode + conversationId.hashCode;

  factory StreamAssistantMessagesDto.fromJson(Map<String, dynamic> json) =>
      _$StreamAssistantMessagesDtoFromJson(json);

  Map<String, dynamic> toJson() => _$StreamAssistantMessagesDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
