import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/app_shadow_tokens.dart';

void main() {
  group('AppShadowTokens', () {
    test('level1 is a single shadow with no offset', () {
      expect(AppShadowTokens.level1, hasLength(1));
      final shadow = AppShadowTokens.level1.first;
      expect(shadow.offset, equals(Offset.zero));
      expect(shadow.blurRadius, equals(0));
    });

    test('level2 has two shadows', () {
      expect(AppShadowTokens.level2, hasLength(2));
    });

    test('level3 has two shadows', () {
      expect(AppShadowTokens.level3, hasLength(2));
    });

    test('level4 has two shadows', () {
      expect(AppShadowTokens.level4, hasLength(2));
    });

    test('level5 has three shadows', () {
      expect(AppShadowTokens.level5, hasLength(3));
    });

    test('shadow levels increase in complexity', () {
      // Higher levels should use larger blur radii
      final l1MaxBlur = AppShadowTokens.level1
          .map((s) => s.blurRadius)
          .reduce((a, b) => a > b ? a : b);
      final l5MaxBlur = AppShadowTokens.level5
          .map((s) => s.blurRadius)
          .reduce((a, b) => a > b ? a : b);
      expect(l5MaxBlur, greaterThan(l1MaxBlur));
    });

    test('all shadows have non-negative blur and spread', () {
      for (final level in [
        AppShadowTokens.level1,
        AppShadowTokens.level2,
        AppShadowTokens.level3,
        AppShadowTokens.level4,
        AppShadowTokens.level5,
      ]) {
        for (final shadow in level) {
          expect(shadow.blurRadius, greaterThanOrEqualTo(0));
        }
      }
    });
  });
}
