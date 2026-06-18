//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/assistant_input_message_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stream_assistant_messages_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class StreamAssistantMessagesDto {
  /// Returns a new [StreamAssistantMessagesDto] instance.
  StreamAssistantMessagesDto({required this.messages});

  /// Conversation window ending with the latest user message to answer.
  @JsonKey(name: r'messages', required: true, includeIfNull: false)
  final List<AssistantInputMessageDto> messages;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreamAssistantMessagesDto && other.messages == messages;

  @override
  int get hashCode => messages.hashCode;

  factory StreamAssistantMessagesDto.fromJson(Map<String, dynamic> json) =>
      _$StreamAssistantMessagesDtoFromJson(json);

  Map<String, dynamic> toJson() => _$StreamAssistantMessagesDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
