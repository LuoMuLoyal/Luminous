//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'context_response_summary.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ContextResponseSummary {
  /// Returns a new [ContextResponseSummary] instance.
  ContextResponseSummary({
    required this.age,

    required this.onboardingCompleted,

    required this.activeAllergyCount,

    required this.conditionCount,

    required this.currentMedicineCount,

    required this.missingCoreProfileFields,
  });

  /// Age derived from birth date. Null when birth date is missing.
  @JsonKey(name: r'age', required: true, includeIfNull: true)
  final num? age;

  /// Whether the onboarding flow has been completed.
  @JsonKey(name: r'onboardingCompleted', required: true, includeIfNull: false)
  final bool onboardingCompleted;

  /// Number of active allergy records returned in this payload.
  @JsonKey(name: r'activeAllergyCount', required: true, includeIfNull: false)
  final num activeAllergyCount;

  /// Number of condition records returned in this payload.
  @JsonKey(name: r'conditionCount', required: true, includeIfNull: false)
  final num conditionCount;

  /// Number of current medicine records returned in this payload.
  @JsonKey(name: r'currentMedicineCount', required: true, includeIfNull: false)
  final num currentMedicineCount;

  /// Missing core profile fields that the frontend can use for onboarding nudges.
  @JsonKey(
    name: r'missingCoreProfileFields',
    required: true,
    includeIfNull: false,
  )
  final List<String> missingCoreProfileFields;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContextResponseSummary &&
          other.age == age &&
          other.onboardingCompleted == onboardingCompleted &&
          other.activeAllergyCount == activeAllergyCount &&
          other.conditionCount == conditionCount &&
          other.currentMedicineCount == currentMedicineCount &&
          other.missingCoreProfileFields == missingCoreProfileFields;

  @override
  int get hashCode =>
      (age == null ? 0 : age.hashCode) +
      onboardingCompleted.hashCode +
      activeAllergyCount.hashCode +
      conditionCount.hashCode +
      currentMedicineCount.hashCode +
      missingCoreProfileFields.hashCode;

  factory ContextResponseSummary.fromJson(Map<String, dynamic> json) =>
      _$ContextResponseSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$ContextResponseSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
