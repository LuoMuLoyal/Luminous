//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clinic_summary_response_dto_water_entries_inner.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClinicSummaryResponseDtoWaterEntriesInner {
  /// Returns a new [ClinicSummaryResponseDtoWaterEntriesInner] instance.
  ClinicSummaryResponseDtoWaterEntriesInner({
    required this.date,

    required this.ml,
  });

  /// Calendar date in YYYY-MM-DD format.
  @JsonKey(name: r'date', required: true, includeIfNull: false)
  final String date;

  /// Water intake in milliliters.
  @JsonKey(name: r'ml', required: true, includeIfNull: false)
  final num ml;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicSummaryResponseDtoWaterEntriesInner &&
          other.date == date &&
          other.ml == ml;

  @override
  int get hashCode => date.hashCode + ml.hashCode;

  factory ClinicSummaryResponseDtoWaterEntriesInner.fromJson(
    Map<String, dynamic> json,
  ) => _$ClinicSummaryResponseDtoWaterEntriesInnerFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ClinicSummaryResponseDtoWaterEntriesInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
