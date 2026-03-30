import 'package:flutter/material.dart';
import 'package:luminous/components/app_surface.dart';

const double kQuickEntryCardRadius = 16;

class QuickEntryVisualStyle {
  const QuickEntryVisualStyle({
    required this.background,
    required this.border,
    required this.iconBackground,
    required this.iconBorder,
    required this.iconColor,
    required this.titleColor,
    required this.subtitleColor,
  });

  final Color background;
  final Color border;
  final Color iconBackground;
  final Color iconBorder;
  final Color iconColor;
  final Color titleColor;
  final Color subtitleColor;
}

QuickEntryVisualStyle resolveQuickEntryVisualStyle(
  BuildContext context,
  Color itemColor,
) {
  final scheme = Theme.of(context).colorScheme;
  final entryThemeColor = Color.lerp(
    itemColor,
    Color.lerp(scheme.primary, scheme.secondary, 0.42)!,
    0.40,
  )!;

  return QuickEntryVisualStyle(
    background: appTintedSurface(
      context,
      entryThemeColor,
      lightAlpha: 0.13,
      darkAlpha: 0.22,
    ),
    border: appTintedBorder(
      context,
      entryThemeColor,
      lightAlpha: 0.24,
      darkAlpha: 0.38,
    ),
    iconBackground: appTintedSurface(
      context,
      entryThemeColor,
      lightAlpha: 0.22,
      darkAlpha: 0.32,
    ),
    iconBorder: appTintedBorder(
      context,
      entryThemeColor,
      lightAlpha: 0.27,
      darkAlpha: 0.43,
    ),
    iconColor: Color.lerp(itemColor, scheme.primary, 0.28)!,
    titleColor: scheme.onSurface,
    subtitleColor: scheme.onSurfaceVariant,
  );
}
