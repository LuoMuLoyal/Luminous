import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/theme/theme.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Forui-aware light theme used by tests.
final FThemeData _foruiLight = appThemeData(
  appDefaultThemeFamily,
  Brightness.light,
);

/// Forui-aware dark theme used by tests.
final FThemeData _foruiDark = appThemeData(
  appDefaultThemeFamily,
  Brightness.dark,
);

/// A lightweight test app that wraps [child] with the same Forui theme
/// bootstrap used by [LuminousApp].
///
/// Use this for widget tests that do not need a [GoRouter].
class TestForuiApp extends StatelessWidget {
  const TestForuiApp({
    super.key,
    this.themeMode = ThemeMode.light,
    this.locale = const Locale('zh'),
    this.home,
  });

  final ThemeMode themeMode;
  final Locale locale;
  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: foruiMaterialTheme(_foruiLight),
      darkTheme: foruiMaterialTheme(_foruiDark),
      themeMode: themeMode,
      locale: locale,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => FTheme(
        data: Theme.of(context).brightness == Brightness.dark
            ? _foruiDark
            : _foruiLight,
        child: child ?? const SizedBox.shrink(),
      ),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        FLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
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
      theme: foruiMaterialTheme(_foruiLight),
      darkTheme: foruiMaterialTheme(_foruiDark),
      themeMode: themeMode,
      locale: locale,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => FTheme(
        data: Theme.of(context).brightness == Brightness.dark
            ? _foruiDark
            : _foruiLight,
        child: child ?? const SizedBox.shrink(),
      ),
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
