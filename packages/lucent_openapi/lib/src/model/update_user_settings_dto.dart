//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/update_ai_chat_context_settings_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_user_settings_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateUserSettingsDto {
  /// Returns a new [UpdateUserSettingsDto] instance.
  UpdateUserSettingsDto({
    this.aiSummariesEnabled,

    this.dataSharingConsent,

    this.aiChatEnabled,

    this.aiChatMemoryEnabled,

    this.aiChatContext,
  });

  /// Allow AI-generated summaries and advice.
  @JsonKey(name: r'aiSummariesEnabled', required: false, includeIfNull: false)
  final bool? aiSummariesEnabled;

  /// Consent to share anonymized data for research.
  @JsonKey(name: r'dataSharingConsent', required: false, includeIfNull: false)
  final bool? dataSharingConsent;

  /// Allow the authenticated user to use the AI chat feature.
  @JsonKey(name: r'aiChatEnabled', required: false, includeIfNull: false)
  final bool? aiChatEnabled;

  /// Allow AI chat to reuse persisted assistant history as cross-conversation memory.
  @JsonKey(name: r'aiChatMemoryEnabled', required: false, includeIfNull: false)
  final bool? aiChatMemoryEnabled;

  /// Fine-grained permissions for what AI chat may read.
  @JsonKey(name: r'aiChatContext', required: false, includeIfNull: false)
  final UpdateAiChatContextSettingsDto? aiChatContext;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateUserSettingsDto &&
          other.aiSummariesEnabled == aiSummariesEnabled &&
          other.dataSharingConsent == dataSharingConsent &&
          other.aiChatEnabled == aiChatEnabled &&
          other.aiChatMemoryEnabled == aiChatMemoryEnabled &&
          other.aiChatContext == aiChatContext;

  @override
  int get hashCode =>
      aiSummariesEnabled.hashCode +
      dataSharingConsent.hashCode +
      aiChatEnabled.hashCode +
      aiChatMemoryEnabled.hashCode +
      aiChatContext.hashCode;

  factory UpdateUserSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserSettingsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateUserSettingsDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
