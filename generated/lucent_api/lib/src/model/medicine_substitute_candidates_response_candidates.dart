//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_substitute_candidates_response_candidates.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineSubstituteCandidatesResponseCandidates {
  /// Returns a new [MedicineSubstituteCandidatesResponseCandidates] instance.
  MedicineSubstituteCandidatesResponseCandidates({
    required this.drugbankId,

    required this.name,

    required this.sharedTarget,
  });

  /// Candidate DrugBank id.
  @JsonKey(name: r'drugbankId', required: true, includeIfNull: false)
  final String drugbankId;

  /// Candidate display name.
  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  /// Target shared with the source drug (the structural reason for candidacy).
  @JsonKey(name: r'sharedTarget', required: true, includeIfNull: true)
  final String? sharedTarget;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineSubstituteCandidatesResponseCandidates &&
          other.drugbankId == drugbankId &&
          other.name == name &&
          other.sharedTarget == sharedTarget;

  @override
  int get hashCode =>
      drugbankId.hashCode +
      name.hashCode +
      (sharedTarget == null ? 0 : sharedTarget.hashCode);

  factory MedicineSubstituteCandidatesResponseCandidates.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineSubstituteCandidatesResponseCandidatesFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineSubstituteCandidatesResponseCandidatesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
