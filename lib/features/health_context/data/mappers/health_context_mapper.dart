import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';

/// Maps Lucent OpenAPI DTOs to domain entities.
class HealthContextMapper {
  HealthContextSnapshot fromDto(HealthContextDataDto dto) {
    return HealthContextSnapshot(
      summary: _mapSummary(dto.summary),
      profile: _mapProfile(dto.profile),
      allergies: dto.allergies.map(_mapAllergy).toList(),
      conditions: dto.conditions.map(_mapCondition).toList(),
      currentMedicines: dto.currentMedicines.map(_mapCurrentMedicine).toList(),
    );
  }

  HealthSummary _mapSummary(UserHealthSummaryDto s) {
    return HealthSummary(
      age: s.age is int ? (s.age as int) : null,
      onboardingCompleted: s.onboardingCompleted,
      activeAllergyCount: s.activeAllergyCount.toInt(),
      conditionCount: s.conditionCount.toInt(),
      currentMedicineCount: s.currentMedicineCount.toInt(),
      missingCoreProfileFields: s.missingCoreProfileFields,
    );
  }

  HealthProfile _mapProfile(UserHealthProfileDto p) {
    return HealthProfile(
      birthDate: p.birthDate?.toString(),
      sexAtBirth: p.sexAtBirth?.name,
      heightCm: p.heightCm is num ? (p.heightCm as num).toDouble() : null,
      bloodType: p.bloodType?.toString(),
      locale: p.locale?.toString(),
      timezone: p.timezone?.toString(),
      unitSystem: p.unitSystem?.name,
      onboardingCompletedAt: p.onboardingCompletedAt?.toString(),
      extras: Map<String, dynamic>.from(p.extras ?? const {}),
    );
  }

  AllergyItem _mapAllergy(UserAllergyItemDto a) {
    return AllergyItem(
      id: a.id,
      kind: a.kind.name,
      label: a.label,
      reaction: a.reaction?.toString(),
      severity: a.severity?.name,
      isActive: a.isActive,
      note: a.note?.toString(),
      createdAt: a.createdAt,
      updatedAt: a.updatedAt,
    );
  }

  ConditionItem _mapCondition(UserConditionItemDto c) {
    return ConditionItem(
      id: c.id,
      label: c.label,
      status: c.status.name,
      diagnosedAt: c.diagnosedAt?.toString(),
      resolvedAt: c.resolvedAt?.toString(),
      note: c.note?.toString(),
      createdAt: c.createdAt,
      updatedAt: c.updatedAt,
    );
  }

  CurrentMedicineItem _mapCurrentMedicine(UserCurrentMedicineItemDto m) {
    return CurrentMedicineItem(
      id: m.id,
      source: m.source_.name,
      sourceRefId: m.sourceRefId?.toString(),
      displayName: m.displayName,
      strengthText: m.strengthText?.toString(),
      doseText: m.doseText?.toString(),
      route: m.route?.toString(),
      startedAt: m.startedAt?.toString(),
      endedAt: m.endedAt?.toString(),
      isCurrent: m.isCurrent,
      note: m.note?.toString(),
      createdAt: m.createdAt,
      updatedAt: m.updatedAt,
    );
  }
}
