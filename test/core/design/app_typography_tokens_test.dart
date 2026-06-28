import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/app_typography_tokens.dart';

void main() {
  group('AppTypographyTokens static constants', () {
    test('sansFamily is Geist', () {
      expect(AppTypographyTokens.sansFamily, equals('Geist'));
    });

    test('monoFamily is Geist Mono', () {
      expect(AppTypographyTokens.monoFamily, equals('Geist Mono'));
    });

    test('sansFallback is Inter', () {
      expect(AppTypographyTokens.sansFallback, equals('Inter'));
    });
  });

  group('AppTypographyTokens mobile scale', () {
    late AppTypographyScale scale;

    setUp(() {
      scale = AppTypographyTokens.mobile(const Color(0xFF171717));
    });

    test('returns an AppTypographyScale', () {
      expect(scale, isA<AppTypographyScale>());
    });

    test('displayXl uses correct fontSize', () {
      expect(scale.displayXl.fontSize, equals(34));
    });

    test('bodyLg uses weight 400', () {
      expect(scale.bodyLg.fontWeight, equals(FontWeight.w400));
    });

    test('bodyMdStrong uses weight 500', () {
      expect(scale.bodyMdStrong.fontWeight, equals(FontWeight.w500));
    });

    test('display styles use weight 600', () {
      expect(scale.displayXl.fontWeight, equals(FontWeight.w600));
      expect(scale.displayLg.fontWeight, equals(FontWeight.w600));
      expect(scale.displayMd.fontWeight, equals(FontWeight.w600));
      expect(scale.displaySm.fontWeight, equals(FontWeight.w600));
    });

    test('all text styles use Geist font family', () {
      final styles = [
        scale.displayXl,
        scale.displayLg,
        scale.displayMd,
        scale.displaySm,
        scale.bodyLg,
        scale.bodyMd,
        scale.bodyMdStrong,
        scale.bodySm,
        scale.bodySmStrong,
        scale.caption,
        scale.buttonMd,
        scale.buttonLg,
      ];
      for (final style in styles) {
        expect(style.fontFamily, equals('Geist'));
      }
    });

    test('captionMono and code use Geist Mono', () {
      expect(scale.captionMono.fontFamily, equals('Geist Mono'));
      expect(scale.code.fontFamily, equals('Geist Mono'));
    });

    test('all text styles use the provided color', () {
      final testColor = const Color(0xFFEE0000);
      final coloredScale = AppTypographyTokens.mobile(testColor);
      final styles = [
        coloredScale.displayXl,
        coloredScale.displayLg,
        coloredScale.displayMd,
        coloredScale.displaySm,
        coloredScale.bodyLg,
        coloredScale.bodyMd,
        coloredScale.bodyMdStrong,
        coloredScale.bodySm,
        coloredScale.bodySmStrong,
        coloredScale.caption,
        coloredScale.captionMono,
        coloredScale.code,
        coloredScale.buttonMd,
        coloredScale.buttonLg,
      ];
      for (final style in styles) {
        expect(style.color, equals(testColor));
      }
    });
  });

  group('AppTypographyTokens desktop scale', () {
    late AppTypographyScale scale;

    setUp(() {
      scale = AppTypographyTokens.desktop(const Color(0xFF171717));
    });

    test('displayXl uses larger fontSize than mobile', () {
      final mobile = AppTypographyTokens.mobile(const Color(0xFF171717));
      expect(
        scale.displayXl.fontSize ?? 0,
        greaterThan(mobile.displayXl.fontSize ?? 0),
      );
    });

    test('body sizes are larger than mobile equivalents', () {
      final mobile = AppTypographyTokens.mobile(const Color(0xFF171717));
      expect(
        scale.bodyLg.fontSize ?? 0,
        greaterThan(mobile.bodyLg.fontSize ?? 0),
      );
      expect(
        scale.bodyMd.fontSize ?? 0,
        greaterThan(mobile.bodyMd.fontSize ?? 0),
      );
      expect(
        scale.bodySm.fontSize ?? 0,
        greaterThan(mobile.bodySm.fontSize ?? 0),
      );
    });
  });
}
