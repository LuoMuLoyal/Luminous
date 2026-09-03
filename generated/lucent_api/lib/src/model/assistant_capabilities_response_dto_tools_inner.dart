//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_capabilities_response_dto_tools_inner.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantCapabilitiesResponseDtoToolsInner {
  /// Returns a new [AssistantCapabilitiesResponseDtoToolsInner] instance.
  AssistantCapabilitiesResponseDtoToolsInner({
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
    unknownEnumValue: AssistantCapabilitiesResponseDtoToolsInnerNameEnum
        .unknownDefaultOpenApi,
  )
  final AssistantCapabilitiesResponseDtoToolsInnerNameEnum name;

  /// Context sources this tool requires before it may run. Allowed values: health_profile, daily_records, sleep_records, current_medicines.
  @JsonKey(
    name: r'requiredContextSources',
    required: true,
    includeIfNull: false,
  )
  final List<
    AssistantCapabilitiesResponseDtoToolsInnerRequiredContextSourcesEnum
  >
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

  @JsonKey(
    name: r'disabledReason',
    required: true,
    includeIfNull: true,
    unknownEnumValue:
        AssistantCapabilitiesResponseDtoToolsInnerDisabledReasonEnum
            .unknownDefaultOpenApi,
  )
  final AssistantCapabilitiesResponseDtoToolsInnerDisabledReasonEnum?
  disabledReason;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssistantCapabilitiesResponseDtoToolsInner &&
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

  factory AssistantCapabilitiesResponseDtoToolsInner.fromJson(
    Map<String, dynamic> json,
  ) => _$AssistantCapabilitiesResponseDtoToolsInnerFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AssistantCapabilitiesResponseDtoToolsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Stable tool identifier exposed to the client.
enum AssistantCapabilitiesResponseDtoToolsInnerNameEnum {
  @JsonValue(r'get_today_records')
  getTodayRecords(r'get_today_records'),
  @JsonValue(r'get_records_by_date')
  getRecordsByDate(r'get_records_by_date'),
  @JsonValue(r'get_records_by_range')
  getRecordsByRange(r'get_records_by_range'),
  @JsonValue(r'get_today_summary_by_date')
  getTodaySummaryByDate(r'get_today_summary_by_date'),
  @JsonValue(r'get_report_summary_by_range')
  getReportSummaryByRange(r'get_report_summary_by_range'),
  @JsonValue(r'get_recent_today_summaries')
  getRecentTodaySummaries(r'get_recent_today_summaries'),
  @JsonValue(r'get_recent_report_summaries')
  getRecentReportSummaries(r'get_recent_report_summaries'),
  @JsonValue(r'get_user_profile')
  getUserProfile(r'get_user_profile'),
  @JsonValue(r'get_user_settings')
  getUserSettings(r'get_user_settings'),
  @JsonValue(r'get_current_medicines')
  getCurrentMedicines(r'get_current_medicines'),
  @JsonValue(r'get_sleep_summary_by_range')
  getSleepSummaryByRange(r'get_sleep_summary_by_range'),
  @JsonValue(r'search_cn_medicine_products')
  searchCnMedicineProducts(r'search_cn_medicine_products'),
  @JsonValue(r'get_cn_medicine_detail')
  getCnMedicineDetail(r'get_cn_medicine_detail'),
  @JsonValue(r'search_medicine_leaflets')
  searchMedicineLeaflets(r'search_medicine_leaflets'),
  @JsonValue(r'search_medical_qa_corpus')
  searchMedicalQaCorpus(r'search_medical_qa_corpus'),
  @JsonValue(r'resolve_drugbank_entity')
  resolveDrugbankEntity(r'resolve_drugbank_entity'),
  @JsonValue(r'get_drugbank_detail')
  getDrugbankDetail(r'get_drugbank_detail'),
  @JsonValue(r'search_drugbank_passages')
  searchDrugbankPassages(r'search_drugbank_passages'),
  @JsonValue(r'propose_create_daily_record')
  proposeCreateDailyRecord(r'propose_create_daily_record'),
  @JsonValue(r'propose_update_daily_record')
  proposeUpdateDailyRecord(r'propose_update_daily_record'),
  @JsonValue(r'propose_delete_daily_record')
  proposeDeleteDailyRecord(r'propose_delete_daily_record'),
  @JsonValue(r'propose_update_user_settings')
  proposeUpdateUserSettings(r'propose_update_user_settings'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const AssistantCapabilitiesResponseDtoToolsInnerNameEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum AssistantCapabilitiesResponseDtoToolsInnerRequiredContextSourcesEnum {
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

  const AssistantCapabilitiesResponseDtoToolsInnerRequiredContextSourcesEnum(
    this.value,
  );

  final String value;

  @override
  String toString() => value;
}

enum AssistantCapabilitiesResponseDtoToolsInnerDisabledReasonEnum {
  @JsonValue(r'chat_disabled')
  chatDisabled(r'chat_disabled'),
  @JsonValue(r'context_disabled')
  contextDisabled(r'context_disabled'),
  @JsonValue(r'model_not_configured')
  modelNotConfigured(r'model_not_configured'),
  @JsonValue(r'not_implemented')
  notImplemented(r'not_implemented'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const AssistantCapabilitiesResponseDtoToolsInnerDisabledReasonEnum(
    this.value,
  );

  final String value;

  @override
  String toString() => value;
}
