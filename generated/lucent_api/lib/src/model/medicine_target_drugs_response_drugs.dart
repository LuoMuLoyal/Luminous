//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_target_drugs_response_drugs.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineTargetDrugsResponseDrugs {
  /// Returns a new [MedicineTargetDrugsResponseDrugs] instance.
  MedicineTargetDrugsResponseDrugs({
    required this.drugbankId,

    required this.name,

    required this.relation,
  });

  /// DrugBank id of a drug acting on the target.
  @JsonKey(name: r'drugbankId', required: true, includeIfNull: false)
  final String drugbankId;

  /// Drug display name.
  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  /// Relation type to the target.
  @JsonKey(name: r'relation', required: true, includeIfNull: false)
  final String relation;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineTargetDrugsResponseDrugs &&
          other.drugbankId == drugbankId &&
          other.name == name &&
          other.relation == relation;

  @override
  int get hashCode => drugbankId.hashCode + name.hashCode + relation.hashCode;

  factory MedicineTargetDrugsResponseDrugs.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineTargetDrugsResponseDrugsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineTargetDrugsResponseDrugsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
