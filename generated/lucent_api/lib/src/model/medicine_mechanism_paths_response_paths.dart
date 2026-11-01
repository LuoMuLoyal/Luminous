//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_mechanism_paths_response_paths.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineMechanismPathsResponsePaths {
  /// Returns a new [MedicineMechanismPathsResponsePaths] instance.
  MedicineMechanismPathsResponsePaths({
    required this.enzymeGene,

    required this.enzymeName,

    required this.otherDrugId,

    required this.otherDrugName,

    required this.relation,
  });

  /// Metabolising enzyme gene symbol.
  @JsonKey(name: r'enzymeGene', required: true, includeIfNull: false)
  final String enzymeGene;

  /// Enzyme display name.
  @JsonKey(name: r'enzymeName', required: true, includeIfNull: false)
  final String enzymeName;

  /// Other drug DrugBank id.
  @JsonKey(name: r'otherDrugId', required: true, includeIfNull: false)
  final String otherDrugId;

  /// Other drug display name.
  @JsonKey(name: r'otherDrugName', required: true, includeIfNull: false)
  final String otherDrugName;

  /// What the first drug does to the enzyme (INHIBITS/INDUCES).
  @JsonKey(name: r'relation', required: true, includeIfNull: false)
  final String relation;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineMechanismPathsResponsePaths &&
          other.enzymeGene == enzymeGene &&
          other.enzymeName == enzymeName &&
          other.otherDrugId == otherDrugId &&
          other.otherDrugName == otherDrugName &&
          other.relation == relation;

  @override
  int get hashCode =>
      enzymeGene.hashCode +
      enzymeName.hashCode +
      otherDrugId.hashCode +
      otherDrugName.hashCode +
      relation.hashCode;

  factory MedicineMechanismPathsResponsePaths.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineMechanismPathsResponsePathsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineMechanismPathsResponsePathsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
