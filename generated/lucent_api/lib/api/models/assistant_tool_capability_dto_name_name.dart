// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// Stable tool identifier exposed to the client.
@JsonEnum()
enum AssistantToolCapabilityDtoNameName {
  @JsonValue('get_today_records')
  getTodayRecords('get_today_records'),
  @JsonValue('get_records_by_date')
  getRecordsByDate('get_records_by_date'),
  @JsonValue('get_records_by_range')
  getRecordsByRange('get_records_by_range'),
  @JsonValue('get_today_summary_by_date')
  getTodaySummaryByDate('get_today_summary_by_date'),
  @JsonValue('get_report_summary_by_range')
  getReportSummaryByRange('get_report_summary_by_range'),
  @JsonValue('get_recent_today_summaries')
  getRecentTodaySummaries('get_recent_today_summaries'),
  @JsonValue('get_recent_report_summaries')
  getRecentReportSummaries('get_recent_report_summaries'),
  @JsonValue('get_user_profile')
  getUserProfile('get_user_profile'),
  @JsonValue('get_user_settings')
  getUserSettings('get_user_settings'),
  @JsonValue('get_current_medicines')
  getCurrentMedicines('get_current_medicines'),
  @JsonValue('get_sleep_summary_by_range')
  getSleepSummaryByRange('get_sleep_summary_by_range'),
  @JsonValue('search_cn_medicine_products')
  searchCnMedicineProducts('search_cn_medicine_products'),
  @JsonValue('get_cn_medicine_detail')
  getCnMedicineDetail('get_cn_medicine_detail'),
  @JsonValue('search_medicine_leaflets')
  searchMedicineLeaflets('search_medicine_leaflets'),
  @JsonValue('search_medical_qa_corpus')
  searchMedicalQaCorpus('search_medical_qa_corpus'),
  @JsonValue('resolve_drugbank_entity')
  resolveDrugbankEntity('resolve_drugbank_entity'),
  @JsonValue('get_drugbank_detail')
  getDrugbankDetail('get_drugbank_detail'),
  @JsonValue('search_drugbank_passages')
  searchDrugbankPassages('search_drugbank_passages'),
  @JsonValue('propose_create_daily_record')
  proposeCreateDailyRecord('propose_create_daily_record'),
  @JsonValue('propose_update_daily_record')
  proposeUpdateDailyRecord('propose_update_daily_record'),
  @JsonValue('propose_delete_daily_record')
  proposeDeleteDailyRecord('propose_delete_daily_record'),
  @JsonValue('propose_update_user_settings')
  proposeUpdateUserSettings('propose_update_user_settings'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const AssistantToolCapabilityDtoNameName(this.json);

  factory AssistantToolCapabilityDtoNameName.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  String toJson() => json ?? 'null';

  @override
  String toString() => json ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<AssistantToolCapabilityDtoNameName> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
