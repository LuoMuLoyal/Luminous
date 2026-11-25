import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/features/health_context/data/mappers/health_context.dart';

ContextResponseSummary _s({
  Object? age,
  bool ob = false,
  num ac = 0,
  num cc = 0,
  num mc = 0,
}) {
  return ContextResponseSummary(
    age: age is num ? age : null,
    onboardingCompleted: ob,
    activeAllergyCount: ac,
    conditionCount: cc,
    currentMedicineCount: mc,
    missingCoreProfileFields: const [],
  );
}

ContextResponseProfile _p({
  Object? h,
  Object? bd,
  ContextResponseProfileSexAtBirthEnum sx =
      ContextResponseProfileSexAtBirthEnum.male,
}) {
  return ContextResponseProfile(
    heightCm: h as num?,
    birthDate: bd as String?,
    sexAtBirth: sx,
    weightKg: null,
    activityLevel: null,
    dietaryPreferences: null,
    locale: null,
    timezone: null,
    unitSystem: ContextResponseProfileUnitSystemEnum.metric,
    onboardingCompletedAt: null,
    extras: null,
  );
}

void main() {
  final mapper = HealthContextMapper();

  group('fromDto - summary', () {
    test('maps fields', () {
      final dto = ContextResponse(
        summary: _s(age: 30, ob: true, ac: 2, cc: 1, mc: 3),
        profile: _p(),
        allergies: const [],
        conditions: const [],
        currentMedicines: const [],
      );
      final s = mapper.fromDto(dto).summary;
      expect(s.age, 30);
      expect(s.onboardingCompleted, true);
      expect(s.activeAllergyCount, 2);
      expect(s.currentMedicineCount, 3);
    });
    test('non-int age → null', () {
      final dto = ContextResponse(
        summary: _s(age: 30.5),
        profile: _p(),
        allergies: const [],
        conditions: const [],
        currentMedicines: const [],
      );
      expect(mapper.fromDto(dto).summary.age, isNull);
    });
  });

  group('fromDto - profile', () {
    test('maps fields', () {
      final dto = ContextResponse(
        summary: _s(),
        profile: _p(
          h: 175,
          bd: '1990-01-15',
          sx: ContextResponseProfileSexAtBirthEnum.male,
        ),
        allergies: const [],
        conditions: const [],
        currentMedicines: const [],
      );
      final p = mapper.fromDto(dto).profile;
      expect(p.heightCm, 175);
      expect(p.birthDate, '1990-01-15');
      expect(p.sexAtBirth, 'male');
    });
    test('nulls propagate', () {
      final dto = ContextResponse(
        summary: _s(),
        profile: _p(),
        allergies: const [],
        conditions: const [],
        currentMedicines: const [],
      );
      final p = mapper.fromDto(dto).profile;
      expect(p.heightCm, isNull);
      expect(p.birthDate, isNull);
    });
  });

  group('fromDto - allergies', () {
    test('maps fields', () {
      final dto = ContextResponse(
        summary: _s(),
        profile: _p(),
        allergies: [
          ContextResponseAllergies(
            id: 'a1',
            kind: ContextResponseAllergiesKindEnum.drug,
            label: 'Penicillin',
            reaction: null,
            severity: ContextResponseAllergiesSeverityEnum.mild,
            isActive: true,
            note: null,
            extras: null,
            recordedAt: null,
            createdAt: 't',
            updatedAt: 't',
          ),
        ],
        conditions: const [],
        currentMedicines: const [],
      );
      final a = mapper.fromDto(dto).allergies.first;
      expect(a.id, 'a1');
      expect(a.label, 'Penicillin');
    });
    test('empty list', () {
      final dto = ContextResponse(
        summary: _s(),
        profile: _p(),
        allergies: const [],
        conditions: const [],
        currentMedicines: const [],
      );
      expect(mapper.fromDto(dto).allergies, isEmpty);
    });
  });

  group('fromDto - full integration', () {
    test('complete dto', () {
      final dto = ContextResponse(
        summary: _s(age: 42),
        profile: _p(h: 165, sx: ContextResponseProfileSexAtBirthEnum.female),
        allergies: [
          ContextResponseAllergies(
            id: 'a1',
            kind: ContextResponseAllergiesKindEnum.drug,
            label: 'P',
            reaction: null,
            severity: ContextResponseAllergiesSeverityEnum.mild,
            isActive: true,
            note: null,
            extras: null,
            recordedAt: null,
            createdAt: 't',
            updatedAt: 't',
          ),
        ],
        conditions: [
          ContextResponseConditions(
            id: 'c1',
            label: 'H',
            status: ContextResponseConditionsStatusEnum.active,
            diagnosedAt: null,
            resolvedAt: null,
            note: null,
            extras: null,
            createdAt: 't',
            updatedAt: 't',
          ),
        ],
        currentMedicines: [
          ContextResponseCurrentMedicines(
            id: 'm1',
            source_: ContextResponseCurrentMedicinesSource_Enum.manual,
            sourceRefId: null,
            displayName: 'Aspirin',
            strengthText: null,
            doseText: null,
            route: null,
            startedAt: null,
            endedAt: null,
            isCurrent: true,
            note: null,
            sourcePayload: null,
            createdAt: 't',
            updatedAt: 't',
          ),
        ],
      );
      final s = mapper.fromDto(dto);
      expect(s.summary.age, 42);
      expect(s.profile.sexAtBirth, 'female');
      expect(s.allergies.first.id, 'a1');
      expect(s.conditions.first.id, 'c1');
      expect(s.currentMedicines.first.id, 'm1');
    });
  });
}
