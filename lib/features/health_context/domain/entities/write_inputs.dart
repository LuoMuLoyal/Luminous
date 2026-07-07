const Object healthContextNoChange = Object();

abstract interface class HealthContextWireEnum {
  String get value;
}

enum HealthSexAtBirth implements HealthContextWireEnum {
  female('female'),
  male('male'),
  intersex('intersex'),
  unknown('unknown');

  const HealthSexAtBirth(this.value);

  @override
  final String value;

  static HealthSexAtBirth? fromValue(String? value) {
    return _fromValue(values, value);
  }
}

enum HealthUnitSystem implements HealthContextWireEnum {
  metric('metric'),
  imperial('imperial');

  const HealthUnitSystem(this.value);

  @override
  final String value;

  static HealthUnitSystem? fromValue(String? value) {
    return _fromValue(values, value);
  }
}

enum HealthAllergyKind implements HealthContextWireEnum {
  drug('drug'),
  food('food'),
  environment('environment'),
  other('other');

  const HealthAllergyKind(this.value);

  @override
  final String value;

  static HealthAllergyKind? fromValue(String? value) {
    return _fromValue(values, value);
  }
}

enum HealthAllergySeverity implements HealthContextWireEnum {
  mild('mild'),
  moderate('moderate'),
  severe('severe'),
  unknown('unknown');

  const HealthAllergySeverity(this.value);

  @override
  final String value;

  static HealthAllergySeverity? fromValue(String? value) {
    return _fromValue(values, value);
  }
}

enum HealthConditionStatus implements HealthContextWireEnum {
  active('active'),
  resolved('resolved'),
  suspected('suspected');

  const HealthConditionStatus(this.value);

  @override
  final String value;

  static HealthConditionStatus? fromValue(String? value) {
    return _fromValue(values, value);
  }
}

enum HealthMedicineSource implements HealthContextWireEnum {
  drugbank('drugbank'),
  cn('cn'),
  manual('manual');

  const HealthMedicineSource(this.value);

  @override
  final String value;

  static HealthMedicineSource? fromValue(String? value) {
    return _fromValue(values, value);
  }
}

T? _fromValue<T extends Enum>(List<T> values, String? value) {
  if (value == null) return null;
  for (final entry in values) {
    final wireValue = (entry as HealthContextWireEnum).value;
    if (wireValue == value || entry.name == value) return entry;
  }
  return null;
}

class HealthProfileUpdateInput {
  const HealthProfileUpdateInput({
    this.locale = healthContextNoChange,
    this.timezone = healthContextNoChange,
    this.unitSystem = healthContextNoChange,
    this.birthDate = healthContextNoChange,
    this.sexAtBirth = healthContextNoChange,
    this.heightCm = healthContextNoChange,
    this.bloodType = healthContextNoChange,
    this.onboardingCompleted = healthContextNoChange,
  });

  final Object? locale;
  final Object? timezone;
  final Object? unitSystem;
  final Object? birthDate;
  final Object? sexAtBirth;
  final Object? heightCm;
  final Object? bloodType;
  final Object? onboardingCompleted;
}

class HealthAllergyWriteInput {
  const HealthAllergyWriteInput({
    required this.kind,
    required this.label,
    this.reaction,
    this.severity,
    this.note,
    this.recordedAt,
  });

  final HealthAllergyKind kind;
  final String label;
  final String? reaction;
  final HealthAllergySeverity? severity;
  final String? note;
  final String? recordedAt;
}

class HealthAllergyUpdateInput {
  const HealthAllergyUpdateInput({
    this.kind = healthContextNoChange,
    this.label = healthContextNoChange,
    this.reaction = healthContextNoChange,
    this.severity = healthContextNoChange,
    this.note = healthContextNoChange,
    this.recordedAt = healthContextNoChange,
    this.isActive = healthContextNoChange,
  });

  final Object? kind;
  final Object? label;
  final Object? reaction;
  final Object? severity;
  final Object? note;
  final Object? recordedAt;
  final Object? isActive;
}

class HealthConditionWriteInput {
  const HealthConditionWriteInput({
    required this.label,
    this.status,
    this.diagnosedAt,
    this.note,
  });

  final String label;
  final HealthConditionStatus? status;
  final String? diagnosedAt;
  final String? note;
}

class HealthConditionUpdateInput {
  const HealthConditionUpdateInput({
    this.label = healthContextNoChange,
    this.status = healthContextNoChange,
    this.diagnosedAt = healthContextNoChange,
    this.note = healthContextNoChange,
  });

  final Object? label;
  final Object? status;
  final Object? diagnosedAt;
  final Object? note;
}

class CurrentMedicineWriteInput {
  const CurrentMedicineWriteInput({
    required this.source,
    this.sourceRefId,
    required this.displayName,
    this.strengthText,
    this.doseText,
    this.route,
    this.startedAt,
    this.endedAt,
    this.note,
  });

  final HealthMedicineSource source;
  final String? sourceRefId;
  final String displayName;
  final String? strengthText;
  final String? doseText;
  final String? route;
  final String? startedAt;
  final String? endedAt;
  final String? note;
}

class CurrentMedicineUpdateInput {
  const CurrentMedicineUpdateInput({
    this.source = healthContextNoChange,
    this.sourceRefId = healthContextNoChange,
    this.displayName = healthContextNoChange,
    this.strengthText = healthContextNoChange,
    this.doseText = healthContextNoChange,
    this.route = healthContextNoChange,
    this.startedAt = healthContextNoChange,
    this.endedAt = healthContextNoChange,
    this.note = healthContextNoChange,
    this.isCurrent = healthContextNoChange,
  });

  final Object? source;
  final Object? sourceRefId;
  final Object? displayName;
  final Object? strengthText;
  final Object? doseText;
  final Object? route;
  final Object? startedAt;
  final Object? endedAt;
  final Object? note;
  final Object? isCurrent;
}
