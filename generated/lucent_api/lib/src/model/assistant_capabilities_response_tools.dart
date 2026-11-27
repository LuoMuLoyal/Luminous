//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_capabilities_response_tools.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantCapabilitiesResponseTools {
  /// Returns a new [AssistantCapabilitiesResponseTools] instance.
  AssistantCapabilitiesResponseTools({
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
    unknownEnumValue:
        AssistantCapabilitiesResponseToolsNameEnum.unknownDefaultOpenApi,
  )
  final AssistantCapabilitiesResponseToolsNameEnum name;

  /// Context sources this tool requires before it may run. Allowed values: health_profile, daily_records, sleep_records, current_medicines.
  @JsonKey(
    name: r'requiredContextSources',
    required: true,
    includeIfNull: false,
  )
  final List<AssistantCapabilitiesResponseToolsRequiredContextSourcesEnum>
  requiredContextSources;

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
    unknownEnumValue: AssistantCapabilitiesResponseToolsDisabledReasonEnum
        .unknownDefaultOpenApi,
  )
  final AssistantCapabilitiesResponseToolsDisabledReasonEnum? disabledReason;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssistantCapabilitiesResponseTools &&
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

  factory AssistantCapabilitiesResponseTools.fromJson(
    Map<String, dynamic> json,
  ) => _$AssistantCapabilitiesResponseToolsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AssistantCapabilitiesResponseToolsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Stable tool identifier exposed to the client.
enum AssistantCapabilitiesResponseToolsNameEnum {
  @JsonValue(r'get_today_records')
  getTodayRecords(r'get_today_records'),
  @JsonValue(r'get_records_by_date')
  getRecordsByDate(r'get_records_by_date'),
  @JsonValue(r'get_records_by_range')
  getRecordsByRange(r'get_records_by_range'),
  @JsonValue(r'get_today_summary')
  getTodaySummary(r'get_today_summary'),
  @JsonValue(r'get_report_summary')
  getReportSummary(r'get_report_summary'),
  @JsonValue(r'get_today_summaries')
  getTodaySummaries(r'get_today_summaries'),
  @JsonValue(r'get_report_summaries')
  getReportSummaries(r'get_report_summaries'),
  @JsonValue(r'get_user_profile')
  getUserProfile(r'get_user_profile'),
  @JsonValue(r'get_user_settings')
  getUserSettings(r'get_user_settings'),
  @JsonValue(r'get_medicines')
  getMedicines(r'get_medicines'),
  @JsonValue(r'get_sleep_summary')
  getSleepSummary(r'get_sleep_summary'),
  @JsonValue(r'get_meal_digest')
  getMealDigest(r'get_meal_digest'),
  @JsonValue(r'search_cn_products')
  searchCnProducts(r'search_cn_products'),
  @JsonValue(r'get_cn_product_detail')
  getCnProductDetail(r'get_cn_product_detail'),
  @JsonValue(r'search_cn_knowledge')
  searchCnKnowledge(r'search_cn_knowledge'),
  @JsonValue(r'resolve_drugbank')
  resolveDrugbank(r'resolve_drugbank'),
  @JsonValue(r'get_drugbank_detail')
  getDrugbankDetail(r'get_drugbank_detail'),
  @JsonValue(r'search_drugbank')
  searchDrugbank(r'search_drugbank'),
  @JsonValue(r'search_adverse_reactions')
  searchAdverseReactions(r'search_adverse_reactions'),
  @JsonValue(r'reason_ontology')
  reasonOntology(r'reason_ontology'),
  @JsonValue(r'reason_rules')
  reasonRules(r'reason_rules'),
  @JsonValue(r'create_record_draft')
  createRecordDraft(r'create_record_draft'),
  @JsonValue(r'update_record_draft')
  updateRecordDraft(r'update_record_draft'),
  @JsonValue(r'delete_record_draft')
  deleteRecordDraft(r'delete_record_draft'),
  @JsonValue(r'update_settings_draft')
  updateSettingsDraft(r'update_settings_draft'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const AssistantCapabilitiesResponseToolsNameEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum AssistantCapabilitiesResponseToolsRequiredContextSourcesEnum {
  @JsonValue(r'health_profile')
  healthProfile(r'health_profile'),
  @JsonValue(r'daily_records')
  dailyRecords(r'daily_records'),
  @JsonValue(r'sleep_records')
  sleepRecords(r'sleep_records'),
  @JsonValue(r'current_medicines')
  currentMedicines(r'current_medicines'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const AssistantCapabilitiesResponseToolsRequiredContextSourcesEnum(
    this.value,
  );

  final String value;

  @override
  String toString() => value;
}

/// Why the tool is currently disabled, or null when enabled.
enum AssistantCapabilitiesResponseToolsDisabledReasonEnum {
  @JsonValue(r'chat_disabled')
  chatDisabled(r'chat_disabled'),
  @JsonValue(r'context_disabled')
  contextDisabled(r'context_disabled'),
  @JsonValue(r'model_not_configured')
  modelNotConfigured(r'model_not_configured'),
  @JsonValue(r'not_implemented')
  notImplemented(r'not_implemented'),
  @JsonValue(r'retrieval_unavailable')
  retrievalUnavailable(r'retrieval_unavailable'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const AssistantCapabilitiesResponseToolsDisabledReasonEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
