//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'drugbank_drug_interaction_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DrugbankDrugInteractionDto {
  /// Returns a new [DrugbankDrugInteractionDto] instance.
  DrugbankDrugInteractionDto({
    required this.drugbankId,

    required this.description,
  });

  @JsonKey(name: r'drugbankId', required: true, includeIfNull: false)
  final String drugbankId;

  @JsonKey(name: r'description', required: true, includeIfNull: false)
  final String description;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrugbankDrugInteractionDto &&
          other.drugbankId == drugbankId &&
          other.description == description;

  @override
  int get hashCode => drugbankId.hashCode + description.hashCode;

  factory DrugbankDrugInteractionDto.fromJson(Map<String, dynamic> json) =>
      _$DrugbankDrugInteractionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DrugbankDrugInteractionDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
