//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medication_overview_response_source_overlaps.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicationOverviewResponseSourceOverlaps {
  /// Returns a new [MedicationOverviewResponseSourceOverlaps] instance.
  MedicationOverviewResponseSourceOverlaps({
    required this.source_,

    required this.medicineCount,

    required this.displayNames,
  });

  /// Health event id, or \"unattributed\" when no event links the medicine.
  @JsonKey(name: r'source', required: true, includeIfNull: false)
  final String source_;

  /// How many entries this medicine group holds.
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'medicineCount', required: true, includeIfNull: false)
  final int medicineCount;

  /// Display names in this group.
  @JsonKey(name: r'displayNames', required: true, includeIfNull: false)
  final List<String> displayNames;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationOverviewResponseSourceOverlaps &&
          other.source_ == source_ &&
          other.medicineCount == medicineCount &&
          other.displayNames == displayNames;

  @override
  int get hashCode =>
      source_.hashCode + medicineCount.hashCode + displayNames.hashCode;

  factory MedicationOverviewResponseSourceOverlaps.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicationOverviewResponseSourceOverlapsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicationOverviewResponseSourceOverlapsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
