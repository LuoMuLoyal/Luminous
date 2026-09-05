//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_detail_response_drug_interactions.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineDetailResponseDrugInteractions {
  /// Returns a new [MedicineDetailResponseDrugInteractions] instance.
  MedicineDetailResponseDrugInteractions({
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
      other is MedicineDetailResponseDrugInteractions &&
          other.drugbankId == drugbankId &&
          other.description == description;

  @override
  int get hashCode => drugbankId.hashCode + description.hashCode;

  factory MedicineDetailResponseDrugInteractions.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineDetailResponseDrugInteractionsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineDetailResponseDrugInteractionsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
