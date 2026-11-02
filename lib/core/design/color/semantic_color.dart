import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/shared/domain/semantic.dart';

import 'palette.dart';
import 'theme_extension.dart';

export 'package:luminous/shared/domain/semantic.dart' show SemanticColor;

/// The [SemanticColor] enum itself lives in the shared domain kernel
/// (`lib/shared/domain/semantic.dart`) so feature `domain/` layers can store a
/// colour token without importing `lib/core/**`. This file owns the
/// theme-dependent resolution: the concrete [SemanticColorPalette] (10
/// pre-computed tones) resolved against the current Forui theme.

extension SemanticColorResolution on SemanticColor {
  /// Returns the full tonal palette for this color.
  SemanticColorPalette palette(BuildContext context) =>
      paletteFromColors(context.theme.colors);

  /// Returns the full tonal palette from an [FColors] instance.
  SemanticColorPalette paletteFromColors(FColors colors) =>
      colors.semantic.of(this);

  // ── Convenience shortcuts ──

  /// Full-saturation color. Use for icons, active indicators, buttons.
  Color solid(BuildContext context) => palette(context).solid;

  /// Foreground color for text/icons on top of [solid].
  Color foreground(BuildContext context) => palette(context).foreground;

  /// Tinted background for chips, badges, tags.
  Color muted(BuildContext context) => palette(context).muted;

  /// Very faint background for containers and empty states.
  Color subtle(BuildContext context) => palette(context).subtle;

  /// Colored border for emphasized containers.
  Color border(BuildContext context) => palette(context).border;

  /// Skeleton/shimmer base color for loading placeholders.
  Color shimmerBase(BuildContext context) => palette(context).shimmerBase;

  /// Disabled state — muted but distinguishable.
  Color disabled(BuildContext context) => palette(context).disabled;

  /// Strong border / shadow tone — emphasized borders, drag indicators, shadows.
  Color borderStrong(BuildContext context) => palette(context).borderStrong;

  /// Medium fill — semi-transparent icons, circular decoration backgrounds.
  Color fill(BuildContext context) => palette(context).fill;

  /// Strong fill — buttons, sparklines, icons, overlays, gradient stops, text.
  Color fillStrong(BuildContext context) => palette(context).fillStrong;
}

extension SemanticColorListResolution on List<SemanticColor> {
  List<Color> resolveAll(FColors colors) =>
      map((c) => c.paletteFromColors(colors).solid).toList();
}

/// Convenient access to [SemanticColors] on [FColors].
///
/// Uses [extensions] iteration rather than [extension] to avoid forui's
/// internal `!` non-null assertion, which would throw an obscure `TypeError`
/// when the extension is missing. Instead, a descriptive [StateError] is
/// thrown to aid debugging in misconfigured themes or test environments.
///
/// Lives here rather than in `theme_extension.dart` (which only declares the
/// [SemanticColors] value type) so the two files no longer import each other.
extension SemanticColorsAccess on FColors {
  SemanticColors get semantic {
    for (final ext in extensions) {
      if (ext is SemanticColors) return ext;
    }
    throw StateError(
      'SemanticColors is not injected into FColors. '
      'Ensure appThemeData() includes SemanticColors in extensions.',
    );
  }
}
