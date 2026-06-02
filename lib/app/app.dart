import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/core/theme/app_theme_controller.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/l10n/app_localizations.dart';

class LuminousApp extends ConsumerStatefulWidget {
  const LuminousApp({super.key, this.routerConfig});

  final RouterConfig<Object>? routerConfig;

  @override
  ConsumerState<LuminousApp> createState() => _LuminousAppState();
}

class _LuminousAppState extends ConsumerState<LuminousApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(authSessionProvider.notifier).restore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref
        .watch(appThemeControllerProvider)
        .maybeWhen(
          data: (preference) => preference.themeMode,
          orElse: () => ThemeMode.system,
        );

    return MaterialApp.router(
      onGenerateTitle: (context) =>
          AppLocalizations.of(context)?.appTitle ?? 'Luminous',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: widget.routerConfig ?? router,
    );
  }
}
