import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/design.dart';

void main() {
  group('Spacing', () {
    test('xs is 4', () {
      expect(Spacing.xs, equals(4));
    });

    test('sm is 6', () {
      expect(Spacing.sm, equals(6));
    });

    test('md is 10', () {
      expect(Spacing.md, equals(10));
    });

    test('lg is 14', () {
      expect(Spacing.lg, equals(14));
    });

    test('xl is 20', () {
      expect(Spacing.xl, equals(20));
    });

    test('xl2 is 28', () {
      expect(Spacing.xl2, equals(28));
    });

    test('xl3 is 36', () {
      expect(Spacing.xl3, equals(36));
    });

    test('xl4 is 44', () {
      expect(Spacing.xl4, equals(44));
    });

    test('xl5 is 56', () {
      expect(Spacing.xl5, equals(56));
    });

    test('xl6 is 72', () {
      expect(Spacing.xl6, equals(72));
    });

    test('xl7 is 96', () {
      expect(Spacing.xl7, equals(96));
    });

    test('xl8 is 128', () {
      expect(Spacing.xl8, equals(128));
    });

    test('all values are positive', () {
      expect(Spacing.xs, greaterThan(0));
      expect(Spacing.sm, greaterThan(0));
      expect(Spacing.md, greaterThan(0));
      expect(Spacing.lg, greaterThan(0));
      expect(Spacing.xl, greaterThan(0));
      expect(Spacing.xl2, greaterThan(0));
      expect(Spacing.xl3, greaterThan(0));
      expect(Spacing.xl4, greaterThan(0));
      expect(Spacing.xl5, greaterThan(0));
      expect(Spacing.xl6, greaterThan(0));
      expect(Spacing.xl7, greaterThan(0));
      expect(Spacing.xl8, greaterThan(0));
    });

    test('values are strictly increasing', () {
      expect(Spacing.xs, lessThan(Spacing.sm));
      expect(Spacing.sm, lessThan(Spacing.md));
      expect(Spacing.md, lessThan(Spacing.lg));
      expect(Spacing.lg, lessThan(Spacing.xl));
      expect(Spacing.xl, lessThan(Spacing.xl2));
      expect(Spacing.xl2, lessThan(Spacing.xl3));
      expect(Spacing.xl3, lessThan(Spacing.xl4));
      expect(Spacing.xl4, lessThan(Spacing.xl5));
      expect(Spacing.xl5, lessThan(Spacing.xl6));
      expect(Spacing.xl6, lessThan(Spacing.xl7));
      expect(Spacing.xl7, lessThan(Spacing.xl8));
    });
  });
}
