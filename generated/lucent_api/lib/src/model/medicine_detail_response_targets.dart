//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_detail_response_targets.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineDetailResponseTargets {
  /// Returns a new [MedicineDetailResponseTargets] instance.
  MedicineDetailResponseTargets({
    required this.name,

    required this.geneName,

    required this.uniprotId,

    required this.uniprotTitle,

    required this.species,

    required this.pdbIds,

    required this.actions,

    required this.knownAction,

    required this.relationKind,
  });

  /// Target display name.
  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  @JsonKey(name: r'geneName', required: true, includeIfNull: true)
  final String? geneName;

  @JsonKey(name: r'uniprotId', required: true, includeIfNull: true)
  final String? uniprotId;

  @JsonKey(name: r'uniprotTitle', required: true, includeIfNull: true)
  final String? uniprotTitle;

  @JsonKey(name: r'species', required: true, includeIfNull: true)
  final String? species;

  @JsonKey(name: r'pdbIds', required: true, includeIfNull: true)
  final List<String>? pdbIds;

  @JsonKey(name: r'actions', required: true, includeIfNull: true)
  final List<String>? actions;

  @JsonKey(name: r'knownAction', required: true, includeIfNull: true)
  final String? knownAction;

  @JsonKey(name: r'relationKind', required: true, includeIfNull: true)
  final String? relationKind;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineDetailResponseTargets &&
          other.name == name &&
          other.geneName == geneName &&
          other.uniprotId == uniprotId &&
          other.uniprotTitle == uniprotTitle &&
          other.species == species &&
          other.pdbIds == pdbIds &&
          other.actions == actions &&
          other.knownAction == knownAction &&
          other.relationKind == relationKind;

  @override
  int get hashCode =>
      name.hashCode +
      (geneName == null ? 0 : geneName.hashCode) +
      (uniprotId == null ? 0 : uniprotId.hashCode) +
      (uniprotTitle == null ? 0 : uniprotTitle.hashCode) +
      (species == null ? 0 : species.hashCode) +
      (pdbIds == null ? 0 : pdbIds.hashCode) +
      (actions == null ? 0 : actions.hashCode) +
      (knownAction == null ? 0 : knownAction.hashCode) +
      (relationKind == null ? 0 : relationKind.hashCode);

  factory MedicineDetailResponseTargets.fromJson(Map<String, dynamic> json) =>
      _$MedicineDetailResponseTargetsFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineDetailResponseTargetsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
