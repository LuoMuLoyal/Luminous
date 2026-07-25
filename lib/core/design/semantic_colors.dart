import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'semantic_color.dart';
import 'semantic_color_palette.dart';

/// Full semantic color scheme injected into [FColors] via `extensions`.
///
/// Created once per (family, brightness) in `appThemeData`. All tonal values
/// are pre-computed — widget code retrieves a [SemanticColorPalette] and picks
/// a tone, never calculating alpha at runtime.
///
/// Access via:
/// ```dart
/// context.theme.colors.semantic  // SemanticColors
/// ```
@immutable
class SemanticColors extends ThemeExtension<SemanticColors> {
  const SemanticColors({
    required this.primary,
    required this.success,
    required this.warning,
    required this.info,
    required this.destructive,
    required this.neutral,
  });

  /// Brand color — varies with the selected theme family.
  final SemanticColorPalette primary;

  /// Success / positive state — fixed across all theme families.
  final SemanticColorPalette success;

  /// Warning / attention state — fixed across all theme families.
  final SemanticColorPalette warning;

  /// Informational / hint — fixed across all theme families.
  final SemanticColorPalette info;

  /// Destructive / error — derives from the theme family's destructive color.
  final SemanticColorPalette destructive;

  /// Neutral / no particular semantic meaning — derives from the theme's
  /// `mutedForeground`, `secondary`, and `border` colors.
  final SemanticColorPalette neutral;

  /// Returns the palette for [color].
  SemanticColorPalette of(SemanticColor color) => switch (color) {
    SemanticColor.primary => primary,
    SemanticColor.success => success,
    SemanticColor.warning => warning,
    SemanticColor.info => info,
    SemanticColor.destructive => destructive,
    SemanticColor.neutral => neutral,
  };

  @override
  SemanticColors copyWith({
    SemanticColorPalette? primary,
    SemanticColorPalette? success,
    SemanticColorPalette? warning,
    SemanticColorPalette? info,
    SemanticColorPalette? destructive,
    SemanticColorPalette? neutral,
  }) => SemanticColors(
    primary: primary ?? this.primary,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    info: info ?? this.info,
    destructive: destructive ?? this.destructive,
    neutral: neutral ?? this.neutral,
  );

  @override
  SemanticColors lerp(SemanticColors? other, double t) {
    if (other is! SemanticColors) return this;
    return SemanticColors(
      primary: _lerpPalette(primary, other.primary, t),
      success: _lerpPalette(success, other.success, t),
      warning: _lerpPalette(warning, other.warning, t),
      info: _lerpPalette(info, other.info, t),
      destructive: _lerpPalette(destructive, other.destructive, t),
      neutral: _lerpPalette(neutral, other.neutral, t),
    );
  }

  static SemanticColorPalette _lerpPalette(
    SemanticColorPalette a,
    SemanticColorPalette b,
    double t,
  ) => SemanticColorPalette(
    solid: Color.lerp(a.solid, b.solid, t)!,
    foreground: Color.lerp(a.foreground, b.foreground, t)!,
    muted: Color.lerp(a.muted, b.muted, t)!,
    subtle: Color.lerp(a.subtle, b.subtle, t)!,
    border: Color.lerp(a.border, b.border, t)!,
    shimmerBase: Color.lerp(a.shimmerBase, b.shimmerBase, t)!,
    disabled: Color.lerp(a.disabled, b.disabled, t)!,
    borderStrong: Color.lerp(a.borderStrong, b.borderStrong, t)!,
    fill: Color.lerp(a.fill, b.fill, t)!,
    fillStrong: Color.lerp(a.fillStrong, b.fillStrong, t)!,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemanticColors &&
          primary == other.primary &&
          success == other.success &&
          warning == other.warning &&
          info == other.info &&
          destructive == other.destructive &&
          neutral == other.neutral;

  @override
  int get hashCode =>
      Object.hash(primary, success, warning, info, destructive, neutral);
}

/// Convenient access to [SemanticColors] on [FColors].
extension SemanticColorsAccess on FColors {
  SemanticColors get semantic => extension<SemanticColors>();
}
