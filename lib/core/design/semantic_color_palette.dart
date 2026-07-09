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
@immutable
class SemanticColorPalette {
  const SemanticColorPalette({
    required this.solid,
    required this.foreground,
    required this.muted,
    required this.subtle,
    required this.border,
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemanticColorPalette &&
          solid == other.solid &&
          foreground == other.foreground &&
          muted == other.muted &&
          subtle == other.subtle &&
          border == other.border;

  @override
  int get hashCode => Object.hash(solid, foreground, muted, subtle, border);

  @override
  String toString() =>
      'SemanticColorPalette(solid: $solid, foreground: $foreground, '
      'muted: $muted, subtle: $subtle, border: $border)';
}
