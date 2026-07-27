//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/sex_at_birth.dart';
import 'package:lucent_api/src/model/unit_system.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_health_context_profile_dto.g.dart';

@CopyWith()
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

    this.weightKg,

    this.emergencyContactName,

    this.emergencyContactPhone,

    this.onboardingCompleted,
  });

  /// Preferred locale. Use null or empty string to clear and follow the client default.
  @JsonKey(name: r'locale', required: false, includeIfNull: false)
  final String? locale;

  /// Preferred timezone. Use null or empty string to clear.
  @JsonKey(name: r'timezone', required: false, includeIfNull: false)
  final String? timezone;

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
  final String? birthDate;

  /// Sex assigned at birth. Use null to clear.
  @JsonKey(
    name: r'sexAtBirth',
    required: false,
    includeIfNull: false,
    unknownEnumValue: SexAtBirth.unknownDefaultOpenApi,
  )
  final SexAtBirth? sexAtBirth;

  /// Height in centimeters. Use null to clear.
  // minimum: 1
  // maximum: 300
  @JsonKey(name: r'heightCm', required: false, includeIfNull: false)
  final num? heightCm;

  /// Blood type. Use null to clear.
  @JsonKey(name: r'bloodType', required: false, includeIfNull: false)
  final String? bloodType;

  /// Weight in kilograms. Stored in extras JSONB. Use null to clear.
  // minimum: 1
  // maximum: 500
  @JsonKey(name: r'weightKg', required: false, includeIfNull: false)
  final num? weightKg;

  /// Emergency contact name. Stored in extras JSONB. Use null or empty string to clear.
  @JsonKey(name: r'emergencyContactName', required: false, includeIfNull: false)
  final String? emergencyContactName;

  /// Emergency contact phone. Stored in extras JSONB. Use null or empty string to clear.
  @JsonKey(
    name: r'emergencyContactPhone',
    required: false,
    includeIfNull: false,
  )
  final String? emergencyContactPhone;

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
          other.weightKg == weightKg &&
          other.emergencyContactName == emergencyContactName &&
          other.emergencyContactPhone == emergencyContactPhone &&
          other.onboardingCompleted == onboardingCompleted;

  @override
  int get hashCode =>
      (locale == null ? 0 : locale.hashCode) +
      (timezone == null ? 0 : timezone.hashCode) +
      unitSystem.hashCode +
      (birthDate == null ? 0 : birthDate.hashCode) +
      sexAtBirth.hashCode +
      (heightCm == null ? 0 : heightCm.hashCode) +
      (bloodType == null ? 0 : bloodType.hashCode) +
      (weightKg == null ? 0 : weightKg.hashCode) +
      (emergencyContactName == null ? 0 : emergencyContactName.hashCode) +
      (emergencyContactPhone == null ? 0 : emergencyContactPhone.hashCode) +
      onboardingCompleted.hashCode;

  factory UpdateHealthContextProfileDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateHealthContextProfileDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateHealthContextProfileDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
