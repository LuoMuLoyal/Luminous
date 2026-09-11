import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/design.dart';

void main() {
  group('IconSizeTokens', () {
    test('xs is 12', () {
      expect(IconSizeTokens.xs, equals(12));
    });

    test('sm is 16', () {
      expect(IconSizeTokens.sm, equals(16));
    });

    test('md is 20', () {
      expect(IconSizeTokens.md, equals(20));
    });

    test('lg is 24', () {
      expect(IconSizeTokens.lg, equals(24));
    });

    test('xl is 28', () {
      expect(IconSizeTokens.xl, equals(28));
    });

    test('xl2 is 32', () {
      expect(IconSizeTokens.xl2, equals(32));
    });

    test('xl3 is 48', () {
      expect(IconSizeTokens.xl3, equals(48));
    });

    test('xl4 is 64', () {
      expect(IconSizeTokens.xl4, equals(64));
    });

    test('all values are positive', () {
      expect(IconSizeTokens.xs, greaterThan(0));
      expect(IconSizeTokens.sm, greaterThan(0));
      expect(IconSizeTokens.md, greaterThan(0));
      expect(IconSizeTokens.lg, greaterThan(0));
      expect(IconSizeTokens.xl, greaterThan(0));
      expect(IconSizeTokens.xl2, greaterThan(0));
      expect(IconSizeTokens.xl3, greaterThan(0));
      expect(IconSizeTokens.xl4, greaterThan(0));
    });

    test('values are strictly increasing', () {
      expect(IconSizeTokens.xs, lessThan(IconSizeTokens.sm));
      expect(IconSizeTokens.sm, lessThan(IconSizeTokens.md));
      expect(IconSizeTokens.md, lessThan(IconSizeTokens.lg));
      expect(IconSizeTokens.lg, lessThan(IconSizeTokens.xl));
      expect(IconSizeTokens.xl, lessThan(IconSizeTokens.xl2));
      expect(IconSizeTokens.xl2, lessThan(IconSizeTokens.xl3));
      expect(IconSizeTokens.xl3, lessThan(IconSizeTokens.xl4));
    });
  });
}
