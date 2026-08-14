//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clinic_summary_share_scope_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClinicSummaryShareScopeDto {
  /// Returns a new [ClinicSummaryShareScopeDto] instance.
  ClinicSummaryShareScopeDto({
    required this.eventId,

    required this.dateFrom,

    required this.dateTo,
  });

  /// Event scope id
  @JsonKey(name: r'eventId', required: true, includeIfNull: true)
  final String? eventId;

  /// Date-range scope start (ISO 8601), or null for an event scope
  @JsonKey(name: r'dateFrom', required: true, includeIfNull: true)
  final String? dateFrom;

  /// Date-range scope end (ISO 8601), or null for an event scope
  @JsonKey(name: r'dateTo', required: true, includeIfNull: true)
  final String? dateTo;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicSummaryShareScopeDto &&
          other.eventId == eventId &&
          other.dateFrom == dateFrom &&
          other.dateTo == dateTo;

  @override
  int get hashCode =>
      (eventId == null ? 0 : eventId.hashCode) +
      (dateFrom == null ? 0 : dateFrom.hashCode) +
      (dateTo == null ? 0 : dateTo.hashCode);

  factory ClinicSummaryShareScopeDto.fromJson(Map<String, dynamic> json) =>
      _$ClinicSummaryShareScopeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ClinicSummaryShareScopeDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
