//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/assistant_context_settings_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_settings_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UserSettingsResponseDto {
  /// Returns a new [UserSettingsResponseDto] instance.
  UserSettingsResponseDto({
    required this.aiSummariesEnabled,

    required this.dataSharingConsent,

    required this.assistantEnabled,

    required this.assistantMemoryEnabled,

    required this.waterTargetCount,

    required this.assistantContext,

    required this.updatedAt,

    required this.passwordReauthenticationRequired,
  });

  /// Allow AI-generated summaries and advice.
  @JsonKey(name: r'aiSummariesEnabled', required: true, includeIfNull: false)
  final bool aiSummariesEnabled;

  /// Consent to share anonymized data for research.
  @JsonKey(name: r'dataSharingConsent', required: true, includeIfNull: false)
  final bool dataSharingConsent;

  /// Allow the authenticated user to use the assistant feature.
  @JsonKey(name: r'assistantEnabled', required: true, includeIfNull: false)
  final bool assistantEnabled;

  /// Allow the assistant to reuse persisted conversation history as cross-conversation memory.
  @JsonKey(
    name: r'assistantMemoryEnabled',
    required: true,
    includeIfNull: false,
  )
  final bool assistantMemoryEnabled;

  /// Daily water intake target (number of glasses).
  @JsonKey(name: r'waterTargetCount', required: true, includeIfNull: false)
  final num waterTargetCount;

  /// Fine-grained assistant context permissions.
  @JsonKey(name: r'assistantContext', required: true, includeIfNull: false)
  final AssistantContextSettingsDto assistantContext;

  /// ISO-8601 timestamp of last update.
  @JsonKey(name: r'updatedAt', required: true, includeIfNull: true)
  final String? updatedAt;

  /// Whether sensitive operations require password re-authentication.
  @JsonKey(
    name: r'passwordReauthenticationRequired',
    required: true,
    includeIfNull: false,
  )
  final bool passwordReauthenticationRequired;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsResponseDto &&
          other.aiSummariesEnabled == aiSummariesEnabled &&
          other.dataSharingConsent == dataSharingConsent &&
          other.assistantEnabled == assistantEnabled &&
          other.assistantMemoryEnabled == assistantMemoryEnabled &&
          other.waterTargetCount == waterTargetCount &&
          other.assistantContext == assistantContext &&
          other.updatedAt == updatedAt &&
          other.passwordReauthenticationRequired ==
              passwordReauthenticationRequired;

  @override
  int get hashCode =>
      aiSummariesEnabled.hashCode +
      dataSharingConsent.hashCode +
      assistantEnabled.hashCode +
      assistantMemoryEnabled.hashCode +
      waterTargetCount.hashCode +
      assistantContext.hashCode +
      (updatedAt == null ? 0 : updatedAt.hashCode) +
      passwordReauthenticationRequired.hashCode;

  factory UserSettingsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserSettingsResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
