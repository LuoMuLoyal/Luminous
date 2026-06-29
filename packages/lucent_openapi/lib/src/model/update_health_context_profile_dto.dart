//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/sex_at_birth.dart';
import 'package:lucent_openapi/src/model/unit_system.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_health_context_profile_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateHealthContextProfileDto {
  /// Returns a new [UpdateHealthContextProfileDto] instance.
  UpdateHealthContextProfileDto({
    this.locale,

    this.timezone,

    this.unitSystem,

    this.birthDate,

    this.sexAtBirth,

    this.heightCm,

    this.bloodType,

    this.onboardingCompleted,
  });

  /// Preferred locale. Use null or empty string to clear and follow the client default.
  @JsonKey(name: r'locale', required: false, includeIfNull: false)
  final Object? locale;

  /// Preferred timezone. Use null or empty string to clear.
  @JsonKey(name: r'timezone', required: false, includeIfNull: false)
  final Object? timezone;

  /// Preferred unit system. Use null to clear.
  @JsonKey(
    name: r'unitSystem',
    required: false,
    includeIfNull: false,
    unknownEnumValue: UnitSystem.unknownDefaultOpenApi,
  )
  final UnitSystem? unitSystem;

  /// Birth date in YYYY-MM-DD format.
  @JsonKey(name: r'birthDate', required: false, includeIfNull: false)
  final Object? birthDate;

  /// Sex assigned at birth. Use null to clear.
  @JsonKey(
    name: r'sexAtBirth',
    required: false,
    includeIfNull: false,
    unknownEnumValue: SexAtBirth.unknownDefaultOpenApi,
  )
  final SexAtBirth? sexAtBirth;

  /// Height in centimeters. Use null to clear.
  @JsonKey(name: r'heightCm', required: false, includeIfNull: false)
  final Object? heightCm;

  /// Blood type. Use null to clear.
  @JsonKey(name: r'bloodType', required: false, includeIfNull: false)
  final Object? bloodType;

  /// Set true to complete onboarding (sets completedAt when missing). Set false to clear onboarding completion.
  @JsonKey(name: r'onboardingCompleted', required: false, includeIfNull: false)
  final bool? onboardingCompleted;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateHealthContextProfileDto &&
          other.locale == locale &&
          other.timezone == timezone &&
          other.unitSystem == unitSystem &&
          other.birthDate == birthDate &&
          other.sexAtBirth == sexAtBirth &&
          other.heightCm == heightCm &&
          other.bloodType == bloodType &&
          other.onboardingCompleted == onboardingCompleted;

  @override
  int get hashCode =>
      (locale == null ? 0 : locale.hashCode) +
      (timezone == null ? 0 : timezone.hashCode) +
      (unitSystem == null ? 0 : unitSystem.hashCode) +
      (birthDate == null ? 0 : birthDate.hashCode) +
      (sexAtBirth == null ? 0 : sexAtBirth.hashCode) +
      (heightCm == null ? 0 : heightCm.hashCode) +
      (bloodType == null ? 0 : bloodType.hashCode) +
      onboardingCompleted.hashCode;

  factory UpdateHealthContextProfileDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateHealthContextProfileDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateHealthContextProfileDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
