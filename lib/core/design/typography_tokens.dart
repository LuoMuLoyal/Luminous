import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Project typography vocabulary mapped to Forui’s `FTypeface` scale.
///
/// Forui exposes ten body/display sizes: `xs3` (10), `xs2` (12), `xs` (14),
/// `sm` (16), `md` (18), `lg` (20), `xl` (22), `xl2` (30), `xl3` (36), and
/// `xl4` (48) for the default touch theme.
///
/// `level1` through `level10` map directly to those ten values in order,
/// replacing both Material `TextTheme` references and hardcoded font sizes
/// with a single project-level scale. Use [resolve] when an [FTypography]
/// instance is already available; use [body]/[display] helpers when only a
/// [BuildContext] is in scope.
enum AppTypographyToken {
  level1,
  level2,
  level3,
  level4,
  level5,
  level6,
  level7,
  level8,
  level9,
  level10,
}

extension AppTypographyTokenExtension on AppTypographyToken {
  TextStyle _style(FTypeface typeface) => switch (this) {
    AppTypographyToken.level1 => typeface.xs3,
    AppTypographyToken.level2 => typeface.xs2,
    AppTypographyToken.level3 => typeface.xs,
    AppTypographyToken.level4 => typeface.sm,
    AppTypographyToken.level5 => typeface.md,
    AppTypographyToken.level6 => typeface.lg,
    AppTypographyToken.level7 => typeface.xl,
    AppTypographyToken.level8 => typeface.xl2,
    AppTypographyToken.level9 => typeface.xl3,
    AppTypographyToken.level10 => typeface.xl4,
  };

  /// Resolves this token against a concrete [FTypography].
  ///
  /// Set [display] to `true` to use [FTypography.display] instead of
  /// [FTypography.body].
  TextStyle resolve(FTypography typography, {bool display = false}) =>
      _style(display ? typography.display : typography.body);

  /// Resolves this token against the body typeface of the current Forui theme.
  TextStyle body(BuildContext context) =>
      resolve(context.theme.typography, display: false);

  /// Resolves this token against the display typeface of the current Forui
  /// theme.
  TextStyle display(BuildContext context) =>
      resolve(context.theme.typography, display: true);
}
