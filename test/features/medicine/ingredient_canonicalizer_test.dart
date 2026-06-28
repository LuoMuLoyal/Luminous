import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/medicine/domain/services/ingredient_canonicalizer.dart';
import 'package:luminous/features/medicine/domain/services/medicine_risk_checker_utils.dart';

void main() {
  group('canonicalIngredientKeysFor', () {
    test('maps acetaminophen variants to canonical key', () {
      final result = canonicalIngredientKeysFor(
        {'acetaminophen'}.map(normalizeToken).toSet(),
      );
      expect(result, contains('acetaminophen'));
    });

    test('maps Chinese 对乙酰氨基酚 to acetaminophen', () {
      final result = canonicalIngredientKeysFor(
        {'对乙酰氨基酚'}.map(normalizeToken).toSet(),
      );
      expect(result, contains('acetaminophen'));
    });

    test('returns unknown tokens as-is', () {
      final result = canonicalIngredientKeysFor(
        {'unknown_herb'}.map(normalizeToken).toSet(),
      );
      expect(result, contains('unknown_herb'));
    });

    test('maps multiple tokens correctly', () {
      final tokens = {'aspirin', '布洛芬'}.map(normalizeToken).toSet();
      final result = canonicalIngredientKeysFor(tokens);
      expect(result, contains('aspirin'));
      expect(result, contains('ibuprofen'));
    });
  });

  group('expandCanonicalIngredientTokens', () {
    test('expands aspirin to all known variants', () {
      final result = expandCanonicalIngredientTokens(
        {'aspirin'}.map(normalizeToken).toSet(),
      );
      expect(result, contains('aspirin'));
      expect(result, contains('acetylsalicylicacid'));
      expect(result, contains('乙酰水杨酸'));
      expect(result, contains('阿司匹林'));
    });

    test('keeps unmatched token and does not expand unrelated groups', () {
      final result = expandCanonicalIngredientTokens(
        {'unknown_herb'}.map(normalizeToken).toSet(),
      );
      expect(result, hasLength(1));
      expect(result, contains('unknown_herb'));
    });
  });

  group('normalizeToken', () {
    test('lowercases and removes spaces', () {
      // Imported from the utils file
      expect(normalizeToken(' Aspirin '), 'aspirin');
      expect(normalizeToken('  Paracetamol  '), 'paracetamol');
      expect(normalizeToken('阿莫西林'), '阿莫西林');
    });
  });
}
