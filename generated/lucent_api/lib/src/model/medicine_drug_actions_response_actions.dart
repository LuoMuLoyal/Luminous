//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_drug_actions_response_actions.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineDrugActionsResponseActions {
  /// Returns a new [MedicineDrugActionsResponseActions] instance.
  MedicineDrugActionsResponseActions({
    required this.targetGene,

    required this.targetName,

    required this.relation,

    required this.actions,
  });

  /// Target gene symbol.
  @JsonKey(name: r'targetGene', required: true, includeIfNull: false)
  final String targetGene;

  /// Target display name.
  @JsonKey(name: r'targetName', required: true, includeIfNull: false)
  final String targetName;

  /// Relation type (INHIBITS/INDUCES/ACTS_ON/SUBSTRATE_OF).
  @JsonKey(name: r'relation', required: true, includeIfNull: false)
  final String relation;

  /// Action labels on the edge, when present.
  @JsonKey(name: r'actions', required: true, includeIfNull: false)
  final List<String> actions;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineDrugActionsResponseActions &&
          other.targetGene == targetGene &&
          other.targetName == targetName &&
          other.relation == relation &&
          other.actions == actions;

  @override
  int get hashCode =>
      targetGene.hashCode +
      targetName.hashCode +
      relation.hashCode +
      actions.hashCode;

  factory MedicineDrugActionsResponseActions.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineDrugActionsResponseActionsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineDrugActionsResponseActionsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
