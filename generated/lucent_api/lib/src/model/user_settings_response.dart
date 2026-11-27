//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/user_settings_response_assistant_context.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_settings_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UserSettingsResponse {
  /// Returns a new [UserSettingsResponse] instance.
  UserSettingsResponse({
    required this.digestEnabled,

    required this.dataSharingConsent,

    required this.assistantEnabled,

    required this.assistantMemoryEnabled,

    required this.assistantAgentMode,

    required this.waterTargetCount,

    required this.assistantContext,

    required this.updatedAt,

    required this.passwordReauthenticationRequired,
  });

  /// Allow AI-generated summaries and advice.
  @JsonKey(name: r'digestEnabled', required: true, includeIfNull: false)
  final bool digestEnabled;

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

  /// Agent backend in effect for this user: \"default\" follows the server operator setting.
  @JsonKey(
    name: r'assistantAgentMode',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        UserSettingsResponseAssistantAgentModeEnum.unknownDefaultOpenApi,
  )
  final UserSettingsResponseAssistantAgentModeEnum assistantAgentMode;

  /// Daily water intake target (number of glasses).
  @JsonKey(name: r'waterTargetCount', required: true, includeIfNull: false)
  final num waterTargetCount;

  @JsonKey(name: r'assistantContext', required: true, includeIfNull: false)
  final UserSettingsResponseAssistantContext assistantContext;

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
      other is UserSettingsResponse &&
          other.digestEnabled == digestEnabled &&
          other.dataSharingConsent == dataSharingConsent &&
          other.assistantEnabled == assistantEnabled &&
          other.assistantMemoryEnabled == assistantMemoryEnabled &&
          other.assistantAgentMode == assistantAgentMode &&
          other.waterTargetCount == waterTargetCount &&
          other.assistantContext == assistantContext &&
          other.updatedAt == updatedAt &&
          other.passwordReauthenticationRequired ==
              passwordReauthenticationRequired;

  @override
  int get hashCode =>
      digestEnabled.hashCode +
      dataSharingConsent.hashCode +
      assistantEnabled.hashCode +
      assistantMemoryEnabled.hashCode +
      assistantAgentMode.hashCode +
      waterTargetCount.hashCode +
      assistantContext.hashCode +
      (updatedAt == null ? 0 : updatedAt.hashCode) +
      passwordReauthenticationRequired.hashCode;

  factory UserSettingsResponse.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserSettingsResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Agent backend in effect for this user: \"default\" follows the server operator setting.
enum UserSettingsResponseAssistantAgentModeEnum {
  @JsonValue(r'default')
  default_(r'default'),
  @JsonValue(r'graph')
  graph(r'graph'),
  @JsonValue(r'deepagents')
  deepagents(r'deepagents'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const UserSettingsResponseAssistantAgentModeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
