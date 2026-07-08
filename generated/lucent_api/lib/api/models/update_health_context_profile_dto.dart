// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'sex_at_birth.dart';
import 'unit_system.dart';

part 'update_health_context_profile_dto.g.dart';

@JsonSerializable()
class UpdateHealthContextProfileDto {
  const UpdateHealthContextProfileDto({
    required this.locale,
    required this.timezone,
    required this.unitSystem,
    required this.birthDate,
    required this.sexAtBirth,
    required this.heightCm,
    required this.bloodType,
    required this.onboardingCompleted,
  });

  factory UpdateHealthContextProfileDto.fromJson(Map<String, Object?> json) =>
      _$UpdateHealthContextProfileDtoFromJson(json);

  /// Preferred locale. Use null or empty string to clear and follow the client default.
  final String? locale;

  /// Preferred timezone. Use null or empty string to clear.
  final String? timezone;

  /// Preferred unit system. Use null to clear.
  final UnitSystem unitSystem;

  /// Birth date in YYYY-MM-DD format.
  final String? birthDate;

  /// Sex assigned at birth. Use null to clear.
  final SexAtBirth sexAtBirth;

  /// Height in centimeters. Use null to clear.
  final num? heightCm;

  /// Blood type. Use null to clear.
  final String? bloodType;

  /// Set true to complete onboarding (sets completedAt when missing). Set false to clear onboarding completion.
  final bool onboardingCompleted;

  Map<String, Object?> toJson() => _$UpdateHealthContextProfileDtoToJson(this);
}
