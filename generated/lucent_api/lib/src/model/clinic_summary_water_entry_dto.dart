//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clinic_summary_water_entry_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClinicSummaryWaterEntryDto {
  /// Returns a new [ClinicSummaryWaterEntryDto] instance.
  ClinicSummaryWaterEntryDto({required this.date, required this.ml});

  /// Calendar date in YYYY-MM-DD format.
  @JsonKey(name: r'date', required: true, includeIfNull: false)
  final String date;

  /// Water intake in milliliters.
  @JsonKey(name: r'ml', required: true, includeIfNull: false)
  final num ml;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicSummaryWaterEntryDto &&
          other.date == date &&
          other.ml == ml;

  @override
  int get hashCode => date.hashCode + ml.hashCode;

  factory ClinicSummaryWaterEntryDto.fromJson(Map<String, dynamic> json) =>
      _$ClinicSummaryWaterEntryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ClinicSummaryWaterEntryDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
