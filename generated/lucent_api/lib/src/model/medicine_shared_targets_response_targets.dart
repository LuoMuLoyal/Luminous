//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_shared_targets_response_targets.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineSharedTargetsResponseTargets {
  /// Returns a new [MedicineSharedTargetsResponseTargets] instance.
  MedicineSharedTargetsResponseTargets({
    required this.targetGene,

    required this.targetName,

    required this.drugCount,

    required this.drugIds,

    required this.drugNames,
  });

  /// Shared target gene symbol.
  @JsonKey(name: r'targetGene', required: true, includeIfNull: false)
  final String targetGene;

  /// Shared target display name.
  @JsonKey(name: r'targetName', required: true, includeIfNull: false)
  final String targetName;

  /// How many of the queried drugs hit this target.
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'drugCount', required: true, includeIfNull: false)
  final int drugCount;

  /// DrugBank ids hitting this target.
  @JsonKey(name: r'drugIds', required: true, includeIfNull: false)
  final List<String> drugIds;

  /// Display names hitting this target.
  @JsonKey(name: r'drugNames', required: true, includeIfNull: false)
  final List<String> drugNames;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineSharedTargetsResponseTargets &&
          other.targetGene == targetGene &&
          other.targetName == targetName &&
          other.drugCount == drugCount &&
          other.drugIds == drugIds &&
          other.drugNames == drugNames;

  @override
  int get hashCode =>
      targetGene.hashCode +
      targetName.hashCode +
      drugCount.hashCode +
      drugIds.hashCode +
      drugNames.hashCode;

  factory MedicineSharedTargetsResponseTargets.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineSharedTargetsResponseTargetsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineSharedTargetsResponseTargetsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
