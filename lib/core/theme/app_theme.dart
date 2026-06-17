import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_colors.dart';
import 'package:luminous/core/design/app_color_tokens.dart';
import 'package:luminous/core/theme/app_theme_controller.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';

abstract final class AppTheme {
  static final light = lightFor(AppThemePalettePreference.classic);
  static final dark = darkFor(AppThemePalettePreference.classic);

  static ThemeData lightFor(AppThemePalettePreference palette) {
    final colors = _paletteColors(palette, Brightness.light);
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        secondary: colors.secondary,
        onSecondary: colors.onSecondary,
        surface: colors.surface.canvas,
        onSurface: colors.ink,
        onSurfaceVariant: colors.surface.body,
        outline: colors.surface.hairline,
        error: AppColorTokens.error,
        onError: AppColorTokens.onPrimary,
      ),
      brightness: Brightness.light,
      scaffoldBackgroundColor: colors.surface.canvasSoft,
      canvasColor: colors.surface.canvas,
      dividerColor: colors.surface.hairline,
      cardColor: colors.surface.canvas,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: colors.selectionBackground,
        selectionHandleColor: colors.primary,
      ),
      extensions: <ThemeExtension<dynamic>>[colors.surface],
    );
  }

  static ThemeData darkFor(AppThemePalettePreference palette) {
    final colors = _paletteColors(palette, Brightness.dark);
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        secondary: colors.secondary,
        onSecondary: colors.onSecondary,
        surface: colors.surface.canvas,
        onSurface: colors.ink,
        onSurfaceVariant: colors.surface.body,
        outline: colors.surface.hairline,
        error: const Color(0xFFFF6363),
        onError: AppColorTokens.primary,
      ),
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.surface.canvas,
      canvasColor: colors.surface.canvasSoft,
      dividerColor: colors.surface.hairline,
      cardColor: colors.surface.canvasSoft,
      shadowColor: Colors.black.withValues(alpha: 0.16),
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: colors.selectionBackground,
        selectionHandleColor: colors.primary,
      ),
      extensions: <ThemeExtension<dynamic>>[colors.surface],
    );
  }
}

class _ResolvedThemePalette {
  const _ResolvedThemePalette({
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.ink,
    required this.selectionBackground,
    required this.surface,
  });

  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color onSecondary;
  final Color ink;
  final Color selectionBackground;
  final AppThemeSurface surface;
}

_ResolvedThemePalette _paletteColors(
  AppThemePalettePreference palette,
  Brightness brightness,
) {
  return switch ((palette, brightness)) {
    (AppThemePalettePreference.classic, Brightness.light) =>
      const _ResolvedThemePalette(
        primary: AppColorTokens.primary,
        onPrimary: AppColorTokens.onPrimary,
        secondary: AppColorTokens.link,
        onSecondary: AppColorTokens.onPrimary,
        ink: AppColorTokens.ink,
        selectionBackground: AppColorTokens.selectionBackground,
        surface: AppThemeSurface.light,
      ),
    (AppThemePalettePreference.bluePink, Brightness.light) =>
      const _ResolvedThemePalette(
        primary: Color(0xFF47A0C9),
        onPrimary: Color(0xFF0E0E0E),
        secondary: Color(0xFFDF8CAD),
        onSecondary: Color(0xFF0E0E0E),
        ink: Color(0xFF0E0E0E),
        selectionBackground: Color(0xFF95CEE8),
        surface: AppThemeSurface.bluePinkLight,
      ),
    (AppThemePalettePreference.yellowGreen, Brightness.light) =>
      const _ResolvedThemePalette(
        primary: Color(0xFF4AA112),
        onPrimary: Color(0xFF1C1A1B),
        secondary: Color(0xFFD4B01D),
        onSecondary: Color(0xFF1C1A1B),
        ink: Color(0xFF1C1A1B),
        selectionBackground: Color(0xFFE7F0D6),
        surface: AppThemeSurface.yellowGreenLight,
      ),
    (AppThemePalettePreference.classic, Brightness.dark) =>
      const _ResolvedThemePalette(
        primary: AppColors.seed,
        onPrimary: AppColorTokens.onPrimary,
        secondary: AppColorTokens.link,
        onSecondary: AppColorTokens.onPrimary,
        ink: Color(0xFFF4F4F4),
        selectionBackground: AppColorTokens.selectionBackground,
        surface: AppThemeSurface.dark,
      ),
    (AppThemePalettePreference.bluePink, Brightness.dark) =>
      const _ResolvedThemePalette(
        primary: Color(0xFF95CEE8),
        onPrimary: Color(0xFF0E0E0E),
        secondary: Color(0xFFDF8CAD),
        onSecondary: Color(0xFF0E0E0E),
        ink: Color(0xFFF4F6F8),
        selectionBackground: Color(0xFF23475A),
        surface: AppThemeSurface.bluePinkDark,
      ),
    (AppThemePalettePreference.yellowGreen, Brightness.dark) =>
      const _ResolvedThemePalette(
        primary: Color(0xFFE7F0D6),
        onPrimary: Color(0xFF1C1A1B),
        secondary: Color(0xFFD4B01D),
        onSecondary: Color(0xFF1C1A1B),
        ink: Color(0xFFF3F5EF),
        selectionBackground: Color(0xFF344624),
        surface: AppThemeSurface.yellowGreenDark,
      ),
  };
}
