import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

const AppThemeFamily appDefaultThemeFamily = AppThemeFamily.blue;

enum AppThemeFamily {
  blue('blue'),
  green('green'),
  neutral('neutral'),
  orange('orange'),
  red('red'),
  rose('rose'),
  slate('slate'),
  violet('violet'),
  yellow('yellow'),
  zinc('zinc');

  const AppThemeFamily(this.storageValue);

  final String storageValue;

  static AppThemeFamily fromStorage(String? value) {
    for (final family in AppThemeFamily.values) {
      if (family.storageValue == value) {
        return family;
      }
    }
    return appDefaultThemeFamily;
  }
}

FThemeData appThemeData(AppThemeFamily family, Brightness brightness) {
  return switch ((family, brightness)) {
    (AppThemeFamily.blue, Brightness.light) => FThemes.blue.light.touch,
    (AppThemeFamily.blue, Brightness.dark) => FThemes.blue.dark.touch,
    (AppThemeFamily.green, Brightness.light) => FThemes.green.light.touch,
    (AppThemeFamily.green, Brightness.dark) => FThemes.green.dark.touch,
    (AppThemeFamily.neutral, Brightness.light) => FThemes.neutral.light.touch,
    (AppThemeFamily.neutral, Brightness.dark) => FThemes.neutral.dark.touch,
    (AppThemeFamily.orange, Brightness.light) => FThemes.orange.light.touch,
    (AppThemeFamily.orange, Brightness.dark) => FThemes.orange.dark.touch,
    (AppThemeFamily.red, Brightness.light) => FThemes.red.light.touch,
    (AppThemeFamily.red, Brightness.dark) => FThemes.red.dark.touch,
    (AppThemeFamily.rose, Brightness.light) => FThemes.rose.light.touch,
    (AppThemeFamily.rose, Brightness.dark) => FThemes.rose.dark.touch,
    (AppThemeFamily.slate, Brightness.light) => FThemes.slate.light.touch,
    (AppThemeFamily.slate, Brightness.dark) => FThemes.slate.dark.touch,
    (AppThemeFamily.violet, Brightness.light) => FThemes.violet.light.touch,
    (AppThemeFamily.violet, Brightness.dark) => FThemes.violet.dark.touch,
    (AppThemeFamily.yellow, Brightness.light) => FThemes.yellow.light.touch,
    (AppThemeFamily.yellow, Brightness.dark) => FThemes.yellow.dark.touch,
    (AppThemeFamily.zinc, Brightness.light) => FThemes.zinc.light.touch,
    (AppThemeFamily.zinc, Brightness.dark) => FThemes.zinc.dark.touch,
  };
}

ThemeData foruiMaterialTheme(FThemeData theme) {
  final material = theme.toApproximateMaterialTheme();
  return material.copyWith(
    scaffoldBackgroundColor: theme.colors.background,
    canvasColor: theme.colors.background,
    cardColor: theme.colors.card,
    dividerColor: theme.colors.border,
    shadowColor: theme.colors.foreground.withValues(
      alpha: theme.colors.brightness == Brightness.dark ? 0.16 : 0.06,
    ),
  );
}
