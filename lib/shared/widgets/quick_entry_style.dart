import 'package:flutter/material.dart';
import 'package:luminous/shared/widgets/app_surface.dart';

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
      lightAlpha: 0.15,
      darkAlpha: 0.24,
    ),
    border: appTintedBorder(
      context,
      entryThemeColor,
      lightAlpha: 0.28,
      darkAlpha: 0.40,
    ),
    iconBackground: appTintedSurface(
      context,
      entryThemeColor,
      lightAlpha: 0.30,
      darkAlpha: 0.36,
    ),
    iconBorder: appTintedBorder(
      context,
      entryThemeColor,
      lightAlpha: 0.34,
      darkAlpha: 0.47,
    ),
    iconColor: Color.lerp(itemColor, scheme.primary, 0.12)!,
    titleColor: scheme.onSurface,
    subtitleColor: Color.lerp(scheme.onSurfaceVariant, scheme.onSurface, 0.24)!,
  );
}
