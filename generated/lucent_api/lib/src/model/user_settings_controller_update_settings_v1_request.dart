//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/user_settings_controller_update_settings_v1_request_assistant_context.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_settings_controller_update_settings_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UserSettingsControllerUpdateSettingsV1Request {
  /// Returns a new [UserSettingsControllerUpdateSettingsV1Request] instance.
  UserSettingsControllerUpdateSettingsV1Request({
    this.aiSummariesEnabled,

    this.dataSharingConsent,

    this.assistantEnabled,

    this.assistantMemoryEnabled,

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

  /// Daily water intake target (number of glasses).
  // minimum: 1
  // maximum: 30
  @JsonKey(name: r'waterTargetCount', required: false, includeIfNull: false)
  final int? waterTargetCount;

  @JsonKey(name: r'assistantContext', required: false, includeIfNull: false)
  final UserSettingsControllerUpdateSettingsV1RequestAssistantContext?
  assistantContext;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsControllerUpdateSettingsV1Request &&
          other.aiSummariesEnabled == aiSummariesEnabled &&
          other.dataSharingConsent == dataSharingConsent &&
          other.assistantEnabled == assistantEnabled &&
          other.assistantMemoryEnabled == assistantMemoryEnabled &&
          other.waterTargetCount == waterTargetCount &&
          other.assistantContext == assistantContext;

  @override
  int get hashCode =>
      aiSummariesEnabled.hashCode +
      dataSharingConsent.hashCode +
      assistantEnabled.hashCode +
      assistantMemoryEnabled.hashCode +
      waterTargetCount.hashCode +
      assistantContext.hashCode;

  factory UserSettingsControllerUpdateSettingsV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$UserSettingsControllerUpdateSettingsV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$UserSettingsControllerUpdateSettingsV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
