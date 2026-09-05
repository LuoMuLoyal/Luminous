//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clinic_summary_response_water_entries.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClinicSummaryResponseWaterEntries {
  /// Returns a new [ClinicSummaryResponseWaterEntries] instance.
  ClinicSummaryResponseWaterEntries({required this.date, required this.ml});

  /// Calendar date in YYYY-MM-DD format.
  @JsonKey(name: r'date', required: true, includeIfNull: false)
  final String date;

  /// Water intake in milliliters.
  @JsonKey(name: r'ml', required: true, includeIfNull: false)
  final num ml;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicSummaryResponseWaterEntries &&
          other.date == date &&
          other.ml == ml;

  @override
  int get hashCode => date.hashCode + ml.hashCode;

  factory ClinicSummaryResponseWaterEntries.fromJson(
    Map<String, dynamic> json,
  ) => _$ClinicSummaryResponseWaterEntriesFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ClinicSummaryResponseWaterEntriesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
