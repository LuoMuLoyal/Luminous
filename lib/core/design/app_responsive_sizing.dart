import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_breakpoints.dart';

/// Lightweight responsive sizing helpers for cards, sidebars, and grid counts.
///
/// These helpers deliberately use simple fractions and min/max clamps rather
/// than a full layout grid, so they can be adopted incrementally without
/// rewriting the existing design system.
abstract final class AppResponsiveSizing {
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
  }) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppBreakpoints.desktop) return desktop;
    if (width >= AppBreakpoints.tablet) return tablet;
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
