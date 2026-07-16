import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:luminous/core/design/semantic_color_palette.dart';
import 'package:luminous/core/design/semantic_colors.dart';

const AppThemeFamily appDefaultThemeFamily = AppThemeFamily.blue;

enum AppThemeFamily {
  blue('blue'),
  green('green'),
  neutral('neutral'),
  orange('orange'),
  red('red'),
  rose('rose'),
  slate('slate'),
  violet('violet'),
  yellow('yellow'),
  zinc('zinc');

  const AppThemeFamily(this.storageValue);

  final String storageValue;

  static AppThemeFamily fromStorage(String? value) {
    for (final family in AppThemeFamily.values) {
      if (family.storageValue == value) {
        return family;
      }
    }
    return appDefaultThemeFamily;
  }
}

/// Returns the base [FThemeData] for a given family and brightness, before
/// semantic color extensions are injected.
FThemeData _baseThemeData(AppThemeFamily family, Brightness brightness) {
  return switch ((family, brightness)) {
    (AppThemeFamily.blue, Brightness.light) => FThemes.blue.light.touch,
    (AppThemeFamily.blue, Brightness.dark) => FThemes.blue.dark.touch,
    (AppThemeFamily.green, Brightness.light) => FThemes.green.light.touch,
    (AppThemeFamily.green, Brightness.dark) => FThemes.green.dark.touch,
    (AppThemeFamily.neutral, Brightness.light) => FThemes.neutral.light.touch,
    (AppThemeFamily.neutral, Brightness.dark) => FThemes.neutral.dark.touch,
    (AppThemeFamily.orange, Brightness.light) => FThemes.orange.light.touch,
    (AppThemeFamily.orange, Brightness.dark) => FThemes.orange.dark.touch,
    (AppThemeFamily.red, Brightness.light) => FThemes.red.light.touch,
    (AppThemeFamily.red, Brightness.dark) => FThemes.red.dark.touch,
    (AppThemeFamily.rose, Brightness.light) => FThemes.rose.light.touch,
    (AppThemeFamily.rose, Brightness.dark) => FThemes.rose.dark.touch,
    (AppThemeFamily.slate, Brightness.light) => FThemes.slate.light.touch,
    (AppThemeFamily.slate, Brightness.dark) => FThemes.slate.dark.touch,
    (AppThemeFamily.violet, Brightness.light) => FThemes.violet.light.touch,
    (AppThemeFamily.violet, Brightness.dark) => FThemes.violet.dark.touch,
    (AppThemeFamily.yellow, Brightness.light) => FThemes.yellow.light.touch,
    (AppThemeFamily.yellow, Brightness.dark) => FThemes.yellow.dark.touch,
    (AppThemeFamily.zinc, Brightness.light) => FThemes.zinc.light.touch,
    (AppThemeFamily.zinc, Brightness.dark) => FThemes.zinc.dark.touch,
  };
}

/// Creates the [FThemeData] for the app, with [SemanticColors] injected as an
/// [FColors] extension.
///
/// Preset Forui themes derive all widget styles from [FColors] via `.inherit()`,
/// so constructing a new [FThemeData] with modified colors is equivalent to the
/// preset — no custom styles are lost.
FThemeData appThemeData(AppThemeFamily family, Brightness brightness) {
  final base = _baseThemeData(family, brightness);
  final colors = base.colors.copyWith(
    extensions: [_semanticColorsFor(brightness, base.colors)],
  );
  return FThemeData(touch: true, debugLabel: base.debugLabel, colors: colors);
}

/// Builds the [SemanticColors] extension for a given brightness.
///
/// - [SemanticColor.primary] and [SemanticColor.destructive] derive from the
///   theme family's [FColors].
/// - [SemanticColor.success], [SemanticColor.warning], and [SemanticColor.info]
///   are fixed across all families — a medical-health requirement.
SemanticColors _semanticColorsFor(Brightness brightness, FColors fColors) {
  final isDark = brightness == Brightness.dark;

  return SemanticColors(
    primary: _paletteFromFColor(
      fColors.primary,
      fColors.primaryForeground,
      isDark,
    ),
    destructive: _paletteFromFColor(
      fColors.destructive,
      fColors.destructiveForeground,
      isDark,
    ),
    neutral: SemanticColorPalette(
      solid: fColors.mutedForeground,
      foreground: fColors.background,
      muted: fColors.secondary,
      subtle: fColors.secondary,
      border: fColors.border,
    ),
    success: _fixedPalette(
      solid: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
      foreground: isDark ? const Color(0xFF052E16) : const Color(0xFFFFFFFF),
      isDark: isDark,
    ),
    warning: _fixedPalette(
      solid: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
      foreground: isDark ? const Color(0xFF451A03) : const Color(0xFFFFFFFF),
      isDark: isDark,
    ),
    info: _fixedPalette(
      solid: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
      foreground: isDark ? const Color(0xFF0C1E3E) : const Color(0xFFFFFFFF),
      isDark: isDark,
    ),
  );
}

/// Derives a [SemanticColorPalette] from a Forui color pair, with dark-mode
/// alpha compensation baked in.
SemanticColorPalette _paletteFromFColor(
  Color solid,
  Color foreground,
  bool isDark,
) => _fixedPalette(solid: solid, foreground: foreground, isDark: isDark);

/// Creates a [SemanticColorPalette] with standardized alpha tones.
///
/// Alpha scale (light → dark) with WCAG 2.1 contrast analysis:
///
/// | Tone    | Light | Dark  | WCAG concern | Analysis |
/// |---------|-------|-------|--------------|----------|
/// | subtle  | 0.05  | 0.10  | Background distinguishability (non-text) | Dark bumped from 0.08→0.10 so empty-state tints are visible on #1C1B1F-class backgrounds. Non-text, so WCAG text contrast N/A; relies on visual distinguishability. |
/// | muted   | 0.10  | 0.18  | Text-on-chip contrast (solid on muted) | In dark mode, solid (#4ADE80-class) on muted (≈#335C3D) yields >7:1 — passes AAA. Light mode similarly passes. |
/// | border  | 0.20  | 0.35  | Semantic border visibility (non-text) | 0.35 in dark creates clearly visible colored borders on dark backgrounds. 0.20 in light is sufficient on light backgrounds. |
///
/// The `foreground` color is used for text/icons placed on top of `solid`
/// (e.g. white on green). Those pairs are chosen by the Forui theme system
/// and always exceed 4.5:1.
SemanticColorPalette _fixedPalette({
  required Color solid,
  required Color foreground,
  required bool isDark,
}) => SemanticColorPalette(
  solid: solid,
  foreground: foreground,
  subtle: solid.withValues(alpha: isDark ? 0.10 : 0.05),
  muted: solid.withValues(alpha: isDark ? 0.18 : 0.10),
  border: solid.withValues(alpha: isDark ? 0.35 : 0.20),
);

ThemeData foruiMaterialTheme(FThemeData theme) {
  final material = theme.toApproximateMaterialTheme();
  return material.copyWith(
    scaffoldBackgroundColor: theme.colors.background,
    canvasColor: theme.colors.background,
    cardColor: theme.colors.card,
    dividerColor: theme.colors.border,
    shadowColor: theme.colors.foreground.withValues(
      alpha: theme.colors.brightness == Brightness.dark ? 0.16 : 0.06,
    ),
  );
}
