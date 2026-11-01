//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medication_overview_response_duplicates.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicationOverviewResponseDuplicates {
  /// Returns a new [MedicationOverviewResponseDuplicates] instance.
  MedicationOverviewResponseDuplicates({
    required this.ingredientKey,

    required this.entryIds,

    required this.displayNames,

    required this.severity,
  });

  /// Shared ingredient key that made these entries duplicates.
  @JsonKey(name: r'ingredientKey', required: true, includeIfNull: false)
  final String ingredientKey;

  /// Ids of the current-medicine entries involved.
  @JsonKey(name: r'entryIds', required: true, includeIfNull: false)
  final List<String> entryIds;

  /// Display names of those entries.
  @JsonKey(name: r'displayNames', required: true, includeIfNull: false)
  final List<String> displayNames;

  /// high when three or more entries share the ingredient, or when they span two knowledge sources.
  @JsonKey(
    name: r'severity',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        MedicationOverviewResponseDuplicatesSeverityEnum.unknownDefaultOpenApi,
  )
  final MedicationOverviewResponseDuplicatesSeverityEnum severity;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationOverviewResponseDuplicates &&
          other.ingredientKey == ingredientKey &&
          other.entryIds == entryIds &&
          other.displayNames == displayNames &&
          other.severity == severity;

  @override
  int get hashCode =>
      ingredientKey.hashCode +
      entryIds.hashCode +
      displayNames.hashCode +
      severity.hashCode;

  factory MedicationOverviewResponseDuplicates.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicationOverviewResponseDuplicatesFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicationOverviewResponseDuplicatesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// high when three or more entries share the ingredient, or when they span two knowledge sources.
enum MedicationOverviewResponseDuplicatesSeverityEnum {
  @JsonValue(r'medium')
  medium(r'medium'),
  @JsonValue(r'high')
  high(r'high'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const MedicationOverviewResponseDuplicatesSeverityEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
