//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/emergency_contact_dto.dart';
import 'package:lucent_api/src/model/sex_at_birth.dart';
import 'package:lucent_api/src/model/unit_system.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_health_profile_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UserHealthProfileDto {
  /// Returns a new [UserHealthProfileDto] instance.
  UserHealthProfileDto({
    required this.birthDate,

    this.sexAtBirth,

    required this.heightCm,

    required this.weightKg,

    required this.bloodType,

    required this.locale,

    required this.timezone,

    this.unitSystem,

    required this.onboardingCompletedAt,

    required this.emergencyContact,

    required this.extras,
  });

  /// Birth date in YYYY-MM-DD format.
  @JsonKey(name: r'birthDate', required: true, includeIfNull: true)
  final String? birthDate;

  /// Sex assigned at birth.
  @JsonKey(
    name: r'sexAtBirth',
    required: false,
    includeIfNull: false,
    unknownEnumValue: SexAtBirth.unknownDefaultOpenApi,
  )
  final SexAtBirth? sexAtBirth;

  /// Height in centimeters.
  @JsonKey(name: r'heightCm', required: true, includeIfNull: true)
  final num? heightCm;

  /// Weight in kilograms. Extracted from extras JSONB.
  @JsonKey(name: r'weightKg', required: true, includeIfNull: true)
  final num? weightKg;

  /// Blood type.
  @JsonKey(name: r'bloodType', required: true, includeIfNull: true)
  final String? bloodType;

  /// Preferred locale.
  @JsonKey(name: r'locale', required: true, includeIfNull: true)
  final String? locale;

  /// Preferred timezone.
  @JsonKey(name: r'timezone', required: true, includeIfNull: true)
  final String? timezone;

  /// Preferred unit system.
  @JsonKey(
    name: r'unitSystem',
    required: false,
    includeIfNull: false,
    unknownEnumValue: UnitSystem.unknownDefaultOpenApi,
  )
  final UnitSystem? unitSystem;

  /// When the onboarding flow was completed.
  @JsonKey(name: r'onboardingCompletedAt', required: true, includeIfNull: true)
  final String? onboardingCompletedAt;

  /// Emergency contact extracted from extras JSONB.
  @JsonKey(name: r'emergencyContact', required: true, includeIfNull: true)
  final EmergencyContactDto? emergencyContact;

  /// Sparse profile extensions stored in jsonb.
  @JsonKey(name: r'extras', required: true, includeIfNull: true)
  final Map<String, Object>? extras;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserHealthProfileDto &&
          other.birthDate == birthDate &&
          other.sexAtBirth == sexAtBirth &&
          other.heightCm == heightCm &&
          other.weightKg == weightKg &&
          other.bloodType == bloodType &&
          other.locale == locale &&
          other.timezone == timezone &&
          other.unitSystem == unitSystem &&
          other.onboardingCompletedAt == onboardingCompletedAt &&
          other.emergencyContact == emergencyContact &&
          other.extras == extras;

  @override
  int get hashCode =>
      (birthDate == null ? 0 : birthDate.hashCode) +
      sexAtBirth.hashCode +
      (heightCm == null ? 0 : heightCm.hashCode) +
      (weightKg == null ? 0 : weightKg.hashCode) +
      (bloodType == null ? 0 : bloodType.hashCode) +
      (locale == null ? 0 : locale.hashCode) +
      (timezone == null ? 0 : timezone.hashCode) +
      unitSystem.hashCode +
      (onboardingCompletedAt == null ? 0 : onboardingCompletedAt.hashCode) +
      (emergencyContact == null ? 0 : emergencyContact.hashCode) +
      (extras == null ? 0 : extras.hashCode);

  factory UserHealthProfileDto.fromJson(Map<String, dynamic> json) =>
      _$UserHealthProfileDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserHealthProfileDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
