//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/clinic_summary_response_conditions.dart';
import 'package:lucent_api/src/model/clinic_summary_response_coverage.dart';
import 'package:lucent_api/src/model/clinic_summary_response_note_entries.dart';
import 'package:lucent_api/src/model/clinic_summary_response_current_medicines.dart';
import 'package:lucent_api/src/model/clinic_summary_response_sleep_entries.dart';
import 'package:lucent_api/src/model/clinic_summary_response_allergies.dart';
import 'package:lucent_api/src/model/clinic_summary_response_profile.dart';
import 'package:lucent_api/src/model/clinic_summary_response_water_entries.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clinic_summary_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClinicSummaryResponse {
  /// Returns a new [ClinicSummaryResponse] instance.
  ClinicSummaryResponse({
    required this.generatedAt,

    required this.scopeLabel,

    required this.start,

    required this.end,

    required this.selectedFields,

    required this.coverage,

    required this.dataRange,

    this.profile,

    this.allergies,

    this.conditions,

    this.currentMedicines,

    this.findings,

    this.waterEntries,

    this.sleepEntries,

    this.noteEntries,

    required this.disclaimer,
  });

  /// Generated timestamp
  @JsonKey(name: r'generatedAt', required: true, includeIfNull: false)
  final String generatedAt;

  /// Scope label: last_7_days | last_30_days | custom for date-range scopes, or the event title for an event scope.
  @JsonKey(name: r'scopeLabel', required: true, includeIfNull: false)
  final String scopeLabel;

  /// Real window start (ISO 8601).
  @JsonKey(name: r'start', required: true, includeIfNull: false)
  final String start;

  /// Real window end (ISO 8601).
  @JsonKey(name: r'end', required: true, includeIfNull: false)
  final String end;

  /// Effective included sections after field selection (profile/allergies/conditions/currentMedicines).
  @JsonKey(name: r'selectedFields', required: true, includeIfNull: false)
  final List<String> selectedFields;

  @JsonKey(name: r'coverage', required: true, includeIfNull: false)
  final ClinicSummaryResponseCoverage coverage;

  /// Legacy range label (last_7_days | last_30_days | custom | event); kept as a compatibility alias of scopeLabel.
  @JsonKey(name: r'dataRange', required: true, includeIfNull: false)
  final String dataRange;

  @JsonKey(name: r'profile', required: false, includeIfNull: false)
  final ClinicSummaryResponseProfile? profile;

  /// Active allergies. Optional: omitted when the section is deselected.
  @JsonKey(name: r'allergies', required: false, includeIfNull: false)
  final List<ClinicSummaryResponseAllergies>? allergies;

  /// Active conditions. Optional: omitted when the section is deselected.
  @JsonKey(name: r'conditions', required: false, includeIfNull: false)
  final List<ClinicSummaryResponseConditions>? conditions;

  /// Current medicines. Optional: omitted when the section is deselected.
  @JsonKey(name: r'currentMedicines', required: false, includeIfNull: false)
  final List<ClinicSummaryResponseCurrentMedicines>? currentMedicines;

  /// Structured facts and change codes reused from the event review (e.g. health_event, observed_changes, no_completed_actions, active_check_in). `insufficient_coverage` is the fixed 资料不足 statement — no generic AI conclusions are ever added. Controlled by the `event_overview` field toggle (R-2): omitted when the field is deselected.
  @JsonKey(name: r'findings', required: false, includeIfNull: false)
  final List<String>? findings;

  /// Daily water intake facts (only records with a parsable ml value). Controlled by the `water` field toggle (R-2): omitted when the field is deselected.
  @JsonKey(name: r'waterEntries', required: false, includeIfNull: false)
  final List<ClinicSummaryResponseWaterEntries>? waterEntries;

  /// Daily sleep duration facts (only records with a positive duration). Controlled by the `sleep` field toggle (R-2): omitted when the field is deselected.
  @JsonKey(name: r'sleepEntries', required: false, includeIfNull: false)
  final List<ClinicSummaryResponseSleepEntries>? sleepEntries;

  /// Free-text note records (date, kind, original text). Controlled by the `notes` field toggle (R-2): omitted when the field is deselected. Defaults to off — the user must explicitly opt in.
  @JsonKey(name: r'noteEntries', required: false, includeIfNull: false)
  final List<ClinicSummaryResponseNoteEntries>? noteEntries;

  /// Disclaimer text
  @JsonKey(name: r'disclaimer', required: true, includeIfNull: false)
  final String disclaimer;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicSummaryResponse &&
          other.generatedAt == generatedAt &&
          other.scopeLabel == scopeLabel &&
          other.start == start &&
          other.end == end &&
          other.selectedFields == selectedFields &&
          other.coverage == coverage &&
          other.dataRange == dataRange &&
          other.profile == profile &&
          other.allergies == allergies &&
          other.conditions == conditions &&
          other.currentMedicines == currentMedicines &&
          other.findings == findings &&
          other.waterEntries == waterEntries &&
          other.sleepEntries == sleepEntries &&
          other.noteEntries == noteEntries &&
          other.disclaimer == disclaimer;

  @override
  int get hashCode =>
      generatedAt.hashCode +
      scopeLabel.hashCode +
      start.hashCode +
      end.hashCode +
      selectedFields.hashCode +
      coverage.hashCode +
      dataRange.hashCode +
      profile.hashCode +
      allergies.hashCode +
      conditions.hashCode +
      currentMedicines.hashCode +
      findings.hashCode +
      waterEntries.hashCode +
      sleepEntries.hashCode +
      noteEntries.hashCode +
      disclaimer.hashCode;

  factory ClinicSummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$ClinicSummaryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ClinicSummaryResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
