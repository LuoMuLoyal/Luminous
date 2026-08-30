import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/design.dart';

void main() {
  group('Spacing', () {
    test('level1 is 4', () {
      expect(Spacing.level1, equals(4));
    });

    test('level2 is 6', () {
      expect(Spacing.level2, equals(6));
    });

    test('level3 is 10', () {
      expect(Spacing.level3, equals(10));
    });

    test('level4 is 14', () {
      expect(Spacing.level4, equals(14));
    });

    test('level5 is 20', () {
      expect(Spacing.level5, equals(20));
    });

    test('level6 is 28', () {
      expect(Spacing.level6, equals(28));
    });

    test('level7 is 36', () {
      expect(Spacing.level7, equals(36));
    });

    test('level8 is 44', () {
      expect(Spacing.level8, equals(44));
    });

    test('level9 is 56', () {
      expect(Spacing.level9, equals(56));
    });

    test('level10 is 72', () {
      expect(Spacing.level10, equals(72));
    });

    test('level11 is 96', () {
      expect(Spacing.level11, equals(96));
    });

    test('level12 is 128', () {
      expect(Spacing.level12, equals(128));
    });

    test('all values are positive', () {
      expect(Spacing.level1, greaterThan(0));
      expect(Spacing.level2, greaterThan(0));
      expect(Spacing.level3, greaterThan(0));
      expect(Spacing.level4, greaterThan(0));
      expect(Spacing.level5, greaterThan(0));
      expect(Spacing.level6, greaterThan(0));
      expect(Spacing.level7, greaterThan(0));
      expect(Spacing.level8, greaterThan(0));
      expect(Spacing.level9, greaterThan(0));
      expect(Spacing.level10, greaterThan(0));
      expect(Spacing.level11, greaterThan(0));
      expect(Spacing.level12, greaterThan(0));
    });

    test('values are strictly increasing', () {
      expect(Spacing.level1, lessThan(Spacing.level2));
      expect(Spacing.level2, lessThan(Spacing.level3));
      expect(Spacing.level3, lessThan(Spacing.level4));
      expect(Spacing.level4, lessThan(Spacing.level5));
      expect(Spacing.level5, lessThan(Spacing.level6));
      expect(Spacing.level6, lessThan(Spacing.level7));
      expect(Spacing.level7, lessThan(Spacing.level8));
      expect(Spacing.level8, lessThan(Spacing.level9));
      expect(Spacing.level9, lessThan(Spacing.level10));
      expect(Spacing.level10, lessThan(Spacing.level11));
      expect(Spacing.level11, lessThan(Spacing.level12));
    });

    test('semantic aliases equal level values', () {
      expect(Spacing.xs, Spacing.level1);
      expect(Spacing.xs, 4);
      expect(Spacing.sm, Spacing.level2);
      expect(Spacing.sm, 6);
      expect(Spacing.md, Spacing.level3);
      expect(Spacing.md, 10);
      expect(Spacing.lg, Spacing.level4);
      expect(Spacing.lg, 14);
      expect(Spacing.xl, Spacing.level5);
      expect(Spacing.xl, 20);
      expect(Spacing.xl2, Spacing.level6);
      expect(Spacing.xl2, 28);
      expect(Spacing.xl3, Spacing.level7);
      expect(Spacing.xl3, 36);
      expect(Spacing.xl4, Spacing.level8);
      expect(Spacing.xl4, 44);
      expect(Spacing.xl5, Spacing.level9);
      expect(Spacing.xl5, 56);
      expect(Spacing.xl6, Spacing.level10);
      expect(Spacing.xl6, 72);
      expect(Spacing.xl7, Spacing.level11);
      expect(Spacing.xl7, 96);
      expect(Spacing.xl8, Spacing.level12);
      expect(Spacing.xl8, 128);
    });

    test('semantic aliases are strictly increasing', () {
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
