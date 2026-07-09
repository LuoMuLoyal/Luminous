import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Typography token scale mapped to Forui's `FTypeface` scale.
///
/// Forui exposes ten body/display sizes: `xs3` (10), `xs2` (12), `xs` (14),
/// `sm` (16), `md` (18), `lg` (20), `xl` (22), `xl2` (30), `xl3` (36), and
/// `xl4` (48) for the default touch theme.
///
/// [level1] through [level10] map directly to those ten values in order.
/// Use [resolve] when an [FTypography] instance is already available;
/// use [body]/[display] helpers when only a [BuildContext] is in scope.
enum TypographyToken {
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

extension TypographyTokenExtension on TypographyToken {
  TextStyle _style(FTypeface typeface) => switch (this) {
    TypographyToken.level1 => typeface.xs3,
    TypographyToken.level2 => typeface.xs2,
    TypographyToken.level3 => typeface.xs,
    TypographyToken.level4 => typeface.sm,
    TypographyToken.level5 => typeface.md,
    TypographyToken.level6 => typeface.lg,
    TypographyToken.level7 => typeface.xl,
    TypographyToken.level8 => typeface.xl2,
    TypographyToken.level9 => typeface.xl3,
    TypographyToken.level10 => typeface.xl4,
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
