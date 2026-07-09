import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/design.dart';

void main() {
  group('RadiusTokens', () {
    test('level0 is 0', () {
      expect(RadiusTokens.level0, equals(0));
    });

    test('level1 is 4', () {
      expect(RadiusTokens.level1, equals(4));
    });

    test('level2 is 6 (Forui xs)', () {
      expect(RadiusTokens.level2, equals(6));
    });

    test('level3 is 8 (Forui sm)', () {
      expect(RadiusTokens.level3, equals(8));
    });

    test('level4 is 10 (Forui md)', () {
      expect(RadiusTokens.level4, equals(10));
    });

    test('level5 is 14 (Forui lg)', () {
      expect(RadiusTokens.level5, equals(14));
    });

    test('levelFull is 100 (Forui pill)', () {
      expect(RadiusTokens.levelFull, equals(100));
    });

    test('values are non-negative', () {
      expect(RadiusTokens.level0, greaterThanOrEqualTo(0));
      expect(RadiusTokens.level1, greaterThanOrEqualTo(0));
      expect(RadiusTokens.level2, greaterThanOrEqualTo(0));
      expect(RadiusTokens.level3, greaterThanOrEqualTo(0));
      expect(RadiusTokens.level4, greaterThanOrEqualTo(0));
      expect(RadiusTokens.level5, greaterThanOrEqualTo(0));
      expect(RadiusTokens.levelFull, greaterThanOrEqualTo(0));
    });

    test('values are weakly increasing', () {
      expect(RadiusTokens.level0, lessThanOrEqualTo(RadiusTokens.level1));
      expect(RadiusTokens.level1, lessThanOrEqualTo(RadiusTokens.level2));
      expect(RadiusTokens.level2, lessThanOrEqualTo(RadiusTokens.level3));
      expect(RadiusTokens.level3, lessThanOrEqualTo(RadiusTokens.level4));
      expect(RadiusTokens.level4, lessThanOrEqualTo(RadiusTokens.level5));
      expect(RadiusTokens.level5, lessThanOrEqualTo(RadiusTokens.levelFull));
    });
  });
}
