//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_detail_response_dto_detail_one_of_drug_interactions_inner.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineDetailResponseDtoDetailOneOfDrugInteractionsInner {
  /// Returns a new [MedicineDetailResponseDtoDetailOneOfDrugInteractionsInner] instance.
  MedicineDetailResponseDtoDetailOneOfDrugInteractionsInner({
    required this.drugbankId,

    required this.description,
  });

  /// Interacting DrugBank drug id.
  @JsonKey(name: r'drugbankId', required: true, includeIfNull: false)
  final String drugbankId;

  /// Interaction description.
  @JsonKey(name: r'description', required: true, includeIfNull: false)
  final String description;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineDetailResponseDtoDetailOneOfDrugInteractionsInner &&
          other.drugbankId == drugbankId &&
          other.description == description;

  @override
  int get hashCode => drugbankId.hashCode + description.hashCode;

  factory MedicineDetailResponseDtoDetailOneOfDrugInteractionsInner.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$MedicineDetailResponseDtoDetailOneOfDrugInteractionsInnerFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineDetailResponseDtoDetailOneOfDrugInteractionsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
