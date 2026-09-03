//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/health_context_response_dto_profile_emergency_contact.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_context_response_dto_profile.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthContextResponseDtoProfile {
  /// Returns a new [HealthContextResponseDtoProfile] instance.
  HealthContextResponseDtoProfile({
    required this.birthDate,

    required this.sexAtBirth,

    required this.heightCm,

    required this.weightKg,

    required this.bloodType,

    required this.locale,

    required this.timezone,

    required this.unitSystem,

    required this.onboardingCompletedAt,

    required this.emergencyContact,

    required this.extras,
  });

  @JsonKey(name: r'birthDate', required: true, includeIfNull: true)
  final String? birthDate;

  @JsonKey(
    name: r'sexAtBirth',
    required: true,
    includeIfNull: true,
    unknownEnumValue:
        HealthContextResponseDtoProfileSexAtBirthEnum.unknownDefaultOpenApi,
  )
  final HealthContextResponseDtoProfileSexAtBirthEnum? sexAtBirth;

  @JsonKey(name: r'heightCm', required: true, includeIfNull: true)
  final num? heightCm;

  @JsonKey(name: r'weightKg', required: true, includeIfNull: true)
  final num? weightKg;

  @JsonKey(name: r'bloodType', required: true, includeIfNull: true)
  final String? bloodType;

  @JsonKey(name: r'locale', required: true, includeIfNull: true)
  final String? locale;

  @JsonKey(name: r'timezone', required: true, includeIfNull: true)
  final String? timezone;

  @JsonKey(
    name: r'unitSystem',
    required: true,
    includeIfNull: true,
    unknownEnumValue:
        HealthContextResponseDtoProfileUnitSystemEnum.unknownDefaultOpenApi,
  )
  final HealthContextResponseDtoProfileUnitSystemEnum? unitSystem;

  @JsonKey(name: r'onboardingCompletedAt', required: true, includeIfNull: true)
  final String? onboardingCompletedAt;

  @JsonKey(name: r'emergencyContact', required: true, includeIfNull: true)
  final HealthContextResponseDtoProfileEmergencyContact? emergencyContact;

  /// Sparse profile extensions stored in jsonb.
  @JsonKey(name: r'extras', required: true, includeIfNull: true)
  final Object? extras;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthContextResponseDtoProfile &&
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
      (sexAtBirth == null ? 0 : sexAtBirth.hashCode) +
      (heightCm == null ? 0 : heightCm.hashCode) +
      (weightKg == null ? 0 : weightKg.hashCode) +
      (bloodType == null ? 0 : bloodType.hashCode) +
      (locale == null ? 0 : locale.hashCode) +
      (timezone == null ? 0 : timezone.hashCode) +
      (unitSystem == null ? 0 : unitSystem.hashCode) +
      (onboardingCompletedAt == null ? 0 : onboardingCompletedAt.hashCode) +
      (emergencyContact == null ? 0 : emergencyContact.hashCode) +
      (extras == null ? 0 : extras.hashCode);

  factory HealthContextResponseDtoProfile.fromJson(Map<String, dynamic> json) =>
      _$HealthContextResponseDtoProfileFromJson(json);

  Map<String, dynamic> toJson() =>
      _$HealthContextResponseDtoProfileToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum HealthContextResponseDtoProfileSexAtBirthEnum {
  @JsonValue(r'female')
  female(r'female'),
  @JsonValue(r'male')
  male(r'male'),
  @JsonValue(r'intersex')
  intersex(r'intersex'),
  @JsonValue(r'unknown')
  unknown(r'unknown'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const HealthContextResponseDtoProfileSexAtBirthEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum HealthContextResponseDtoProfileUnitSystemEnum {
  @JsonValue(r'metric')
  metric(r'metric'),
  @JsonValue(r'imperial')
  imperial(r'imperial'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const HealthContextResponseDtoProfileUnitSystemEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
