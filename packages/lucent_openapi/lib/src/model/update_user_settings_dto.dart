//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/update_assistant_context_settings_dto.dart';
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

    this.assistantEnabled,

    this.assistantMemoryEnabled,

    this.assistantContext,
  });

  /// Allow AI-generated summaries and advice.
  @JsonKey(name: r'aiSummariesEnabled', required: false, includeIfNull: false)
  final bool? aiSummariesEnabled;

  /// Consent to share anonymized data for research.
  @JsonKey(name: r'dataSharingConsent', required: false, includeIfNull: false)
  final bool? dataSharingConsent;

  /// Allow the authenticated user to use the assistant feature.
  @JsonKey(name: r'assistantEnabled', required: false, includeIfNull: false)
  final bool? assistantEnabled;

  /// Allow the assistant to reuse persisted conversation history as cross-conversation memory.
  @JsonKey(
    name: r'assistantMemoryEnabled',
    required: false,
    includeIfNull: false,
  )
  final bool? assistantMemoryEnabled;

  /// Fine-grained permissions for what the assistant may read.
  @JsonKey(name: r'assistantContext', required: false, includeIfNull: false)
  final UpdateAssistantContextSettingsDto? assistantContext;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateUserSettingsDto &&
          other.aiSummariesEnabled == aiSummariesEnabled &&
          other.dataSharingConsent == dataSharingConsent &&
          other.assistantEnabled == assistantEnabled &&
          other.assistantMemoryEnabled == assistantMemoryEnabled &&
          other.assistantContext == assistantContext;

  @override
  int get hashCode =>
      aiSummariesEnabled.hashCode +
      dataSharingConsent.hashCode +
      assistantEnabled.hashCode +
      assistantMemoryEnabled.hashCode +
      assistantContext.hashCode;

  factory UpdateUserSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserSettingsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateUserSettingsDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
