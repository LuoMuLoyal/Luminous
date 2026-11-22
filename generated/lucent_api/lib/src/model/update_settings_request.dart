//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/update_settings_request_assistant_context.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_settings_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateSettingsRequest {
  /// Returns a new [UpdateSettingsRequest] instance.
  UpdateSettingsRequest({
    this.aiSummariesEnabled,

    this.dataSharingConsent,

    this.assistantEnabled,

    this.assistantMemoryEnabled,

    this.assistantAgentMode,

    this.waterTargetCount,

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

  /// Agent backend preference: \"default\" follows the server operator setting; \"graph\" and \"deepagents\" override it for this user.
  @JsonKey(
    name: r'assistantAgentMode',
    required: false,
    includeIfNull: false,
    unknownEnumValue:
        UpdateSettingsRequestAssistantAgentModeEnum.unknownDefaultOpenApi,
  )
  final UpdateSettingsRequestAssistantAgentModeEnum? assistantAgentMode;

  /// Daily water intake target (number of glasses).
  // minimum: 1
  // maximum: 30
  @JsonKey(name: r'waterTargetCount', required: false, includeIfNull: false)
  final int? waterTargetCount;

  @JsonKey(name: r'assistantContext', required: false, includeIfNull: false)
  final UpdateSettingsRequestAssistantContext? assistantContext;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateSettingsRequest &&
          other.aiSummariesEnabled == aiSummariesEnabled &&
          other.dataSharingConsent == dataSharingConsent &&
          other.assistantEnabled == assistantEnabled &&
          other.assistantMemoryEnabled == assistantMemoryEnabled &&
          other.assistantAgentMode == assistantAgentMode &&
          other.waterTargetCount == waterTargetCount &&
          other.assistantContext == assistantContext;

  @override
  int get hashCode =>
      aiSummariesEnabled.hashCode +
      dataSharingConsent.hashCode +
      assistantEnabled.hashCode +
      assistantMemoryEnabled.hashCode +
      assistantAgentMode.hashCode +
      waterTargetCount.hashCode +
      assistantContext.hashCode;

  factory UpdateSettingsRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateSettingsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateSettingsRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Agent backend preference: \"default\" follows the server operator setting; \"graph\" and \"deepagents\" override it for this user.
enum UpdateSettingsRequestAssistantAgentModeEnum {
  @JsonValue(r'default')
  default_(r'default'),
  @JsonValue(r'graph')
  graph(r'graph'),
  @JsonValue(r'deepagents')
  deepagents(r'deepagents'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const UpdateSettingsRequestAssistantAgentModeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
