import 'package:flutter/material.dart';
import 'package:luminous/core/design/tokens/breakpoints.dart';

/// Lightweight responsive sizing helpers for cards, sidebars, grid counts, and
/// scalable dimensions.
///
/// These are layout helpers, not visual design tokens. They use simple
/// fractions and min/max clamps to adapt structural dimensions to the current
/// screen size; color, spacing, radius, and typography values should come from
/// the current Forui theme or the dedicated token files instead.
abstract final class ResponsiveSizing {
  /// Returns a card width that occupies a fraction of the screen on small
  /// devices while staying within a comfortable min/max range.
  ///
  /// Default fraction is 0.72 so a horizontally scrollable card peeks at the
  /// next item on typical phone widths (≈280–320 px on 390–430 px screens).
  static double cardWidth(
    BuildContext context, {
    double mobileFraction = 0.72,
    double minWidth = 260,
    double maxWidth = 320,
  }) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return (screenWidth * mobileFraction).clamp(minWidth, maxWidth);
  }

  /// Returns a sidebar width that scales with the screen width on desktop
  /// layouts but never collapses below [minWidth] or exceeds [maxWidth].
  static double sidebarWidth(
    BuildContext context, {
    double fraction = 0.22,
    double minWidth = 280,
    double maxWidth = 360,
  }) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return (screenWidth * fraction).clamp(minWidth, maxWidth);
  }

  /// Returns the number of columns for a grid based on the current breakpoint.
  static int gridCrossAxisCount(
    BuildContext context, {
    int mobile = 2,
    int tablet = 3,
    int desktop = 4,
    int ultrawide = 6,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= Breakpoints.ultrawide) return ultrawide;
    if (width >= Breakpoints.desktop) return desktop;
    if (width >= Breakpoints.tablet) return tablet;
    return mobile;
  }

  /// Returns a value that scales with the available width, clamped between
  /// [minValue] and [maxValue]. Useful for font sizes, icon diameters, etc.
  static double scaleByWidth(
    BuildContext context, {
    required double fraction,
    required double minValue,
    required double maxValue,
  }) {
    return (MediaQuery.sizeOf(context).width * fraction).clamp(
      minValue,
      maxValue,
    );
  }

  /// Returns a value that scales with the available height, clamped between
  /// [minValue] and [maxValue]. Useful for chart placeholders, hero images, etc.
  static double scaleByHeight(
    BuildContext context, {
    required double fraction,
    required double minValue,
    required double maxValue,
  }) {
    return (MediaQuery.sizeOf(context).height * fraction).clamp(
      minValue,
      maxValue,
    );
  }
}
