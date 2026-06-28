import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/medicine/domain/services/allergy_severity_helper.dart';

AllergyItem _allergy({
  required String kind,
  required String label,
  String? severity,
  String? reaction,
}) {
  return AllergyItem(
    id: '1',
    kind: kind,
    label: label,
    reaction: reaction,
    severity: severity,
    isActive: true,
    note: null,
    createdAt: '2026-06-10T08:00:00.000Z',
    updatedAt: '2026-06-10T08:00:00.000Z',
  );
}

void main() {
  group('inferredAllergySeverity', () {
    test('returns severity when already set and valid', () {
      final a = _allergy(
        kind: 'drug',
        label: 'Penicillin',
        severity: 'moderate',
      );
      expect(inferredAllergySeverity(a), 'moderate');
    });

    test(
      'returns severe when reaction contains Chinese anaphylaxis keyword',
      () {
        final a = _allergy(kind: 'food', label: 'Peanut', reaction: '过敏性休克');
        expect(inferredAllergySeverity(a), 'severe');
      },
    );

    test('returns severe for English anaphylaxis keyword', () {
      final a = _allergy(
        kind: 'environment',
        label: 'Bee sting',
        reaction: 'Patient experienced anaphylaxis',
      );
      expect(inferredAllergySeverity(a), 'severe');
    });

    test('returns unknown when severity is null and no reaction', () {
      final a = _allergy(kind: 'drug', label: 'Test');
      expect(inferredAllergySeverity(a), 'unknown');
    });

    test('returns unknown when severity is "unknown"', () {
      final a = _allergy(kind: 'drug', label: 'Test', severity: 'unknown');
      expect(inferredAllergySeverity(a), 'unknown');
    });
  });

  group('isSevereAllergy', () {
    test('returns true for severe allergies', () {
      final a = _allergy(kind: 'drug', label: 'Penicillin', severity: 'severe');
      expect(isSevereAllergy(a), isTrue);
    });

    test('returns false for non-severe allergies', () {
      final a = _allergy(kind: 'drug', label: 'Penicillin', severity: 'mild');
      expect(isSevereAllergy(a), isFalse);
    });

    test('returns true when reaction indicates anaphylaxis', () {
      final a = _allergy(
        kind: 'food',
        label: 'Peanut',
        reaction: 'Anaphylactic shock',
      );
      expect(isSevereAllergy(a), isTrue);
    });
  });
}
