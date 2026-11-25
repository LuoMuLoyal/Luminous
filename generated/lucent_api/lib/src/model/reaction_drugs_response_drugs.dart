//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reaction_drugs_response_drugs.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReactionDrugsResponseDrugs {
  /// Returns a new [ReactionDrugsResponseDrugs] instance.
  ReactionDrugsResponseDrugs({
    required this.drugbankId,

    required this.name,

    required this.labelCount,

    required this.confidenceMax,
  });

  /// DrugBank drug id that could cause the reaction.
  @JsonKey(name: r'drugbankId', required: true, includeIfNull: false)
  final String drugbankId;

  /// Drug display name.
  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  /// Number of distinct labels linking this drug to the reaction.
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'labelCount', required: true, includeIfNull: false)
  final int labelCount;

  /// Highest extraction confidence among those links; null = unscored.
  @JsonKey(name: r'confidenceMax', required: true, includeIfNull: true)
  final num? confidenceMax;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReactionDrugsResponseDrugs &&
          other.drugbankId == drugbankId &&
          other.name == name &&
          other.labelCount == labelCount &&
          other.confidenceMax == confidenceMax;

  @override
  int get hashCode =>
      drugbankId.hashCode +
      name.hashCode +
      labelCount.hashCode +
      (confidenceMax == null ? 0 : confidenceMax.hashCode);

  factory ReactionDrugsResponseDrugs.fromJson(Map<String, dynamic> json) =>
      _$ReactionDrugsResponseDrugsFromJson(json);

  Map<String, dynamic> toJson() => _$ReactionDrugsResponseDrugsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
