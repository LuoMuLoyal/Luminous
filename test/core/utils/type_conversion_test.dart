import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/utils/type_conversion.dart';

void main() {
  group('asMap', () {
    test('returns the map when already Map<String, dynamic>', () {
      final input = <String, dynamic>{'a': 1, 'b': 'hello'};
      expect(asMap(input), same(input));
    });

    test(
      'converts generic Map with non-string keys to Map<String, dynamic>',
      () {
        final input = <Object, dynamic>{1: 'one', 'two': 2};
        final result = asMap(input);
        expect(result, isA<Map<String, dynamic>>());
        expect(result?['1'], 'one');
        expect(result?['two'], 2);
      },
    );

    test('returns null for null input', () {
      expect(asMap(null), isNull);
    });

    test('returns null for non-map input', () {
      expect(asMap('not a map'), isNull);
      expect(asMap(42), isNull);
      expect(asMap([1, 2, 3]), isNull);
    });

    test('returns empty map for empty map input', () {
      expect(asMap(<String, dynamic>{}), <String, dynamic>{});
    });
  });

  group('asList', () {
    test('returns the list cast to List<Object?> for a list input', () {
      final result = asList([1, 'two', true, null]);
      expect(result, [1, 'two', true, null]);
    });

    test('returns empty list for null input', () {
      expect(asList(null), const <Object?>[]);
    });

    test('returns empty list for non-list input', () {
      expect(asList('not a list'), const <Object?>[]);
      expect(asList(42), const <Object?>[]);
      expect(asList({'a': 1}), const <Object?>[]);
    });

    test('returns empty list for empty list input', () {
      expect(asList([]), const <Object?>[]);
    });

    test('preserves list elements including nested maps', () {
      final result = asList([
        {'key': 'value'},
        [1, 2],
        null,
      ]);
      expect(result.length, 3);
      expect(result[0], {'key': 'value'});
      expect(result[1], [1, 2]);
      expect(result[2], isNull);
    });
  });

  group('asString', () {
    test('returns trimmed string for string input', () {
      expect(asString('  hello  '), 'hello');
    });

    test('returns null for null input', () {
      expect(asString(null), isNull);
    });

    test('returns null for empty string', () {
      expect(asString(''), isNull);
    });

    test('returns null for whitespace-only string', () {
      expect(asString('   '), isNull);
    });

    test('returns string representation of numbers', () {
      expect(asString(42), '42');
      expect(asString(3.14), '3.14');
    });

    test('returns string representation of boolean', () {
      expect(asString(true), 'true');
    });

    test('returns null for empty toString result', () {
      // An object whose toString() returns empty
      expect(asString(_EmptyToString()), isNull);
    });
  });

  group('asNum', () {
    test('returns the value when already a num', () {
      expect(asNum(42), 42);
      expect(asNum(3.14), 3.14);
    });

    test('parses numeric string', () {
      expect(asNum('42'), 42);
      expect(asNum('3.14'), 3.14);
    });

    test('returns null for null input', () {
      expect(asNum(null), isNull);
    });

    test('returns null for non-numeric string', () {
      expect(asNum('hello'), isNull);
      expect(asNum(''), isNull);
    });

    test('returns null for boolean input', () {
      // bool.toString() is 'true'/'false' which num.tryParse cannot parse
      expect(asNum(true), isNull);
    });

    test('parses negative numbers', () {
      expect(asNum('-42'), -42);
      expect(asNum(-3.14), -3.14);
    });

    test('parses zero', () {
      expect(asNum(0), 0);
      expect(asNum('0'), 0);
    });
  });
}

class _EmptyToString {
  @override
  String toString() => '';
}
