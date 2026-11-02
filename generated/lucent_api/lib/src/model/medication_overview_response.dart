//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/medication_overview_response_source_overlaps.dart';
import 'package:lucent_api/src/model/medication_overview_response_duplicates.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medication_overview_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicationOverviewResponse {
  /// Returns a new [MedicationOverviewResponse] instance.
  MedicationOverviewResponse({
    required this.totalMedicines,

    required this.resolvableMedicines,

    required this.duplicates,

    required this.sourceOverlaps,
  });

  /// Every current medicine on record.
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'totalMedicines', required: true, includeIfNull: false)
  final int totalMedicines;

  /// How many could be resolved to ingredients. The rest cannot participate in duplicate detection.
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'resolvableMedicines', required: true, includeIfNull: false)
  final int resolvableMedicines;

  /// One entry per shared ingredient; empty when nothing overlaps.
  @JsonKey(name: r'duplicates', required: true, includeIfNull: false)
  final List<MedicationOverviewResponseDuplicates> duplicates;

  /// Entries grouped by health event, plus unattributed ones.
  @JsonKey(name: r'sourceOverlaps', required: true, includeIfNull: false)
  final List<MedicationOverviewResponseSourceOverlaps> sourceOverlaps;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationOverviewResponse &&
          other.totalMedicines == totalMedicines &&
          other.resolvableMedicines == resolvableMedicines &&
          other.duplicates == duplicates &&
          other.sourceOverlaps == sourceOverlaps;

  @override
  int get hashCode =>
      totalMedicines.hashCode +
      resolvableMedicines.hashCode +
      duplicates.hashCode +
      sourceOverlaps.hashCode;

  factory MedicationOverviewResponse.fromJson(Map<String, dynamic> json) =>
      _$MedicationOverviewResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationOverviewResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
