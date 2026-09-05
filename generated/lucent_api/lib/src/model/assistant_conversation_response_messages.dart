//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_conversation_response_messages.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantConversationResponseMessages {
  /// Returns a new [AssistantConversationResponseMessages] instance.
  AssistantConversationResponseMessages({
    required this.role,

    required this.content,

    required this.usedTools,

    required this.createdAt,
  });

  /// Persisted conversation role visible to the client.
  @JsonKey(
    name: r'role',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        AssistantConversationResponseMessagesRoleEnum.unknownDefaultOpenApi,
  )
  final AssistantConversationResponseMessagesRoleEnum role;

  /// Persisted Markdown-ready message content.
  @JsonKey(name: r'content', required: true, includeIfNull: false)
  final String content;

  /// Tool names recorded for this message. Non-empty for assistant messages that used tools.
  @JsonKey(name: r'usedTools', required: true, includeIfNull: false)
  final List<String> usedTools;

  /// ISO-8601 timestamp when the message was created.
  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final String createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssistantConversationResponseMessages &&
          other.role == role &&
          other.content == content &&
          other.usedTools == usedTools &&
          other.createdAt == createdAt;

  @override
  int get hashCode =>
      role.hashCode +
      content.hashCode +
      usedTools.hashCode +
      createdAt.hashCode;

  factory AssistantConversationResponseMessages.fromJson(
    Map<String, dynamic> json,
  ) => _$AssistantConversationResponseMessagesFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AssistantConversationResponseMessagesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Persisted conversation role visible to the client.
enum AssistantConversationResponseMessagesRoleEnum {
  @JsonValue(r'user')
  user(r'user'),
  @JsonValue(r'assistant')
  assistant(r'assistant'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const AssistantConversationResponseMessagesRoleEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
