import 'package:luminous/core/design/app_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/app_color_tokens.dart';

void main() {
  group('AppColorTokens primary palette', () {
    test('primary color', () {
      expect(AppColorTokens.primary, equals(const Color(0xFF171717)));
    });

    test('onPrimary color', () {
      expect(AppColorTokens.onPrimary, equals(const Color(0xFFFFFFFF)));
    });

    test('ink color', () {
      expect(AppColorTokens.ink, equals(const Color(0xFF171717)));
    });

    test('body color', () {
      expect(AppColorTokens.body, equals(const Color(0xFF4D4D4D)));
    });

    test('mute color', () {
      expect(AppColorTokens.mute, equals(const Color(0xFF888888)));
    });
  });

  group('AppColorTokens surface colors', () {
    test('canvas is white', () {
      expect(AppColorTokens.canvas, equals(const Color(0xFFFFFFFF)));
    });

    test('canvasSoft', () {
      expect(AppColorTokens.canvasSoft, equals(const Color(0xFFFAFAFA)));
    });

    test('canvasSoft2', () {
      expect(AppColorTokens.canvasSoft2, equals(const Color(0xFFF5F5F5)));
    });

    test('hairline', () {
      expect(AppColorTokens.hairline, equals(const Color(0xFFEBEBEB)));
    });

    test('hairlineStrong', () {
      expect(AppColorTokens.hairlineStrong, equals(const Color(0xFFA1A1A1)));
    });
  });

  group('AppColorTokens semantic colors', () {
    test('link', () {
      expect(AppColorTokens.link, equals(const Color(0xFF0070F3)));
    });

    test('success', () {
      expect(AppColorTokens.success, equals(const Color(0xFF0070F3)));
    });

    test('error', () {
      expect(AppColorTokens.error, equals(const Color(0xFFEE0000)));
    });

    test('warning', () {
      expect(AppColorTokens.warning, equals(const Color(0xFFF5A623)));
    });

    test('health', () {
      expect(AppColorTokens.health, equals(const Color(0xFF158765)));
    });
  });

  group('AppColorTokens seed', () {
    test('seed matches primary', () {
      expect(AppColorTokens.seed, equals(AppColorTokens.primary));
    });
  });
}
