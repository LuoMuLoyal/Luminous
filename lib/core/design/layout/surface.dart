import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Surface-level color tokens for the app's "near-white grey" visual direction.
///
/// The app uses a three-tier surface system on desktop, two on phone:
/// - **Sidebar** (`sidebarBackground`): one step deeper than the page (#F4F4F5),
///   so navigation reads as a distinct column without a border.
/// - **Scaffold background** (`scaffoldBackground`): a near-white grey (#FAFAFA)
///   so white cards naturally stand out without relying on borders alone.
/// - **Card**: `colors.card` (white) from the Forui theme.
///
/// The three tiers must stay ordered `sidebar < scaffold < card` in light mode —
/// that ordering *is* the hierarchy; borders are decoration on top of it.
/// Without the sidebar tier the nav and the page were the same color and every
/// level of the layout collapsed into 1px outlines.
///
/// Container border (`containerBorder`): an ultra-faint border (#F5F5F5)
/// that is barely visible on the scaffold but provides a consistent visual
/// "frame" for both `FCard` and `FTileGroup`.
///
/// Dark mode derives all tokens from Forui's color system (lerped / alpha-based)
/// so they adapt automatically to any theme family.
///
/// See: `appThemeData()` and `foruiMaterialTheme()` in `lib/core/theme/family.dart`.
abstract final class SurfaceTokens {
  /// The scaffold (page-level) background color.
  ///
  /// Light: #FAFAFA — the near-white surface used by Linear, Apple Notes and
  /// GitHub content areas. Darker than `card`, so white cards lift off it.
  ///
  /// Dark: **deeper** than `colors.card`. Forui's dark `card` (#171717) is
  /// already darker than a 50/50 `background`/`secondary` lerp (#181818), so the
  /// old formula put the page *above* the cards and they sank into it instead of
  /// floating. Deriving the scaffold as a lerp toward `background` from `card`
  /// keeps the order `background < scaffold < card` in dark mode too.
  static Color scaffoldBackground(FColors colors) {
    if (colors.brightness == Brightness.dark) {
      return Color.lerp(colors.card, colors.background, 0.45)!;
    }
    return const Color(0xFFFAFAFA);
  }

  /// The navigation sidebar background.
  ///
  /// The sidebar sits **behind** the content canvas, so it is always the
  /// deepest tier of the three. Two consequences:
  ///
  /// - It must be derived from the scaffold rather than from `background`
  ///   directly. `background` in light mode is pure white (brighter than the
  ///   #FAFAFA scaffold), so using it as the sidebar made the sidebar *lighter*
  ///   than the page.
  /// - "Deeper" flips meaning between themes: darken on light, and go
  ///   *toward* `background` on dark (`background` being near-black, lerping
  ///   toward `secondary` would make the sidebar lighter than the page — the
  ///   exact regression this token exists to prevent).
  ///
  /// Light: one deliberate step below #FAFAFA.
  /// Dark: 60% of the way from the scaffold back toward `background`.
  static Color sidebarBackground(FColors colors) {
    final scaffold = scaffoldBackground(colors);
    if (colors.brightness == Brightness.dark) {
      return Color.lerp(scaffold, colors.background, 0.6)!;
    }
    return Color.lerp(scaffold, colors.secondary, 0.55)!;
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
