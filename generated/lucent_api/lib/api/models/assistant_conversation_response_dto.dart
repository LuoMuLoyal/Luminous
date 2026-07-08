// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'assistant_conversation_data_dto.dart';

part 'assistant_conversation_response_dto.g.dart';

@JsonSerializable()
class AssistantConversationResponseDto {
  const AssistantConversationResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory AssistantConversationResponseDto.fromJson(
    Map<String, Object?> json,
  ) => _$AssistantConversationResponseDtoFromJson(json);

  /// Result code.
  final num code;

  /// Message.
  final String message;

  /// Persisted conversation payload, or null when none exists.
  final AssistantConversationDataDto data;

  Map<String, Object?> toJson() =>
      _$AssistantConversationResponseDtoToJson(this);
}
