import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/app_spacing_tokens.dart';

void main() {
  group('AppSpacingTokens', () {
    test('level1 is 4', () {
      expect(AppSpacingTokens.level1, equals(4));
    });

    test('level2 is 6', () {
      expect(AppSpacingTokens.level2, equals(6));
    });

    test('level3 is 10', () {
      expect(AppSpacingTokens.level3, equals(10));
    });

    test('level4 is 14', () {
      expect(AppSpacingTokens.level4, equals(14));
    });

    test('level5 is 20', () {
      expect(AppSpacingTokens.level5, equals(20));
    });

    test('level6 is 28', () {
      expect(AppSpacingTokens.level6, equals(28));
    });

    test('level7 is 36', () {
      expect(AppSpacingTokens.level7, equals(36));
    });

    test('level8 is 44', () {
      expect(AppSpacingTokens.level8, equals(44));
    });

    test('level9 is 56', () {
      expect(AppSpacingTokens.level9, equals(56));
    });

    test('level10 is 72', () {
      expect(AppSpacingTokens.level10, equals(72));
    });

    test('level11 is 96', () {
      expect(AppSpacingTokens.level11, equals(96));
    });

    test('level12 is 128', () {
      expect(AppSpacingTokens.level12, equals(128));
    });

    test('all values are positive', () {
      expect(AppSpacingTokens.level1, greaterThan(0));
      expect(AppSpacingTokens.level2, greaterThan(0));
      expect(AppSpacingTokens.level3, greaterThan(0));
      expect(AppSpacingTokens.level4, greaterThan(0));
      expect(AppSpacingTokens.level5, greaterThan(0));
      expect(AppSpacingTokens.level6, greaterThan(0));
      expect(AppSpacingTokens.level7, greaterThan(0));
      expect(AppSpacingTokens.level8, greaterThan(0));
      expect(AppSpacingTokens.level9, greaterThan(0));
      expect(AppSpacingTokens.level10, greaterThan(0));
      expect(AppSpacingTokens.level11, greaterThan(0));
      expect(AppSpacingTokens.level12, greaterThan(0));
    });

    test('values are strictly increasing', () {
      expect(AppSpacingTokens.level1, lessThan(AppSpacingTokens.level2));
      expect(AppSpacingTokens.level2, lessThan(AppSpacingTokens.level3));
      expect(AppSpacingTokens.level3, lessThan(AppSpacingTokens.level4));
      expect(AppSpacingTokens.level4, lessThan(AppSpacingTokens.level5));
      expect(AppSpacingTokens.level5, lessThan(AppSpacingTokens.level6));
      expect(AppSpacingTokens.level6, lessThan(AppSpacingTokens.level7));
      expect(AppSpacingTokens.level7, lessThan(AppSpacingTokens.level8));
      expect(AppSpacingTokens.level8, lessThan(AppSpacingTokens.level9));
      expect(AppSpacingTokens.level9, lessThan(AppSpacingTokens.level10));
      expect(AppSpacingTokens.level10, lessThan(AppSpacingTokens.level11));
      expect(AppSpacingTokens.level11, lessThan(AppSpacingTokens.level12));
    });
  });
}
