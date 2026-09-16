//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_sequence_response_drug.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineSequenceResponseDrug {
  /// Returns a new [MedicineSequenceResponseDrug] instance.
  MedicineSequenceResponseDrug({
    required this.description,

    required this.length,

    required this.sequence,
  });

  /// Chain description exactly as the source header spells it, e.g. \"heavy chain\".
  @JsonKey(name: r'description', required: true, includeIfNull: false)
  final String description;

  /// Residue count.
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'length', required: true, includeIfNull: false)
  final int length;

  /// Amino-acid sequence.
  @JsonKey(name: r'sequence', required: true, includeIfNull: false)
  final String sequence;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineSequenceResponseDrug &&
          other.description == description &&
          other.length == length &&
          other.sequence == sequence;

  @override
  int get hashCode =>
      description.hashCode + length.hashCode + sequence.hashCode;

  factory MedicineSequenceResponseDrug.fromJson(Map<String, dynamic> json) =>
      _$MedicineSequenceResponseDrugFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineSequenceResponseDrugToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
