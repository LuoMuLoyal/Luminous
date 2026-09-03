//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clinic_summary_share_response_dto_scope.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClinicSummaryShareResponseDtoScope {
  /// Returns a new [ClinicSummaryShareResponseDtoScope] instance.
  ClinicSummaryShareResponseDtoScope({
    required this.eventId,

    required this.dateFrom,

    required this.dateTo,
  });

  @JsonKey(name: r'eventId', required: true, includeIfNull: true)
  final String? eventId;

  @JsonKey(name: r'dateFrom', required: true, includeIfNull: true)
  final String? dateFrom;

  @JsonKey(name: r'dateTo', required: true, includeIfNull: true)
  final String? dateTo;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicSummaryShareResponseDtoScope &&
          other.eventId == eventId &&
          other.dateFrom == dateFrom &&
          other.dateTo == dateTo;

  @override
  int get hashCode =>
      (eventId == null ? 0 : eventId.hashCode) +
      (dateFrom == null ? 0 : dateFrom.hashCode) +
      (dateTo == null ? 0 : dateTo.hashCode);

  factory ClinicSummaryShareResponseDtoScope.fromJson(
    Map<String, dynamic> json,
  ) => _$ClinicSummaryShareResponseDtoScopeFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ClinicSummaryShareResponseDtoScopeToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
