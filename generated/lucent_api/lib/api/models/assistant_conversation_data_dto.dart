// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'assistant_conversation_data_dto_status_status.dart';
import 'assistant_conversation_message_dto.dart';

part 'assistant_conversation_data_dto.g.dart';

@JsonSerializable()
class AssistantConversationDataDto {
  const AssistantConversationDataDto({
    required this.id,
    required this.title,
    required this.status,
    required this.messages,
    required this.lastMessageAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AssistantConversationDataDto.fromJson(Map<String, Object?> json) =>
      _$AssistantConversationDataDtoFromJson(json);

  /// Stable persisted conversation identifier.
  final String id;

  /// Optional server-derived conversation title.
  final String? title;

  /// Current conversation status.
  final AssistantConversationDataDtoStatusStatus status;

  /// Persisted messages in chronological order.
  final List<AssistantConversationMessageDto> messages;

  /// ISO-8601 timestamp of the latest conversation activity.
  final String? lastMessageAt;

  /// ISO-8601 creation timestamp.
  final String createdAt;

  /// ISO-8601 update timestamp.
  final String updatedAt;

  Map<String, Object?> toJson() => _$AssistantConversationDataDtoToJson(this);
}
