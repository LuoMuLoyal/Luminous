import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/features/health_context/data/mappers/health_context_mapper.dart';

UserHealthSummaryDto _s({
  Object? age,
  bool ob = false,
  num ac = 0,
  num cc = 0,
  num mc = 0,
}) {
  return UserHealthSummaryDto(
    age: age,
    onboardingCompleted: ob,
    activeAllergyCount: ac,
    conditionCount: cc,
    currentMedicineCount: mc,
    missingCoreProfileFields: const [],
  );
}

UserHealthProfileDto _p({Object? h, Object? bd, SexAtBirth? sx}) {
  return UserHealthProfileDto(
    heightCm: h,
    birthDate: bd,
    sexAtBirth: sx,
    bloodType: null,
    locale: null,
    timezone: null,
    unitSystem: null,
    onboardingCompletedAt: null,
    extras: null,
  );
}

void main() {
  final mapper = HealthContextMapper();

  group('fromDto - summary', () {
    test('maps fields', () {
      final dto = HealthContextDataDto(
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
      final dto = HealthContextDataDto(
        summary: _s(age: 'abc'),
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
      final dto = HealthContextDataDto(
        summary: _s(),
        profile: _p(h: 175, bd: '1990-01-15', sx: SexAtBirth.male),
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
      final dto = HealthContextDataDto(
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
      final dto = HealthContextDataDto(
        summary: _s(),
        profile: _p(),
        allergies: [
          UserAllergyItemDto(
            id: 'a1',
            kind: UserAllergyKind.drug,
            label: 'Penicillin',
            reaction: null,
            severity: null,
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
      final dto = HealthContextDataDto(
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
      final dto = HealthContextDataDto(
        summary: _s(age: 42),
        profile: _p(h: 165, sx: SexAtBirth.female),
        allergies: [
          UserAllergyItemDto(
            id: 'a1',
            kind: UserAllergyKind.drug,
            label: 'P',
            reaction: null,
            severity: null,
            isActive: true,
            note: null,
            extras: null,
            recordedAt: null,
            createdAt: 't',
            updatedAt: 't',
          ),
        ],
        conditions: [
          UserConditionItemDto(
            id: 'c1',
            label: 'H',
            status: UserConditionStatus.active,
            diagnosedAt: null,
            resolvedAt: null,
            note: null,
            extras: null,
            createdAt: 't',
            updatedAt: 't',
          ),
        ],
        currentMedicines: [
          UserCurrentMedicineItemDto(
            id: 'm1',
            source_: MedicineSource.manual,
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
