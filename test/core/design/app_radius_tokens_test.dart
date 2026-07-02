import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/app_radius_tokens.dart';

void main() {
  group('AppRadiusTokens', () {
    test('level0 is 0', () {
      expect(AppRadiusTokens.level0, equals(0));
    });

    test('level1 is 4', () {
      expect(AppRadiusTokens.level1, equals(4));
    });

    test('level2 is 8', () {
      expect(AppRadiusTokens.level2, equals(8));
    });

    test('level3 is 12', () {
      expect(AppRadiusTokens.level3, equals(12));
    });

    test('level4 is 16', () {
      expect(AppRadiusTokens.level4, equals(16));
    });

    test('level5 is 20', () {
      expect(AppRadiusTokens.level5, equals(20));
    });

    test('levelFull is 9999', () {
      expect(AppRadiusTokens.levelFull, equals(9999));
    });

    test('values are non-negative', () {
      expect(AppRadiusTokens.level0, greaterThanOrEqualTo(0));
      expect(AppRadiusTokens.level1, greaterThanOrEqualTo(0));
      expect(AppRadiusTokens.level2, greaterThanOrEqualTo(0));
      expect(AppRadiusTokens.level3, greaterThanOrEqualTo(0));
      expect(AppRadiusTokens.level4, greaterThanOrEqualTo(0));
      expect(AppRadiusTokens.level5, greaterThanOrEqualTo(0));
      expect(AppRadiusTokens.levelFull, greaterThanOrEqualTo(0));
    });

    test('values are weakly increasing', () {
      expect(AppRadiusTokens.level0, lessThanOrEqualTo(AppRadiusTokens.level1));
      expect(AppRadiusTokens.level1, lessThanOrEqualTo(AppRadiusTokens.level2));
      expect(AppRadiusTokens.level2, lessThanOrEqualTo(AppRadiusTokens.level3));
      expect(AppRadiusTokens.level3, lessThanOrEqualTo(AppRadiusTokens.level4));
      expect(AppRadiusTokens.level4, lessThanOrEqualTo(AppRadiusTokens.level5));
      expect(AppRadiusTokens.level5, lessThanOrEqualTo(AppRadiusTokens.levelFull));
    });
  });
}
