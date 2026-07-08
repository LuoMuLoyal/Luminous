// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'assistant_conversation_summary_dto_status_status.dart';

part 'assistant_conversation_summary_dto.g.dart';

@JsonSerializable()
class AssistantConversationSummaryDto {
  const AssistantConversationSummaryDto({
    required this.id,
    required this.title,
    required this.status,
    required this.lastMessageAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AssistantConversationSummaryDto.fromJson(Map<String, Object?> json) =>
      _$AssistantConversationSummaryDtoFromJson(json);

  /// Stable persisted conversation identifier.
  final String id;

  /// Optional server-derived conversation title.
  final String? title;

  /// Current conversation status.
  final AssistantConversationSummaryDtoStatusStatus status;

  /// ISO-8601 timestamp of the latest conversation activity.
  final String? lastMessageAt;

  /// ISO-8601 creation timestamp.
  final String createdAt;

  /// ISO-8601 update timestamp.
  final String updatedAt;

  Map<String, Object?> toJson() =>
      _$AssistantConversationSummaryDtoToJson(this);
}
