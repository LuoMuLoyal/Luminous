//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'preview_clinic_summary_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PreviewClinicSummaryRequest {
  /// Returns a new [PreviewClinicSummaryRequest] instance.
  PreviewClinicSummaryRequest({
    this.eventId,

    this.dateFrom,

    this.dateTo,

    this.selectedFields,
  });

  /// Event scope: build the summary from this event review. Wins over dateFrom/dateTo when both are supplied.
  @JsonKey(name: r'eventId', required: false, includeIfNull: false)
  final String? eventId;

  /// Date-range scope start (ISO 8601 date, YYYY-MM-DD). Both dates are required whenever a date range is given (a partial pair is rejected); ignored when eventId is present. When neither eventId nor a date range is supplied, the summary falls back to the default last_30_days range (legacy semantics).
  @JsonKey(name: r'dateFrom', required: false, includeIfNull: false)
  final String? dateFrom;

  /// Date-range scope end (ISO 8601 date, YYYY-MM-DD). Inclusive calendar day; both dates required whenever a date range is given; span must cover at most 30 inclusive calendar days. When neither eventId nor a date range is supplied, the summary falls back to the default last_30_days range (legacy semantics).
  @JsonKey(name: r'dateTo', required: false, includeIfNull: false)
  final String? dateTo;

  /// Summary sections to include. Empty arrays and unknown values are rejected; when omitted every section is included.
  @JsonKey(name: r'selectedFields', required: false, includeIfNull: false)
  final List<PreviewClinicSummaryRequestSelectedFieldsEnum>? selectedFields;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PreviewClinicSummaryRequest &&
          other.eventId == eventId &&
          other.dateFrom == dateFrom &&
          other.dateTo == dateTo &&
          other.selectedFields == selectedFields;

  @override
  int get hashCode =>
      eventId.hashCode +
      dateFrom.hashCode +
      dateTo.hashCode +
      selectedFields.hashCode;

  factory PreviewClinicSummaryRequest.fromJson(Map<String, dynamic> json) =>
      _$PreviewClinicSummaryRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PreviewClinicSummaryRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum PreviewClinicSummaryRequestSelectedFieldsEnum {
  @JsonValue(r'event_overview')
  eventOverview(r'event_overview'),
  @JsonValue(r'symptom_changes')
  symptomChanges(r'symptom_changes'),
  @JsonValue(r'medication_slots')
  medicationSlots(r'medication_slots'),
  @JsonValue(r'water')
  water(r'water'),
  @JsonValue(r'sleep')
  sleep(r'sleep'),
  @JsonValue(r'notes')
  notes(r'notes'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const PreviewClinicSummaryRequestSelectedFieldsEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
