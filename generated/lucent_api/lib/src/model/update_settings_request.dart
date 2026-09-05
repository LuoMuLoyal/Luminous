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
  final UpdateSettingsRequestAssistantContext? assistantContext;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateSettingsRequest &&
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

  factory UpdateSettingsRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateSettingsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateSettingsRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
