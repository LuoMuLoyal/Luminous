import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Surface-level color tokens for the app's "near-white grey" visual direction.
///
/// The app uses a two-tier surface system:
/// - **Scaffold background** (`scaffoldBackground`): a near-white grey (#FAFAFA)
///   so white cards naturally stand out without relying on borders alone.
/// - **Container border** (`containerBorder`): an ultra-faint border (#F5F5F5)
///   that is barely visible on the scaffold but provides a consistent visual
///   "frame" for both `FCard` and `FTileGroup`.
///
/// Dark mode derives both tokens from Forui's color system (lerped / alpha-based)
/// so they adapt automatically to any theme family.
///
/// See: `appThemeData()` and `foruiMaterialTheme()` in `lib/core/theme/family.dart`.
abstract final class SurfaceTokens {
  /// The scaffold (page-level) background color.
  ///
  /// Light: #FAFAFA (Tailwind neutral-50) — the industry-standard near-white
  /// surface used by Linear, Apple Notes, and GitHub's content areas.
  /// Dark: a 50/50 lerp between `background` and `secondary` for a soft
  /// elevation from pure black.
  static Color scaffoldBackground(FColors colors) {
    if (colors.brightness == Brightness.dark) {
      return Color.lerp(colors.background, colors.secondary, 0.5)!;
    }
    return const Color(0xFFFAFAFA);
  }

  /// The ultra-faint container border for `FCard` and `FTileGroup`.
  ///
  /// Light: #F5F5F5 — only 0.8% lightness delta on #FAFAFA scaffold, nearly
  /// invisible but still providing a consistent visual "frame".
  /// Dark: `colors.border` at 50% alpha so it adapts to any theme family.
  static Color containerBorder(FColors colors) {
    if (colors.brightness == Brightness.dark) {
      return colors.border.withValues(alpha: 0.5);
    }
    return const Color(0xFFF5F5F5);
  }
}
