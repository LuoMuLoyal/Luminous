import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'semantic_color_palette.dart';
import 'semantic_colors.dart';

/// Semantic color token used by domain/data layers to stay theme-agnostic.
///
/// Replaces the former `AppColors` enum. The actual [SemanticColorPalette]
/// (5 pre-computed tones) is resolved in the presentation layer against the
/// current Forui theme.
///
/// The [neutral] variant covers entities that previously used `AppColors.secondary`,
/// `.muted`, `.foreground`, `.background`, or `.border` — i.e. "no particular
/// semantic meaning." Its palette derives from the theme's neutral colors
/// (`mutedForeground`, `secondary`, `border`).
enum SemanticColor { primary, success, warning, info, destructive, neutral }

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
