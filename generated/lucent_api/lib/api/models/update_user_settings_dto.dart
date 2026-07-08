// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'update_assistant_context_settings_dto.dart';

part 'update_user_settings_dto.g.dart';

@JsonSerializable()
class UpdateUserSettingsDto {
  const UpdateUserSettingsDto({
    required this.aiSummariesEnabled,
    required this.dataSharingConsent,
    required this.assistantEnabled,
    required this.assistantMemoryEnabled,
    required this.assistantContext,
  });

  factory UpdateUserSettingsDto.fromJson(Map<String, Object?> json) =>
      _$UpdateUserSettingsDtoFromJson(json);

  /// Allow AI-generated summaries and advice.
  final bool aiSummariesEnabled;

  /// Consent to share anonymized data for research.
  final bool dataSharingConsent;

  /// Allow the authenticated user to use the assistant feature.
  final bool assistantEnabled;

  /// Allow the assistant to reuse persisted conversation history as cross-conversation memory.
  final bool assistantMemoryEnabled;

  /// Fine-grained permissions for what the assistant may read.
  final UpdateAssistantContextSettingsDto assistantContext;

  Map<String, Object?> toJson() => _$UpdateUserSettingsDtoToJson(this);
}
