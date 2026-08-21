import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:luminous/core/design/design.dart';

/// Derives the FlowUI theme from the ambient Luminous Forui theme.
FlowTheme luminousFlowTheme(BuildContext context) {
  final colors = context.theme.colors;
  final baseColors = Theme.of(context).brightness == Brightness.dark
      ? FlowColors.dark
      : FlowColors.light;

  return FlowTheme(
    colors: baseColors.copyWith(
      primary: SemanticColor.primary.solid(context),
      onPrimary: colors.primaryForeground,
      surface: colors.background,
      onSurface: colors.foreground,
      onSurfaceVariant: colors.mutedForeground,
      onSurfaceMuted: colors.mutedForeground.withValues(alpha: 0.5),
      onSurfaceDisabled: colors.mutedForeground.withValues(alpha: 0.3),
      outline: colors.border,
      outlineVariant: colors.border.withValues(alpha: 0.5),
      surfaceBright: colors.card,
      surfaceContainerLowest: colors.background,
      surfaceContainerLow: colors.secondary,
      surfaceContainer: colors.secondary,
      surfaceContainerHigh: colors.secondary,
      surfaceContainerHighest: colors.secondary,
      error: SemanticColor.destructive.solid(context),
      onError: Colors.white,
    ),
    typography: FlowTypography.standard.withFontFamily(
      TypographyToken.level4.body(context).fontFamily ?? 'Figtree',
    ),
  );
}

/// Installs [luminousFlowTheme] for an assistant subtree only.
Widget withLuminousFlowTheme(BuildContext context, Widget child) {
  final parentTheme = Theme.of(context);
  final extensions =
      parentTheme.extensions.values
          .where((extension) => extension is! FlowTheme)
          .toList(growable: true)
        ..add(luminousFlowTheme(context));

  return Theme(
    data: parentTheme.copyWith(extensions: extensions),
    child: child,
  );
}
