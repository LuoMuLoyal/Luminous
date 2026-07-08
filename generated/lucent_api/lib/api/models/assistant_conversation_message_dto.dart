// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'assistant_conversation_message_dto_role_role.dart';

part 'assistant_conversation_message_dto.g.dart';

@JsonSerializable()
class AssistantConversationMessageDto {
  const AssistantConversationMessageDto({
    required this.role,
    required this.content,
    required this.usedTools,
    required this.createdAt,
  });

  factory AssistantConversationMessageDto.fromJson(Map<String, Object?> json) =>
      _$AssistantConversationMessageDtoFromJson(json);

  /// Persisted conversation role visible to the client.
  final AssistantConversationMessageDtoRoleRole role;

  /// Persisted Markdown-ready message content.
  final String content;

  /// Tool names recorded for this message. Non-empty for assistant messages that used tools.
  final List<String> usedTools;

  /// ISO-8601 timestamp when the message was created.
  final String createdAt;

  Map<String, Object?> toJson() =>
      _$AssistantConversationMessageDtoToJson(this);
}
