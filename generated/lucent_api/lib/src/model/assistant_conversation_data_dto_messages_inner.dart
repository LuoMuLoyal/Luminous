//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_conversation_data_dto_messages_inner.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantConversationDataDtoMessagesInner {
  /// Returns a new [AssistantConversationDataDtoMessagesInner] instance.
  AssistantConversationDataDtoMessagesInner({
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
        AssistantConversationDataDtoMessagesInnerRoleEnum.unknownDefaultOpenApi,
  )
  final AssistantConversationDataDtoMessagesInnerRoleEnum role;

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
      other is AssistantConversationDataDtoMessagesInner &&
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

  factory AssistantConversationDataDtoMessagesInner.fromJson(
    Map<String, dynamic> json,
  ) => _$AssistantConversationDataDtoMessagesInnerFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AssistantConversationDataDtoMessagesInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Persisted conversation role visible to the client.
enum AssistantConversationDataDtoMessagesInnerRoleEnum {
  @JsonValue(r'user')
  user(r'user'),
  @JsonValue(r'assistant')
  assistant(r'assistant'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const AssistantConversationDataDtoMessagesInnerRoleEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
