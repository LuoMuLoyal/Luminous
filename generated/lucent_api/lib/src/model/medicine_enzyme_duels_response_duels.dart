//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_enzyme_duels_response_duels.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineEnzymeDuelsResponseDuels {
  /// Returns a new [MedicineEnzymeDuelsResponseDuels] instance.
  MedicineEnzymeDuelsResponseDuels({
    required this.enzymeGene,

    required this.inducerDrug,

    required this.inhibitedSubstrate,
  });

  /// Enzyme where induction and metabolism meet.
  @JsonKey(name: r'enzymeGene', required: true, includeIfNull: false)
  final String enzymeGene;

  /// Drug inducing the enzyme (lowers substrate exposure).
  @JsonKey(name: r'inducerDrug', required: true, includeIfNull: false)
  final String inducerDrug;

  /// Substrate drug whose exposure falls.
  @JsonKey(name: r'inhibitedSubstrate', required: true, includeIfNull: false)
  final String inhibitedSubstrate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineEnzymeDuelsResponseDuels &&
          other.enzymeGene == enzymeGene &&
          other.inducerDrug == inducerDrug &&
          other.inhibitedSubstrate == inhibitedSubstrate;

  @override
  int get hashCode =>
      enzymeGene.hashCode + inducerDrug.hashCode + inhibitedSubstrate.hashCode;

  factory MedicineEnzymeDuelsResponseDuels.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineEnzymeDuelsResponseDuelsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineEnzymeDuelsResponseDuelsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
