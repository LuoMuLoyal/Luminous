// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'user_health_summary_dto.g.dart';

@JsonSerializable()
class UserHealthSummaryDto {
  const UserHealthSummaryDto({
    required this.age,
    required this.onboardingCompleted,
    required this.activeAllergyCount,
    required this.conditionCount,
    required this.currentMedicineCount,
    required this.missingCoreProfileFields,
  });

  factory UserHealthSummaryDto.fromJson(Map<String, Object?> json) =>
      _$UserHealthSummaryDtoFromJson(json);

  /// Age derived from birth date. Null when birth date is missing.
  final num? age;

  /// Whether the onboarding flow has been completed.
  final bool onboardingCompleted;

  /// Number of active allergy records returned in this payload.
  final num activeAllergyCount;

  /// Number of condition records returned in this payload.
  final num conditionCount;

  /// Number of current medicine records returned in this payload.
  final num currentMedicineCount;

  /// Missing core profile fields that the frontend can use for onboarding nudges.
  final List<String> missingCoreProfileFields;

  Map<String, Object?> toJson() => _$UserHealthSummaryDtoToJson(this);
}
