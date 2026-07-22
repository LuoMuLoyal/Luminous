// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'sex_at_birth.dart';
import 'unit_system.dart';

part 'user_health_profile_dto.g.dart';

@JsonSerializable()
class UserHealthProfileDto {
  const UserHealthProfileDto({
    required this.birthDate,
    required this.heightCm,
    required this.bloodType,
    required this.locale,
    required this.timezone,
    required this.onboardingCompletedAt,
    required this.extras,
    this.sexAtBirth,
    this.unitSystem,
  });

  factory UserHealthProfileDto.fromJson(Map<String, Object?> json) =>
      _$UserHealthProfileDtoFromJson(json);

  /// Birth date in YYYY-MM-DD format.
  final String? birthDate;

  /// Sex assigned at birth.
  final SexAtBirth? sexAtBirth;

  /// Height in centimeters.
  final num? heightCm;

  /// Blood type.
  final String? bloodType;

  /// Preferred locale.
  final String? locale;

  /// Preferred timezone.
  final String? timezone;

  /// Preferred unit system.
  final UnitSystem? unitSystem;

  /// When the onboarding flow was completed.
  final String? onboardingCompletedAt;

  /// Sparse profile extensions stored in jsonb.
  final dynamic extras;

  Map<String, Object?> toJson() => _$UserHealthProfileDtoToJson(this);
}
