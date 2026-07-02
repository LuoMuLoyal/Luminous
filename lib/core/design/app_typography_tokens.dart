import 'package:flutter/material.dart';

@immutable
class AppTypographyScale {
  const AppTypographyScale({
    required this.displayXl,
    required this.displayLg,
    required this.displayMd,
    required this.displaySm,
    required this.bodyLg,
    required this.bodyMd,
    required this.bodyMdStrong,
    required this.bodySm,
    required this.bodySmStrong,
    required this.caption,
    required this.captionMono,
    required this.code,
    required this.buttonMd,
    required this.buttonLg,
  });

  final TextStyle displayXl;
  final TextStyle displayLg;
  final TextStyle displayMd;
  final TextStyle displaySm;
  final TextStyle bodyLg;
  final TextStyle bodyMd;
  final TextStyle bodyMdStrong;
  final TextStyle bodySm;
  final TextStyle bodySmStrong;
  final TextStyle caption;
  final TextStyle captionMono;
  final TextStyle code;
  final TextStyle buttonMd;
  final TextStyle buttonLg;
}

/// Legacy compatibility shim.
///
/// Runtime feature code now reads Material `textTheme` directly. This file
/// remains only so older tests and temporary compatibility code can keep
/// resolving the historical named scale during the final cleanup phase.
abstract final class AppTypographyTokens {
  static const String sansFamily = 'Geist';
  static const String monoFamily = 'Geist Mono';
  static const String sansFallback = 'Inter';

  static AppTypographyScale mobile(Color color) {
    return AppTypographyScale(
      displayXl: _sans(
        color: color,
        fontSize: 30,
        height: 36 / 30,
        weight: FontWeight.w600,
        letterSpacing: -0.8,
      ),
      displayLg: _sans(
        color: color,
        fontSize: 26,
        height: 32 / 26,
        weight: FontWeight.w600,
        letterSpacing: -0.6,
      ),
      displayMd: _sans(
        color: color,
        fontSize: 22,
        height: 28 / 22,
        weight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      displaySm: _sans(
        color: color,
        fontSize: 18,
        height: 24 / 18,
        weight: FontWeight.w600,
      ),
      bodyLg: _sans(
        color: color,
        fontSize: 16,
        height: 24 / 16,
        weight: FontWeight.w400,
      ),
      bodyMd: _sans(
        color: color,
        fontSize: 14,
        height: 20 / 14,
        weight: FontWeight.w400,
      ),
      bodyMdStrong: _sans(
        color: color,
        fontSize: 14,
        height: 20 / 14,
        weight: FontWeight.w500,
      ),
      bodySm: _sans(
        color: color,
        fontSize: 12,
        height: 18 / 12,
        weight: FontWeight.w400,
      ),
      bodySmStrong: _sans(
        color: color,
        fontSize: 12,
        height: 18 / 12,
        weight: FontWeight.w500,
      ),
      caption: _sans(
        color: color,
        fontSize: 11,
        height: 14 / 11,
        weight: FontWeight.w400,
      ),
      captionMono: _mono(color: color, fontSize: 11, height: 14 / 11),
      code: _mono(color: color, fontSize: 12, height: 18 / 12),
      buttonMd: _sans(
        color: color,
        fontSize: 12,
        height: 18 / 12,
        weight: FontWeight.w500,
      ),
      buttonLg: _sans(
        color: color,
        fontSize: 14,
        height: 20 / 14,
        weight: FontWeight.w500,
      ),
    );
  }

  static AppTypographyScale desktop(Color color) {
    return AppTypographyScale(
      displayXl: _sans(
        color: color,
        fontSize: 42,
        height: 44 / 42,
        weight: FontWeight.w600,
        letterSpacing: -1.4,
      ),
      displayLg: _sans(
        color: color,
        fontSize: 30,
        height: 36 / 30,
        weight: FontWeight.w600,
        letterSpacing: -0.8,
      ),
      displayMd: _sans(
        color: color,
        fontSize: 24,
        height: 32 / 24,
        weight: FontWeight.w600,
        letterSpacing: -0.4,
      ),
      displaySm: _sans(
        color: color,
        fontSize: 18,
        height: 24 / 18,
        weight: FontWeight.w600,
      ),
      bodyLg: _sans(
        color: color,
        fontSize: 16,
        height: 24 / 16,
        weight: FontWeight.w400,
      ),
      bodyMd: _sans(
        color: color,
        fontSize: 14,
        height: 20 / 14,
        weight: FontWeight.w400,
      ),
      bodyMdStrong: _sans(
        color: color,
        fontSize: 14,
        height: 20 / 14,
        weight: FontWeight.w500,
      ),
      bodySm: _sans(
        color: color,
        fontSize: 12,
        height: 18 / 12,
        weight: FontWeight.w400,
      ),
      bodySmStrong: _sans(
        color: color,
        fontSize: 12,
        height: 18 / 12,
        weight: FontWeight.w500,
      ),
      caption: _sans(
        color: color,
        fontSize: 12,
        height: 16 / 12,
        weight: FontWeight.w400,
      ),
      captionMono: _mono(color: color, fontSize: 12, height: 16 / 12),
      code: _mono(color: color, fontSize: 13, height: 20 / 13),
      buttonMd: _sans(
        color: color,
        fontSize: 12,
        height: 18 / 12,
        weight: FontWeight.w500,
      ),
      buttonLg: _sans(
        color: color,
        fontSize: 14,
        height: 20 / 14,
        weight: FontWeight.w500,
      ),
    );
  }

  static TextStyle _sans({
    required Color color,
    required double fontSize,
    required double height,
    required FontWeight weight,
    double? letterSpacing,
  }) {
    return TextStyle(
      color: color,
      fontFamily: sansFamily,
      fontFamilyFallback: const <String>[
        sansFallback,
        'system-ui',
        'sans-serif',
      ],
      fontSize: fontSize,
      height: height,
      fontWeight: weight,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle _mono({
    required Color color,
    required double fontSize,
    required double height,
  }) {
    return TextStyle(
      color: color,
      fontFamily: monoFamily,
      fontFamilyFallback: const <String>[
        'ui-monospace',
        'SFMono-Regular',
        'Menlo',
        'Monaco',
        'monospace',
      ],
      fontSize: fontSize,
      height: height,
      fontWeight: FontWeight.w400,
    );
  }
}
