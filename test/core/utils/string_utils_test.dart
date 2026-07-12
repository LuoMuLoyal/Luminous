import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/utils/string_utils.dart';

void main() {
  group('normalizeNullableText', () {
    test('returns null for null input', () {
      expect(normalizeNullableText(null), isNull);
    });

    test('returns null for empty string', () {
      expect(normalizeNullableText(''), isNull);
    });

    test('returns null for whitespace-only string', () {
      expect(normalizeNullableText('   '), isNull);
      expect(normalizeNullableText('\t\n'), isNull);
    });

    test('trims surrounding whitespace', () {
      expect(normalizeNullableText('  hello  '), 'hello');
    });

    test('preserves internal whitespace', () {
      expect(normalizeNullableText('  hello world  '), 'hello world');
    });

    test('returns non-empty string as-is when no trimming needed', () {
      expect(normalizeNullableText('hello'), 'hello');
    });
  });
}
