//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clinic_summary_response_current_medicines.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClinicSummaryResponseCurrentMedicines {
  /// Returns a new [ClinicSummaryResponseCurrentMedicines] instance.
  ClinicSummaryResponseCurrentMedicines({
    required this.displayName,

    this.doseText,
  });

  /// Generic medicine name
  @JsonKey(name: r'displayName', required: true, includeIfNull: false)
  final String displayName;

  @JsonKey(name: r'doseText', required: false, includeIfNull: false)
  final String? doseText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicSummaryResponseCurrentMedicines &&
          other.displayName == displayName &&
          other.doseText == doseText;

  @override
  int get hashCode =>
      displayName.hashCode + (doseText == null ? 0 : doseText.hashCode);

  factory ClinicSummaryResponseCurrentMedicines.fromJson(
    Map<String, dynamic> json,
  ) => _$ClinicSummaryResponseCurrentMedicinesFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ClinicSummaryResponseCurrentMedicinesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
