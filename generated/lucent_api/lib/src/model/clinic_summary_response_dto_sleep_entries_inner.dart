//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clinic_summary_response_dto_sleep_entries_inner.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClinicSummaryResponseDtoSleepEntriesInner {
  /// Returns a new [ClinicSummaryResponseDtoSleepEntriesInner] instance.
  ClinicSummaryResponseDtoSleepEntriesInner({
    required this.date,

    required this.minutes,
  });

  /// Calendar date in YYYY-MM-DD format.
  @JsonKey(name: r'date', required: true, includeIfNull: false)
  final String date;

  /// Sleep duration in minutes.
  @JsonKey(name: r'minutes', required: true, includeIfNull: false)
  final num minutes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicSummaryResponseDtoSleepEntriesInner &&
          other.date == date &&
          other.minutes == minutes;

  @override
  int get hashCode => date.hashCode + minutes.hashCode;

  factory ClinicSummaryResponseDtoSleepEntriesInner.fromJson(
    Map<String, dynamic> json,
  ) => _$ClinicSummaryResponseDtoSleepEntriesInnerFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ClinicSummaryResponseDtoSleepEntriesInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
