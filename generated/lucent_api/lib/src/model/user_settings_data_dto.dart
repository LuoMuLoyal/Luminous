//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/security_pin_settings_dto.dart';
import 'package:lucent_api/src/model/assistant_context_settings_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_settings_data_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UserSettingsDataDto {
  /// Returns a new [UserSettingsDataDto] instance.
  UserSettingsDataDto({
    required this.aiSummariesEnabled,
    required this.dataSharingConsent,
    required this.assistantEnabled,
    required this.assistantMemoryEnabled,
    required this.waterTargetCount,
    required this.assistantContext,
    required this.updatedAt,
    required this.securityPin,
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

  /// Security PIN status.
  @JsonKey(name: r'securityPin', required: true, includeIfNull: false)
  final SecurityPinSettingsDto securityPin;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsDataDto &&
          other.aiSummariesEnabled == aiSummariesEnabled &&
          other.dataSharingConsent == dataSharingConsent &&
          other.assistantEnabled == assistantEnabled &&
          other.assistantMemoryEnabled == assistantMemoryEnabled &&
          other.waterTargetCount == waterTargetCount &&
          other.assistantContext == assistantContext &&
          other.updatedAt == updatedAt &&
          other.securityPin == securityPin;

  @override
  int get hashCode =>
      aiSummariesEnabled.hashCode +
      dataSharingConsent.hashCode +
      assistantEnabled.hashCode +
      assistantMemoryEnabled.hashCode +
      waterTargetCount.hashCode +
      assistantContext.hashCode +
      (updatedAt == null ? 0 : updatedAt.hashCode) +
      securityPin.hashCode;

  factory UserSettingsDataDto.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserSettingsDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
