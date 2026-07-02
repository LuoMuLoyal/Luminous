import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

abstract final class AppTheme {
  static final FThemeData foruiLight = FThemes.neutral.light.touch;
  static final FThemeData foruiDark = FThemes.neutral.dark.touch;

  static final ThemeData light = _materialTheme(foruiLight);
  static final ThemeData dark = _materialTheme(foruiDark);

  static FThemeData forBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? foruiDark : foruiLight;
  }

  static ThemeData _materialTheme(FThemeData theme) {
    final material = theme.toApproximateMaterialTheme();
    return material.copyWith(
      scaffoldBackgroundColor: theme.colors.background,
      canvasColor: theme.colors.background,
      cardColor: theme.colors.card,
      dividerColor: theme.colors.border,
      shadowColor: Colors.black.withValues(
        alpha: theme.colors.brightness == Brightness.dark ? 0.16 : 0.06,
      ),
    );
  }
}
