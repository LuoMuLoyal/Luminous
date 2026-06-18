//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/ai_chat_conversation_message_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ai_chat_conversation_data_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AiChatConversationDataDto {
  /// Returns a new [AiChatConversationDataDto] instance.
  AiChatConversationDataDto({
    required this.id,

    required this.title,

    required this.status,

    required this.messages,

    required this.lastMessageAt,

    required this.createdAt,

    required this.updatedAt,
  });

  /// Stable persisted conversation identifier.
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  /// Optional server-derived conversation title.
  @JsonKey(name: r'title', required: true, includeIfNull: true)
  final Object? title;

  /// Current conversation status.
  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue: AiChatConversationDataDtoStatusEnum.unknownDefaultOpenApi,
  )
  final AiChatConversationDataDtoStatusEnum status;

  /// Persisted messages in chronological order.
  @JsonKey(name: r'messages', required: true, includeIfNull: false)
  final List<AiChatConversationMessageDto> messages;

  /// ISO-8601 timestamp of the latest conversation activity.
  @JsonKey(name: r'lastMessageAt', required: true, includeIfNull: true)
  final Object? lastMessageAt;

  /// ISO-8601 creation timestamp.
  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final String createdAt;

  /// ISO-8601 update timestamp.
  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final String updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiChatConversationDataDto &&
          other.id == id &&
          other.title == title &&
          other.status == status &&
          other.messages == messages &&
          other.lastMessageAt == lastMessageAt &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      id.hashCode +
      (title == null ? 0 : title.hashCode) +
      status.hashCode +
      messages.hashCode +
      (lastMessageAt == null ? 0 : lastMessageAt.hashCode) +
      createdAt.hashCode +
      updatedAt.hashCode;

  factory AiChatConversationDataDto.fromJson(Map<String, dynamic> json) =>
      _$AiChatConversationDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AiChatConversationDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Current conversation status.
enum AiChatConversationDataDtoStatusEnum {
  /// Current conversation status.
  @JsonValue(r'active')
  active(r'active'),

  /// Current conversation status.
  @JsonValue(r'archived')
  archived(r'archived'),

  /// Current conversation status.
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const AiChatConversationDataDtoStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
