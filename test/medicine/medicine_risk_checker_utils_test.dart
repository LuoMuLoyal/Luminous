import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/medicine/domain/services/medicine_risk_checker_utils.dart';

void main() {
  group('normalizeToken', () {
    test('lowercases and removes spaces', () {
      expect(normalizeToken(' Aspirin '), 'aspirin');
      expect(normalizeToken('  Paracetamol  '), 'paracetamol');
    });
  });

  group('asNonEmptyString', () {
    test('returns null for null', () {
      expect(asNonEmptyString(null), isNull);
    });
    test('returns null for empty string', () {
      expect(asNonEmptyString(''), isNull);
    });
    test('returns null for whitespace-only', () {
      expect(asNonEmptyString('   '), isNull);
    });
    test('returns trimmed value for non-empty', () {
      expect(asNonEmptyString('  hello  '), 'hello');
    });
    test('handles non-string Object', () {
      expect(asNonEmptyString(42), '42');
    });
  });

  group('firstNonEmpty', () {
    test('returns first non-empty', () {
      expect(firstNonEmpty('', null, 'c'), 'c');
    });
    test('returns null when all empty', () {
      expect(firstNonEmpty(null, '', ''), isNull);
    });
    test('returns a when it is non-empty', () {
      expect(firstNonEmpty('a', 'b', 'c'), 'a');
    });
  });

  group('extractIngredientTokens', () {
    test('splits on common separators', () {
      final result = extractIngredientTokens('aspirin,ibuprofen');
      expect(result, contains('aspirin'));
      expect(result, contains('ibuprofen'));
    });

    test('normalizes Chinese punctuation', () {
      final result = extractIngredientTokens('阿莫西林、布洛芬');
      expect(result, contains('阿莫西林'));
      expect(result, contains('布洛芬'));
    });

    test('filters single-char tokens', () {
      final result = extractIngredientTokens('a,b');
      expect(result, isEmpty);
    });
  });

  group('cleanIngredientToken', () {
    test('removes strength suffixes', () {
      expect(cleanIngredientToken('Ibuprofen 200mg'), 'ibuprofen');
    });
    test('returns null for empty input', () {
      expect(cleanIngredientToken('   '), isNull);
    });
    test(
      'returns null for single char',
      () => expect(cleanIngredientToken('x'), isNull),
    );
  });

  group('duplicateIngredientEvidence', () {
    test('joins sorted tokens', () {
      expect(
        duplicateIngredientEvidence(
          {'ibuprofen', 'aspirin'}.map(normalizeToken).toSet(),
        ),
        'aspirin / ibuprofen',
      );
    });
  });
}
