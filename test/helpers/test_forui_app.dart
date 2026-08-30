import 'package:flutter_localizations/flutter_localizations.dart' as fl;
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/theme/family.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

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
/// Use this for widget tests that do not need a [GoRouter]. Set
/// [showToaster] when the widget under test shows toasts (e.g. from a dialog
/// or bottom sheet): the toaster is then placed in the MaterialApp builder
/// (above the Navigator, mirroring production), and the test is responsible
/// for draining toast timers before it ends.
class TestForuiApp extends StatelessWidget {
  const TestForuiApp({
    super.key,
    this.themeMode = ThemeMode.light,
    this.locale = const Locale('zh'),
    this.home,
    this.showToaster = false,
  });

  final ThemeMode themeMode;
  final Locale locale;
  final Widget? home;
  final bool showToaster;

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
        child: showToaster
            ? FToaster(child: child ?? const SizedBox.shrink())
            : child ?? const SizedBox.shrink(),
      ),
      // material_ui's GlobalMaterialLocalizations.delegates covers
      // material_ui's MaterialLocalizations (for forui widgets).
      // fl.* delegates cover Flutter framework's MaterialLocalizations /
      // WidgetsLocalizations / CupertinoLocalizations (RefreshIndicator etc.).
      // Both sets register different interface types — both are needed.
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        FLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
        fl.GlobalMaterialLocalizations.delegate,
        fl.GlobalWidgetsLocalizations.delegate,
        fl.GlobalCupertinoLocalizations.delegate,
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
    this.showToaster = false,
    required this.routerConfig,
  });

  final ThemeMode themeMode;
  final Locale locale;

  /// Wraps the app in an [FToaster] above the navigator (mirroring
  /// production), so toast timers survive route pops. Needed by flows that
  /// show toasts whose action outlives the current route (e.g. the
  /// add-to-box success toast after the recognition dialog is closed).
  final bool showToaster;

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
        child: showToaster
            ? FToaster(child: child ?? const SizedBox.shrink())
            : child ?? const SizedBox.shrink(),
      ),
      // material_ui's GlobalMaterialLocalizations.delegates covers
      // material_ui's MaterialLocalizations (for forui widgets).
      // fl.* delegates cover Flutter framework's MaterialLocalizations /
      // WidgetsLocalizations / CupertinoLocalizations (RefreshIndicator etc.).
      // Both sets register different interface types — both are needed.
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        FLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
        fl.GlobalMaterialLocalizations.delegate,
        fl.GlobalWidgetsLocalizations.delegate,
        fl.GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: routerConfig,
    );
  }
}
