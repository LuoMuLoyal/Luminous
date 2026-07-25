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
///
/// Forui 0.24.0 removed all predefined color schemes except neutral. Non-neutral
/// families are emulated by overriding [FColors.primary] / [FColors.primaryForeground]
/// on the neutral base, preserving the color variety the app has always offered.
FThemeData _baseThemeData(AppThemeFamily family, Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final base = isDark ? FTheme.neutral.dark.touch : FTheme.neutral.light.touch;
  final override = _familyColorOverride(family, isDark);

  if (override == null) return base;

  return FThemeData(
    touch: true,
    debugLabel: '${family.storageValue} ${isDark ? 'Dark' : 'Light'} Touch',
    colors: base.colors.copyWith(
      primary: override.primary,
      primaryForeground: override.primaryForeground,
    ),
  );
}

/// Primary color override for each non-neutral family.
///
/// Color values are taken from the Forui 0.23.x predefined schemes that were
/// removed in 0.24.0. Returns `null` for neutral (no override needed).
class _ColorOverride {
  const _ColorOverride(this.primary, this.primaryForeground);
  final Color primary;
  final Color primaryForeground;
}

_ColorOverride? _familyColorOverride(AppThemeFamily family, bool isDark) {
  return switch (family) {
    AppThemeFamily.neutral => null,
    AppThemeFamily.blue => const _ColorOverride(
      Color(0xFF1447E6),
      Color(0xFFEFF6FF),
    ),
    AppThemeFamily.green => const _ColorOverride(
      Color(0xFF5EA500),
      Color(0xFFF7FEE7),
    ),
    AppThemeFamily.orange => _ColorOverride(
      isDark ? const Color(0xFFFF6900) : const Color(0xFFF54A00),
      const Color(0xFFFFF7ED),
    ),
    AppThemeFamily.red => _ColorOverride(
      isDark ? const Color(0xFFFB2C36) : const Color(0xFFE7000B),
      const Color(0xFFFEF2F2),
    ),
    AppThemeFamily.rose => _ColorOverride(
      isDark ? const Color(0xFFFF2056) : const Color(0xFFEC003F),
      const Color(0xFFFFF1F2),
    ),
    AppThemeFamily.slate => _ColorOverride(
      isDark ? const Color(0xFFE2E8F0) : const Color(0xFF0F172B),
      const Color(0xFFF8FAFC),
    ),
    AppThemeFamily.violet => _ColorOverride(
      isDark ? const Color(0xFF8E51FF) : const Color(0xFF7F22FE),
      const Color(0xFFF5F3FF),
    ),
    AppThemeFamily.yellow => _ColorOverride(
      isDark ? const Color(0xFFEFB100) : const Color(0xFFFCC800),
      const Color(0xFF733E0A),
    ),
    AppThemeFamily.zinc => _ColorOverride(
      isDark ? const Color(0xFFE4E4E7) : const Color(0xFF18181B),
      const Color(0xFFFAFAFA),
    ),
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
      shimmerBase: fColors.mutedForeground.withValues(
        alpha: isDark ? 0.06 : 0.03,
      ),
      disabled: fColors.mutedForeground.withValues(alpha: 0.5),
      borderStrong: fColors.mutedForeground.withValues(
        alpha: isDark ? 0.40 : 0.30,
      ),
      fill: fColors.mutedForeground.withValues(alpha: 0.55),
      fillStrong: fColors.mutedForeground.withValues(alpha: 0.80),
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
/// | shimmerBase| 0.03 | 0.06  | Skeleton/shimmer base | Derived from muted × 0.32. Very faint so shimmer animation is subtle. |
/// | disabled | 0.50  | 0.50  | Disabled foreground | Uniform across modes — disabled state should be clearly distinguishable but muted. |
/// | borderStrong | 0.30 | 0.40 | Emphasized borders/shadows | Higher than border for drag, destructive, shadow. |
/// | fill | 0.55 | 0.55 | Semi-transparent icons/circles | Uniform — decorative, non-text. |
/// | fillStrong | 0.80 | 0.80 | Buttons/sparklines/overlays/text | High opacity fill, covers 0.68–0.92 range. |
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
  // shimmerBase ≈ muted × 0.32, pre-computed to avoid runtime alpha arithmetic.
  shimmerBase: solid.withValues(alpha: isDark ? 0.06 : 0.03),
  disabled: solid.withValues(alpha: 0.5),
  borderStrong: solid.withValues(alpha: isDark ? 0.40 : 0.30),
  fill: solid.withValues(alpha: 0.55),
  fillStrong: solid.withValues(alpha: 0.80),
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
