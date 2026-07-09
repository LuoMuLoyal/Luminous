// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'assistant_context_settings_dto.dart';
import 'security_pin_settings_dto.dart';

part 'user_settings_data_dto.g.dart';

@JsonSerializable()
class UserSettingsDataDto {
  const UserSettingsDataDto({
    required this.aiSummariesEnabled,
    required this.dataSharingConsent,
    required this.assistantEnabled,
    required this.assistantMemoryEnabled,
    required this.waterTargetCount,
    required this.assistantContext,
    required this.updatedAt,
    required this.securityPin,
  });

  factory UserSettingsDataDto.fromJson(Map<String, Object?> json) =>
      _$UserSettingsDataDtoFromJson(json);

  /// Allow AI-generated summaries and advice.
  final bool aiSummariesEnabled;

  /// Consent to share anonymized data for research.
  final bool dataSharingConsent;

  /// Allow the authenticated user to use the assistant feature.
  final bool assistantEnabled;

  /// Allow the assistant to reuse persisted conversation history as cross-conversation memory.
  final bool assistantMemoryEnabled;

  /// Daily water intake target (number of glasses).
  final num waterTargetCount;

  /// Fine-grained assistant context permissions.
  final AssistantContextSettingsDto assistantContext;

  /// ISO-8601 timestamp of last update.
  final String? updatedAt;

  /// Security PIN status.
  final SecurityPinSettingsDto securityPin;

  Map<String, Object?> toJson() => _$UserSettingsDataDtoToJson(this);
}
