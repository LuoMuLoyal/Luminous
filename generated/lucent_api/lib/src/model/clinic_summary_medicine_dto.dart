//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clinic_summary_medicine_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClinicSummaryMedicineDto {
  /// Returns a new [ClinicSummaryMedicineDto] instance.
  ClinicSummaryMedicineDto({required this.displayName, this.doseText});

  /// Generic medicine name
  @JsonKey(name: r'displayName', required: true, includeIfNull: false)
  final String displayName;

  /// Dose instruction
  @JsonKey(name: r'doseText', required: false, includeIfNull: false)
  final String? doseText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicSummaryMedicineDto &&
          other.displayName == displayName &&
          other.doseText == doseText;

  @override
  int get hashCode =>
      displayName.hashCode + (doseText == null ? 0 : doseText.hashCode);

  factory ClinicSummaryMedicineDto.fromJson(Map<String, dynamic> json) =>
      _$ClinicSummaryMedicineDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ClinicSummaryMedicineDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
