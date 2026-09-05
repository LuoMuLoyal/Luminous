//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clinic_summary_response_allergies.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClinicSummaryResponseAllergies {
  /// Returns a new [ClinicSummaryResponseAllergies] instance.
  ClinicSummaryResponseAllergies({
    required this.label,

    required this.reaction,

    required this.severity,
  });

  /// Allergy label (e.g. 青霉素)
  @JsonKey(name: r'label', required: true, includeIfNull: false)
  final String label;

  @JsonKey(name: r'reaction', required: true, includeIfNull: true)
  final String? reaction;

  @JsonKey(name: r'severity', required: true, includeIfNull: true)
  final String? severity;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicSummaryResponseAllergies &&
          other.label == label &&
          other.reaction == reaction &&
          other.severity == severity;

  @override
  int get hashCode =>
      label.hashCode +
      (reaction == null ? 0 : reaction.hashCode) +
      (severity == null ? 0 : severity.hashCode);

  factory ClinicSummaryResponseAllergies.fromJson(Map<String, dynamic> json) =>
      _$ClinicSummaryResponseAllergiesFromJson(json);

  Map<String, dynamic> toJson() => _$ClinicSummaryResponseAllergiesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
