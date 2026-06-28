import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/app_spacing_tokens.dart';

void main() {
  group('AppSpacingTokens', () {
    test('xxs is 4', () {
      expect(AppSpacingTokens.xxs, equals(4));
    });

    test('xs is 8', () {
      expect(AppSpacingTokens.xs, equals(8));
    });

    test('sm is 12', () {
      expect(AppSpacingTokens.sm, equals(12));
    });

    test('md is 16', () {
      expect(AppSpacingTokens.md, equals(16));
    });

    test('lg is 24', () {
      expect(AppSpacingTokens.lg, equals(24));
    });

    test('xl is 32', () {
      expect(AppSpacingTokens.xl, equals(32));
    });

    test('x2l is 40', () {
      expect(AppSpacingTokens.x2l, equals(40));
    });

    test('x3l is 48', () {
      expect(AppSpacingTokens.x3l, equals(48));
    });

    test('x4l is 64', () {
      expect(AppSpacingTokens.x4l, equals(64));
    });

    test('x5l is 96', () {
      expect(AppSpacingTokens.x5l, equals(96));
    });

    test('x6l is 128', () {
      expect(AppSpacingTokens.x6l, equals(128));
    });

    test('section is 192', () {
      expect(AppSpacingTokens.section, equals(192));
    });

    test('all values are positive', () {
      expect(AppSpacingTokens.xxs, greaterThan(0));
      expect(AppSpacingTokens.xs, greaterThan(0));
      expect(AppSpacingTokens.sm, greaterThan(0));
      expect(AppSpacingTokens.md, greaterThan(0));
      expect(AppSpacingTokens.lg, greaterThan(0));
      expect(AppSpacingTokens.xl, greaterThan(0));
      expect(AppSpacingTokens.x2l, greaterThan(0));
      expect(AppSpacingTokens.x3l, greaterThan(0));
      expect(AppSpacingTokens.x4l, greaterThan(0));
      expect(AppSpacingTokens.x5l, greaterThan(0));
      expect(AppSpacingTokens.x6l, greaterThan(0));
      expect(AppSpacingTokens.section, greaterThan(0));
    });

    test('values are strictly increasing', () {
      expect(AppSpacingTokens.xxs, lessThan(AppSpacingTokens.xs));
      expect(AppSpacingTokens.xs, lessThan(AppSpacingTokens.sm));
      expect(AppSpacingTokens.sm, lessThan(AppSpacingTokens.md));
      expect(AppSpacingTokens.md, lessThan(AppSpacingTokens.lg));
      expect(AppSpacingTokens.lg, lessThan(AppSpacingTokens.xl));
      expect(AppSpacingTokens.xl, lessThan(AppSpacingTokens.x2l));
      expect(AppSpacingTokens.x2l, lessThan(AppSpacingTokens.x3l));
      expect(AppSpacingTokens.x3l, lessThan(AppSpacingTokens.x4l));
      expect(AppSpacingTokens.x4l, lessThan(AppSpacingTokens.x5l));
      expect(AppSpacingTokens.x5l, lessThan(AppSpacingTokens.x6l));
      expect(AppSpacingTokens.x6l, lessThan(AppSpacingTokens.section));
    });
  });
}
