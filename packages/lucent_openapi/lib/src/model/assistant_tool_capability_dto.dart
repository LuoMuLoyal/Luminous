//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'assistant_tool_capability_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantToolCapabilityDto {
  /// Returns a new [AssistantToolCapabilityDto] instance.
  AssistantToolCapabilityDto({
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
    unknownEnumValue: AssistantToolCapabilityDtoNameEnum.unknownDefaultOpenApi,
  )
  final AssistantToolCapabilityDtoNameEnum name;

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
        AssistantToolCapabilityDtoDisabledReasonEnum.unknownDefaultOpenApi,
  )
  final AssistantToolCapabilityDtoDisabledReasonEnum? disabledReason;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssistantToolCapabilityDto &&
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

  factory AssistantToolCapabilityDto.fromJson(Map<String, dynamic> json) =>
      _$AssistantToolCapabilityDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantToolCapabilityDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Stable tool identifier exposed to the client.
enum AssistantToolCapabilityDtoNameEnum {
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
  @JsonValue(r'get_today_summary_by_date')
  getTodaySummaryByDate(r'get_today_summary_by_date'),

  /// Stable tool identifier exposed to the client.
  @JsonValue(r'get_report_summary_by_range')
  getReportSummaryByRange(r'get_report_summary_by_range'),

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
  @JsonValue(r'get_medicine_leaflet_context')
  getMedicineLeafletContext(r'get_medicine_leaflet_context'),

  /// Stable tool identifier exposed to the client.
  @JsonValue(r'propose_create_daily_record')
  proposeCreateDailyRecord(r'propose_create_daily_record'),

  /// Stable tool identifier exposed to the client.
  @JsonValue(r'propose_update_daily_record')
  proposeUpdateDailyRecord(r'propose_update_daily_record'),

  /// Stable tool identifier exposed to the client.
  @JsonValue(r'propose_delete_daily_record')
  proposeDeleteDailyRecord(r'propose_delete_daily_record'),

  /// Stable tool identifier exposed to the client.
  @JsonValue(r'propose_update_user_settings')
  proposeUpdateUserSettings(r'propose_update_user_settings'),

  /// Stable tool identifier exposed to the client.
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const AssistantToolCapabilityDtoNameEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Why the tool is currently disabled, or null when enabled.
enum AssistantToolCapabilityDtoDisabledReasonEnum {
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

  const AssistantToolCapabilityDtoDisabledReasonEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
