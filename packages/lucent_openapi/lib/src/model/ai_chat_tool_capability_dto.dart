//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'ai_chat_tool_capability_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AiChatToolCapabilityDto {
  /// Returns a new [AiChatToolCapabilityDto] instance.
  AiChatToolCapabilityDto({
    required this.name,

    required this.requiredContextSources,

    required this.permittedByUser,

    required this.enabled,

    required this.implemented,

    required this.disabledReason,
  });

  /// Stable tool identifier exposed to the client.
  @JsonKey(
    name: r'name',
    required: true,
    includeIfNull: false,
    unknownEnumValue: AiChatToolCapabilityDtoNameEnum.unknownDefaultOpenApi,
  )
  final AiChatToolCapabilityDtoNameEnum name;

  /// Context sources this tool requires before it may run. Allowed values: health_profile, daily_records, sleep_records, current_medicines.
  @JsonKey(
    name: r'requiredContextSources',
    required: true,
    includeIfNull: false,
  )
  final List<String> requiredContextSources;

  /// Whether the current user settings permit this tool in principle.
  @JsonKey(name: r'permittedByUser', required: true, includeIfNull: false)
  final bool permittedByUser;

  /// Whether this tool is currently executable for this user.
  @JsonKey(name: r'enabled', required: true, includeIfNull: false)
  final bool enabled;

  /// Whether the server has already implemented this tool beyond planning/foundation wiring.
  @JsonKey(name: r'implemented', required: true, includeIfNull: false)
  final bool implemented;

  /// Why the tool is currently disabled, or null when enabled.
  @JsonKey(
    name: r'disabledReason',
    required: true,
    includeIfNull: true,
    unknownEnumValue:
        AiChatToolCapabilityDtoDisabledReasonEnum.unknownDefaultOpenApi,
  )
  final AiChatToolCapabilityDtoDisabledReasonEnum? disabledReason;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiChatToolCapabilityDto &&
          other.name == name &&
          other.requiredContextSources == requiredContextSources &&
          other.permittedByUser == permittedByUser &&
          other.enabled == enabled &&
          other.implemented == implemented &&
          other.disabledReason == disabledReason;

  @override
  int get hashCode =>
      name.hashCode +
      requiredContextSources.hashCode +
      permittedByUser.hashCode +
      enabled.hashCode +
      implemented.hashCode +
      (disabledReason == null ? 0 : disabledReason.hashCode);

  factory AiChatToolCapabilityDto.fromJson(Map<String, dynamic> json) =>
      _$AiChatToolCapabilityDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AiChatToolCapabilityDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Stable tool identifier exposed to the client.
enum AiChatToolCapabilityDtoNameEnum {
  /// Stable tool identifier exposed to the client.
  @JsonValue(r'get_today_records')
  getTodayRecords(r'get_today_records'),

  /// Stable tool identifier exposed to the client.
  @JsonValue(r'get_records_by_date')
  getRecordsByDate(r'get_records_by_date'),

  /// Stable tool identifier exposed to the client.
  @JsonValue(r'get_records_by_range')
  getRecordsByRange(r'get_records_by_range'),

  /// Stable tool identifier exposed to the client.
  @JsonValue(r'get_recent_today_summaries')
  getRecentTodaySummaries(r'get_recent_today_summaries'),

  /// Stable tool identifier exposed to the client.
  @JsonValue(r'get_recent_report_summaries')
  getRecentReportSummaries(r'get_recent_report_summaries'),

  /// Stable tool identifier exposed to the client.
  @JsonValue(r'get_user_profile')
  getUserProfile(r'get_user_profile'),

  /// Stable tool identifier exposed to the client.
  @JsonValue(r'get_user_settings')
  getUserSettings(r'get_user_settings'),

  /// Stable tool identifier exposed to the client.
  @JsonValue(r'get_current_medicines')
  getCurrentMedicines(r'get_current_medicines'),

  /// Stable tool identifier exposed to the client.
  @JsonValue(r'get_sleep_summary_by_range')
  getSleepSummaryByRange(r'get_sleep_summary_by_range'),

  /// Stable tool identifier exposed to the client.
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const AiChatToolCapabilityDtoNameEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Why the tool is currently disabled, or null when enabled.
enum AiChatToolCapabilityDtoDisabledReasonEnum {
  /// Why the tool is currently disabled, or null when enabled.
  @JsonValue(r'chat_disabled')
  chatDisabled(r'chat_disabled'),

  /// Why the tool is currently disabled, or null when enabled.
  @JsonValue(r'context_disabled')
  contextDisabled(r'context_disabled'),

  /// Why the tool is currently disabled, or null when enabled.
  @JsonValue(r'model_not_configured')
  modelNotConfigured(r'model_not_configured'),

  /// Why the tool is currently disabled, or null when enabled.
  @JsonValue(r'not_implemented')
  notImplemented(r'not_implemented'),

  /// Why the tool is currently disabled, or null when enabled.
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const AiChatToolCapabilityDtoDisabledReasonEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
