import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/app_radius_tokens.dart';

void main() {
  group('AppRadiusTokens', () {
    test('none is 0', () {
      expect(AppRadiusTokens.none, equals(0));
    });

    test('xs is 4', () {
      expect(AppRadiusTokens.xs, equals(4));
    });

    test('sm is 6', () {
      expect(AppRadiusTokens.sm, equals(6));
    });

    test('md is 8', () {
      expect(AppRadiusTokens.md, equals(8));
    });

    test('lg is 12', () {
      expect(AppRadiusTokens.lg, equals(12));
    });

    test('xl is 16', () {
      expect(AppRadiusTokens.xl, equals(16));
    });

    test('pillSm is 64', () {
      expect(AppRadiusTokens.pillSm, equals(64));
    });

    test('pill is 100', () {
      expect(AppRadiusTokens.pill, equals(100));
    });

    test('full is 9999', () {
      expect(AppRadiusTokens.full, equals(9999));
    });
  });
}
