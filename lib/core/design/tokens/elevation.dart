import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Elevation / shadow token system.
///
/// Provides pre-computed [BoxShadow] lists for the few places in the app
/// that need shadow elevation. Dark-mode alpha compensation is baked in,
/// consistent with [SemanticColorPalette]'s strategy — shadows derive from
/// the theme's `foreground` color, never from raw `Colors.black`.
///
/// | Token    | Use case                          | blur | dy |
/// |----------|-----------------------------------|------|----|
/// | [raised] | Card hover, drag-target highlight | 12   | 4  |
/// | [glow]   | Floating action, colored halo     | 8    | 2  |
abstract final class ElevationTokens {
  /// Subtle raised shadow — card hover, drag-target highlight.
  ///
  /// Uses the theme's `foreground` color with low alpha so the shadow
  /// adapts to light/dark automatically.
  static List<BoxShadow> raised(FColors colors) => [
    BoxShadow(
      color: colors.foreground.withValues(
        alpha: colors.brightness == Brightness.dark ? 0.20 : 0.12,
      ),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  /// Colored glow shadow — floating action button, mic button.
  ///
  /// Takes an explicit [color] (typically a semantic border-strong tone)
  /// so the glow matches the element's semantic meaning.
  static List<BoxShadow> glow(Color color) => [
    BoxShadow(color: color, blurRadius: 8, offset: const Offset(0, 2)),
  ];

  /// Default shadow color for `MaterialTheme.shadowColor`.
  ///
  /// Very faint — used by Material's internal shadow painting but rarely
  /// visible in the Forui-first visual direction.
  static Color shadowColor(FColors colors) => colors.foreground.withValues(
    alpha: colors.brightness == Brightness.dark ? 0.16 : 0.06,
  );
}
