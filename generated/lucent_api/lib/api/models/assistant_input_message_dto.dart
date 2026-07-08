// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'assistant_input_message_dto_role_role.dart';

part 'assistant_input_message_dto.g.dart';

@JsonSerializable()
class AssistantInputMessageDto {
  const AssistantInputMessageDto({required this.role, required this.content});

  factory AssistantInputMessageDto.fromJson(Map<String, Object?> json) =>
      _$AssistantInputMessageDtoFromJson(json);

  /// Client-visible conversation role. system is not accepted.
  final AssistantInputMessageDtoRoleRole role;

  /// Plain or Markdown-ready message content.
  final String content;

  Map<String, Object?> toJson() => _$AssistantInputMessageDtoToJson(this);
}
