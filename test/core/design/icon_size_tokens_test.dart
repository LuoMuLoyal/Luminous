import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/design.dart';

void main() {
  group('IconSizeTokens', () {
    test('level1 is 12', () {
      expect(IconSizeTokens.level1, equals(12));
    });

    test('level2 is 16', () {
      expect(IconSizeTokens.level2, equals(16));
    });

    test('level3 is 20', () {
      expect(IconSizeTokens.level3, equals(20));
    });

    test('level4 is 24', () {
      expect(IconSizeTokens.level4, equals(24));
    });

    test('level5 is 28', () {
      expect(IconSizeTokens.level5, equals(28));
    });

    test('level6 is 32', () {
      expect(IconSizeTokens.level6, equals(32));
    });

    test('level7 is 48', () {
      expect(IconSizeTokens.level7, equals(48));
    });

    test('level8 is 64', () {
      expect(IconSizeTokens.level8, equals(64));
    });

    test('semantic aliases equal level values', () {
      expect(IconSizeTokens.xs, IconSizeTokens.level1);
      expect(IconSizeTokens.xs, 12);
      expect(IconSizeTokens.sm, IconSizeTokens.level2);
      expect(IconSizeTokens.sm, 16);
      expect(IconSizeTokens.md, IconSizeTokens.level3);
      expect(IconSizeTokens.md, 20);
      expect(IconSizeTokens.lg, IconSizeTokens.level4);
      expect(IconSizeTokens.lg, 24);
      expect(IconSizeTokens.xl, IconSizeTokens.level5);
      expect(IconSizeTokens.xl, 28);
      expect(IconSizeTokens.xl2, IconSizeTokens.level6);
      expect(IconSizeTokens.xl2, 32);
      expect(IconSizeTokens.xl3, IconSizeTokens.level7);
      expect(IconSizeTokens.xl3, 48);
      expect(IconSizeTokens.xl4, IconSizeTokens.level8);
      expect(IconSizeTokens.xl4, 64);
    });

    test('semantic aliases are strictly increasing', () {
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
