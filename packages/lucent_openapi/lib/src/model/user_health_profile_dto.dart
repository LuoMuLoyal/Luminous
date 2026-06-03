//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/sex_at_birth.dart';
import 'package:lucent_openapi/src/model/lactation_state.dart';
import 'package:lucent_openapi/src/model/unit_system.dart';
import 'package:lucent_openapi/src/model/pregnancy_state.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_health_profile_dto.g.dart';

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

    required this.sexAtBirth,

    required this.heightCm,

    required this.pregnancyState,

    required this.lactationState,

    required this.bloodType,

    required this.locale,

    required this.timezone,

    required this.unitSystem,

    required this.onboardingCompletedAt,

    required this.extras,
  });

  /// Birth date in YYYY-MM-DD format.
  @JsonKey(name: r'birthDate', required: true, includeIfNull: true)
  final Object? birthDate;

  /// Sex assigned at birth.
  @JsonKey(
    name: r'sexAtBirth',
    required: true,
    includeIfNull: true,
    unknownEnumValue: SexAtBirth.unknownDefaultOpenApi,
  )
  final SexAtBirth? sexAtBirth;

  /// Height in centimeters.
  @JsonKey(name: r'heightCm', required: true, includeIfNull: true)
  final Object? heightCm;

  /// Pregnancy state for personalized medical guidance.
  @JsonKey(
    name: r'pregnancyState',
    required: true,
    includeIfNull: true,
    unknownEnumValue: PregnancyState.unknownDefaultOpenApi,
  )
  final PregnancyState? pregnancyState;

  /// Lactation state for personalized medical guidance.
  @JsonKey(
    name: r'lactationState',
    required: true,
    includeIfNull: true,
    unknownEnumValue: LactationState.unknownDefaultOpenApi,
  )
  final LactationState? lactationState;

  /// Blood type.
  @JsonKey(name: r'bloodType', required: true, includeIfNull: true)
  final Object? bloodType;

  /// Preferred locale.
  @JsonKey(name: r'locale', required: true, includeIfNull: true)
  final Object? locale;

  /// Preferred timezone.
  @JsonKey(name: r'timezone', required: true, includeIfNull: true)
  final Object? timezone;

  /// Preferred unit system.
  @JsonKey(
    name: r'unitSystem',
    required: true,
    includeIfNull: true,
    unknownEnumValue: UnitSystem.unknownDefaultOpenApi,
  )
  final UnitSystem? unitSystem;

  /// When the onboarding flow was completed.
  @JsonKey(name: r'onboardingCompletedAt', required: true, includeIfNull: true)
  final Object? onboardingCompletedAt;

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
          other.pregnancyState == pregnancyState &&
          other.lactationState == lactationState &&
          other.bloodType == bloodType &&
          other.locale == locale &&
          other.timezone == timezone &&
          other.unitSystem == unitSystem &&
          other.onboardingCompletedAt == onboardingCompletedAt &&
          other.extras == extras;

  @override
  int get hashCode =>
      (birthDate == null ? 0 : birthDate.hashCode) +
      (sexAtBirth == null ? 0 : sexAtBirth.hashCode) +
      (heightCm == null ? 0 : heightCm.hashCode) +
      (pregnancyState == null ? 0 : pregnancyState.hashCode) +
      (lactationState == null ? 0 : lactationState.hashCode) +
      (bloodType == null ? 0 : bloodType.hashCode) +
      (locale == null ? 0 : locale.hashCode) +
      (timezone == null ? 0 : timezone.hashCode) +
      (unitSystem == null ? 0 : unitSystem.hashCode) +
      (onboardingCompletedAt == null ? 0 : onboardingCompletedAt.hashCode) +
      (extras == null ? 0 : extras.hashCode);

  factory UserHealthProfileDto.fromJson(Map<String, dynamic> json) =>
      _$UserHealthProfileDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserHealthProfileDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
