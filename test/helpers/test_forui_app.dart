import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Forui-aware light theme used by tests.
final FThemeData _foruiLight = FThemes.neutral.light.touch;

/// Forui-aware dark theme used by tests.
final FThemeData _foruiDark = FThemes.neutral.dark.touch;

ThemeData _materialTheme(FThemeData theme) {
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

/// A lightweight test app that wraps [child] with the same Forui theme
/// bootstrap used by [LuminousApp].
///
/// Use this for widget tests that do not need a [GoRouter].
class TestForuiApp extends StatelessWidget {
  const TestForuiApp({
    super.key,
    this.themeMode = ThemeMode.light,
    this.locale = const Locale('zh'),
    required this.child,
  });

  final ThemeMode themeMode;
  final Locale locale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _materialTheme(_foruiLight),
      darkTheme: _materialTheme(_foruiDark),
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        FLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }
}

/// A lightweight test app that wraps a [GoRouter] with the same Forui theme
/// bootstrap used by [LuminousApp].
class TestForuiRouterApp extends StatelessWidget {
  const TestForuiRouterApp({
    super.key,
    this.themeMode = ThemeMode.light,
    this.locale = const Locale('zh'),
    required this.routerConfig,
  });

  final ThemeMode themeMode;
  final Locale locale;
  final RouterConfig<Object> routerConfig;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: _materialTheme(_foruiLight),
      darkTheme: _materialTheme(_foruiDark),
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        FLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: routerConfig,
    );
  }
}
