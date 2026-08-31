import 'package:flutter/material.dart';

/// High-contrast accessibility color overrides.
///
/// When the user enables high-contrast mode in accessibility settings,
/// these values replace the corresponding [FColors] properties to maximize
/// foreground/background separation and strengthen borders.
///
/// The values are intentionally not derived from the active theme family —
/// high-contrast mode is an accessibility override that uses extreme,
/// consistent values across all families.
abstract final class HighContrastColors {
  // -- Light mode --

  /// Maximum-contrast foreground for light mode (pure black).
  static const lightForeground = Color(0xFF000000);

  /// Near-black muted foreground for light mode.
  static const lightMutedForeground = Color(0xFF1A1A1A);

  /// Darkened border for light mode.
  static const lightBorder = Color(0xFF333333);

  // -- Dark mode --

  /// Maximum-contrast foreground for dark mode (pure white).
  static const darkForeground = Color(0xFFFFFFFF);

  /// Near-white muted foreground for dark mode.
  static const darkMutedForeground = Color(0xFFE0E0E0);

  /// Lightened border for dark mode.
  static const darkBorder = Color(0xFFCCCCCC);
}
