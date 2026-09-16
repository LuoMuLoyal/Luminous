//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_sequence_response_targets.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineSequenceResponseTargets {
  /// Returns a new [MedicineSequenceResponseTargets] instance.
  MedicineSequenceResponseTargets({
    required this.uniprotId,

    required this.targetName,

    required this.dataset,

    required this.length,

    required this.sequence,
  });

  /// UniProt identifier of the target.
  @JsonKey(name: r'uniprotId', required: true, includeIfNull: false)
  final String uniprotId;

  @JsonKey(name: r'targetName', required: true, includeIfNull: true)
  final String? targetName;

  /// Which sequence this is: protein_fasta or gene_fasta.
  @JsonKey(name: r'dataset', required: true, includeIfNull: false)
  final String dataset;

  /// Residue (protein) or base (gene) count.
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'length', required: true, includeIfNull: false)
  final int length;

  /// Sequence content.
  @JsonKey(name: r'sequence', required: true, includeIfNull: false)
  final String sequence;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineSequenceResponseTargets &&
          other.uniprotId == uniprotId &&
          other.targetName == targetName &&
          other.dataset == dataset &&
          other.length == length &&
          other.sequence == sequence;

  @override
  int get hashCode =>
      uniprotId.hashCode +
      (targetName == null ? 0 : targetName.hashCode) +
      dataset.hashCode +
      length.hashCode +
      sequence.hashCode;

  factory MedicineSequenceResponseTargets.fromJson(Map<String, dynamic> json) =>
      _$MedicineSequenceResponseTargetsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineSequenceResponseTargetsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
