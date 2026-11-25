//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_user_context_profile_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateUserContextProfileRequest {
  /// Returns a new [UpdateUserContextProfileRequest] instance.
  UpdateUserContextProfileRequest({
    this.locale,

    this.timezone,

    this.unitSystem,

    this.birthDate,

    this.sexAtBirth,

    this.heightCm,

    this.activityLevel,

    this.dietaryPreferences,

    this.weightKg,

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
    unknownEnumValue:
        UpdateUserContextProfileRequestUnitSystemEnum.unknownDefaultOpenApi,
  )
  final UpdateUserContextProfileRequestUnitSystemEnum? unitSystem;

  /// Birth date in YYYY-MM-DD format.
  @JsonKey(name: r'birthDate', required: false, includeIfNull: false)
  final String? birthDate;

  /// Sex assigned at birth. Use null to clear.
  @JsonKey(
    name: r'sexAtBirth',
    required: false,
    includeIfNull: false,
    unknownEnumValue:
        UpdateUserContextProfileRequestSexAtBirthEnum.unknownDefaultOpenApi,
  )
  final UpdateUserContextProfileRequestSexAtBirthEnum? sexAtBirth;

  /// Height in centimeters. Use null to clear.
  // minimum: 1
  // maximum: 300
  @JsonKey(name: r'heightCm', required: false, includeIfNull: false)
  final int? heightCm;

  /// Self-reported activity level. Use null to clear.
  @JsonKey(
    name: r'activityLevel',
    required: false,
    includeIfNull: false,
    unknownEnumValue:
        UpdateUserContextProfileRequestActivityLevelEnum.unknownDefaultOpenApi,
  )
  final UpdateUserContextProfileRequestActivityLevelEnum? activityLevel;

  /// Dietary preferences. Stored in extras JSONB. Use null to clear.
  @JsonKey(name: r'dietaryPreferences', required: false, includeIfNull: false)
  final List<UpdateUserContextProfileRequestDietaryPreferencesEnum>?
  dietaryPreferences;

  /// Weight in kilograms. Stored in extras JSONB. Use null to clear.
  // minimum: 1
  // maximum: 500
  @JsonKey(name: r'weightKg', required: false, includeIfNull: false)
  final int? weightKg;

  /// Set true to complete onboarding (sets completedAt when missing). Set false to clear onboarding completion.
  @JsonKey(name: r'onboardingCompleted', required: false, includeIfNull: false)
  final bool? onboardingCompleted;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateUserContextProfileRequest &&
          other.locale == locale &&
          other.timezone == timezone &&
          other.unitSystem == unitSystem &&
          other.birthDate == birthDate &&
          other.sexAtBirth == sexAtBirth &&
          other.heightCm == heightCm &&
          other.activityLevel == activityLevel &&
          other.dietaryPreferences == dietaryPreferences &&
          other.weightKg == weightKg &&
          other.onboardingCompleted == onboardingCompleted;

  @override
  int get hashCode =>
      (locale == null ? 0 : locale.hashCode) +
      (timezone == null ? 0 : timezone.hashCode) +
      (unitSystem == null ? 0 : unitSystem.hashCode) +
      (birthDate == null ? 0 : birthDate.hashCode) +
      (sexAtBirth == null ? 0 : sexAtBirth.hashCode) +
      (heightCm == null ? 0 : heightCm.hashCode) +
      (activityLevel == null ? 0 : activityLevel.hashCode) +
      (dietaryPreferences == null ? 0 : dietaryPreferences.hashCode) +
      (weightKg == null ? 0 : weightKg.hashCode) +
      onboardingCompleted.hashCode;

  factory UpdateUserContextProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserContextProfileRequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$UpdateUserContextProfileRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Preferred unit system. Use null to clear.
enum UpdateUserContextProfileRequestUnitSystemEnum {
  @JsonValue(r'metric')
  metric(r'metric'),
  @JsonValue(r'imperial')
  imperial(r'imperial'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const UpdateUserContextProfileRequestUnitSystemEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Sex assigned at birth. Use null to clear.
enum UpdateUserContextProfileRequestSexAtBirthEnum {
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

  const UpdateUserContextProfileRequestSexAtBirthEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Self-reported activity level. Use null to clear.
enum UpdateUserContextProfileRequestActivityLevelEnum {
  @JsonValue(r'sedentary')
  sedentary(r'sedentary'),
  @JsonValue(r'lightlyActive')
  lightlyActive(r'lightlyActive'),
  @JsonValue(r'moderatelyActive')
  moderatelyActive(r'moderatelyActive'),
  @JsonValue(r'veryActive')
  veryActive(r'veryActive'),
  @JsonValue(r'extremelyActive')
  extremelyActive(r'extremelyActive'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const UpdateUserContextProfileRequestActivityLevelEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum UpdateUserContextProfileRequestDietaryPreferencesEnum {
  @JsonValue(r'vegetarian')
  vegetarian(r'vegetarian'),
  @JsonValue(r'vegan')
  vegan(r'vegan'),
  @JsonValue(r'lowCarb')
  lowCarb(r'lowCarb'),
  @JsonValue(r'lowSalt')
  lowSalt(r'lowSalt'),
  @JsonValue(r'lowFat')
  lowFat(r'lowFat'),
  @JsonValue(r'highProtein')
  highProtein(r'highProtein'),
  @JsonValue(r'keto')
  keto(r'keto'),
  @JsonValue(r'halal')
  halal(r'halal'),
  @JsonValue(r'other')
  other(r'other'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const UpdateUserContextProfileRequestDietaryPreferencesEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
