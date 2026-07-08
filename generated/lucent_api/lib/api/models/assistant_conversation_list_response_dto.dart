// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'assistant_conversation_summary_dto.dart';

part 'assistant_conversation_list_response_dto.g.dart';

@JsonSerializable()
class AssistantConversationListResponseDto {
  const AssistantConversationListResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory AssistantConversationListResponseDto.fromJson(
    Map<String, Object?> json,
  ) => _$AssistantConversationListResponseDtoFromJson(json);

  /// Result code.
  final num code;

  /// Message.
  final String message;

  /// Recent persisted conversations for the authenticated user, newest first.
  final List<AssistantConversationSummaryDto> data;

  Map<String, Object?> toJson() =>
      _$AssistantConversationListResponseDtoToJson(this);
}
