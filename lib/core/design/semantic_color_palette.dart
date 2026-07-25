import 'package:flutter/material.dart';

/// A complete tonal scale for a single semantic color.
///
/// Each tone is a pre-computed concrete [Color] — no runtime alpha arithmetic.
/// Dark-mode alpha compensation is baked in at theme-creation time, so widget
/// code never needs to branch on [Brightness].
///
/// Usage convention:
///
/// | Tone        | Old pattern                          | Use case                         |
/// |-------------|--------------------------------------|----------------------------------|
/// | [solid]     | `color.resolve(colors)` (no alpha)   | Icons, active indicators, buttons|
/// | [foreground]| `colors.primaryForeground` etc.      | Text/icons *on top of* [solid]   |
/// | [muted]     | `color.withValues(alpha: 0.08~0.12)` | Chip/badge/tag backgrounds       |
/// | [subtle]    | `color.withValues(alpha: 0.04~0.06)` | Container/empty-state backgrounds|
/// | [border]    | `color.withValues(alpha: 0.18~0.25)` | Colored container borders        |
/// | [shimmerBase]| `muted.withValues(alpha: 0.32~0.35)` | Skeleton/shimmer base color     |
/// | [disabled]  | `color.withValues(alpha: 0.5)`       | Disabled button foreground      |
/// | [borderStrong]| `color.withValues(alpha: 0.2~0.4)` | Shadows, emphasized borders, drag |
/// | [fill]      | `color.withValues(alpha: 0.55~0.56)` | Semi-transparent icons, circle bg |
/// | [fillStrong]| `color.withValues(alpha: 0.68~0.92)` | Buttons, sparklines, overlays, text |
@immutable
class SemanticColorPalette {
  const SemanticColorPalette({
    required this.solid,
    required this.foreground,
    required this.muted,
    required this.subtle,
    required this.border,
    required this.shimmerBase,
    required this.disabled,
    required this.borderStrong,
    required this.fill,
    required this.fillStrong,
  });

  /// Full-saturation color — buttons, active indicators, icon main color.
  final Color solid;

  /// Foreground color for text/icons placed *on top of* [solid].
  final Color foreground;

  /// Tinted background — chips, badges, tags, small accent containers.
  final Color muted;

  /// Very faint background — large containers, empty states.
  final Color subtle;

  /// Colored border for emphasized containers.
  final Color border;

  /// Skeleton/shimmer base color — loading placeholders.
  ///
  /// Pre-computed from [muted] with reduced alpha so shimmer
  /// animations have a consistent base across light/dark modes.
  final Color shimmerBase;

  /// Disabled state — muted but distinguishable.
  ///
  /// Used for disabled button foregrounds where the full [solid]
  /// would be too prominent.
  final Color disabled;

  /// Strong border / shadow tone — emphasized borders, drag indicators,
  /// box shadows. Higher alpha than [border].
  final Color borderStrong;

  /// Medium fill — semi-transparent icons, circular decoration backgrounds.
  /// Sits between [muted] and [solid] in opacity.
  final Color fill;

  /// Strong fill — buttons, sparklines, icons, overlays, gradient stops,
  /// text colors. High opacity but not fully [solid].
  final Color fillStrong;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemanticColorPalette &&
          solid == other.solid &&
          foreground == other.foreground &&
          muted == other.muted &&
          subtle == other.subtle &&
          border == other.border &&
          shimmerBase == other.shimmerBase &&
          disabled == other.disabled &&
          borderStrong == other.borderStrong &&
          fill == other.fill &&
          fillStrong == other.fillStrong;

  @override
  int get hashCode => Object.hash(
    solid,
    foreground,
    muted,
    subtle,
    border,
    shimmerBase,
    disabled,
    borderStrong,
    fill,
    fillStrong,
  );

  @override
  String toString() =>
      'SemanticColorPalette(solid: $solid, foreground: $foreground, '
      'muted: $muted, subtle: $subtle, border: $border, '
      'shimmerBase: $shimmerBase, disabled: $disabled, '
      'borderStrong: $borderStrong, fill: $fill, fillStrong: $fillStrong)';
}
