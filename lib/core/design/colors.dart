import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Semantic color tokens used by data/domain layers so they do not hard-code
/// concrete [Color] values. The actual [Color] is resolved in the presentation
/// layer against the current Forui theme.
enum AppColors {
  primary,
  destructive,
  secondary,
  muted,
  background,
  border,
  foreground,
}

extension AppColorsResolution on AppColors {
  Color resolve(FColors colors) => switch (this) {
    AppColors.primary => colors.primary,
    AppColors.destructive => colors.destructive,
    AppColors.secondary => colors.secondary,
    AppColors.muted => colors.mutedForeground,
    AppColors.background => colors.background,
    AppColors.border => colors.border,
    AppColors.foreground => colors.foreground,
  };
}

extension AppColorsContext on AppColors {
  Color of(BuildContext context) => resolve(context.theme.colors);
}

extension AppColorsListResolution on List<AppColors> {
  List<Color> resolveAll(FColors colors) =>
      map((c) => c.resolve(colors)).toList();
}
