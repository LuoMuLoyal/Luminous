import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/network/map_utils.dart';

void main() {
  group('coerceToStringMap', () {
    test('returns null for null input', () {
      expect(coerceToStringMap(null), isNull);
    });

    test('returns the same map when already Map<String, dynamic>', () {
      final input = <String, dynamic>{'a': 1, 'b': 'two'};
      final result = coerceToStringMap(input);
      expect(result, same(input));
    });

    test('coerces Map<dynamic, dynamic> keys to String', () {
      final input = <dynamic, dynamic>{1: 'one', 2: 'two'};
      final result = coerceToStringMap(input);
      expect(result, isA<Map<String, dynamic>>());
      expect(result!['1'], equals('one'));
      expect(result['2'], equals('two'));
    });

    test('coerces Map<Object?, Object?> keys to String', () {
      final input = <Object?, Object?>{'key': 'value', 42: 'answer'};
      final result = coerceToStringMap(input);
      expect(result, isA<Map<String, dynamic>>());
      expect(result!['key'], equals('value'));
      expect(result['42'], equals('answer'));
    });

    test('returns null for non-Map types', () {
      expect(coerceToStringMap('string'), isNull);
      expect(coerceToStringMap(42), isNull);
      expect(coerceToStringMap([1, 2, 3]), isNull);
    });
  });
}
