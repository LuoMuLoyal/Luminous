import 'package:flutter/material.dart';

import 'package:luminous/core/design/color/palette.dart';

/// Gradient token system.
///
/// Provides named gradient patterns for the few places that use gradients.
/// All gradients are defined here — no ad-hoc `LinearGradient` in widget code.
///
/// | Token          | Use case                                    |
/// |----------------|---------------------------------------------|
/// | [semanticFill] | Icon tile / badge needing visual weight      |
/// | [tintFade]     | Container with color-tinted background fade  |
abstract final class GradientTokens {
  /// Semantic color fill gradient — primary suggestion card icon tiles,
  /// badges, and other elements that need visual weight beyond a flat
  /// muted fill.
  ///
  /// Goes from [SemanticColorPalette.fillStrong] to [SemanticColorPalette.solid]
  /// (top-left → bottom-right), creating a rich but tonally-consistent fill.
  static Gradient semanticFill(SemanticColorPalette palette) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [palette.fillStrong, palette.solid],
  );

  /// Color tint fade — hero sections and containers that need a subtle
  /// color-tinted background. Goes from [from] (typically a semantic border
  /// tone) to [to] (typically the theme background), creating a gentle
  /// color wash that fades into the base surface.
  static Gradient tintFade(Color from, Color to) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [from, to],
  );
}
