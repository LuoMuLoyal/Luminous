import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/i18n/app_locale.dart';
import 'package:luminous/core/i18n/app_locale_controller.dart';
import 'package:luminous/core/theme/app_theme_controller.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_reminder_notification_coordinator.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/core/theme/theme.dart';

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
    ref.listen<AuthSessionState>(authSessionProvider, (previous, next) {
      final previousUserId = previous?.user?.id;
      final nextUserId = next.user?.id;

      if (previous?.isAuthenticated == true && !next.isAuthenticated) {
        ref.invalidate(healthContextSnapshotProvider);
        return;
      }

      if (!next.isAuthenticated || next.isLoading) {
        return;
      }

      final becameAuthenticated = previous?.isAuthenticated != true;
      final switchedUser =
          previousUserId != null && previousUserId != nextUserId;
      if (!becameAuthenticated && !switchedUser) {
        return;
      }

      ref.invalidate(healthContextSnapshotProvider);
      unawaited(_restoreLocaleFromProfile());
    });
    ref.listen<AsyncValue<void>>(
      medicineReminderNotificationSyncProvider,
      (_, _) {},
    );

    final themePreference = ref
        .watch(appThemeControllerProvider)
        .maybeWhen(
          data: (preference) => preference,
          orElse: () => const AppThemePreference(),
        );
    final themeMode = themePreference.mode.themeMode;
    final lightTheme = appThemeData(themePreference.family, Brightness.light);
    final darkTheme = appThemeData(themePreference.family, Brightness.dark);
    final locale = ref.watch(appLocaleControllerProvider).asData?.value;

    return MaterialApp.router(
      onGenerateTitle: (context) =>
          AppLocalizations.of(context)?.appTitle ?? 'Luminous',
      debugShowCheckedModeBanner: false,
      theme: foruiMaterialTheme(lightTheme),
      darkTheme: foruiMaterialTheme(darkTheme),
      themeMode: themeMode,
      locale: locale?.flutterLocale,
      builder: (context, child) => FTheme(
        data: Theme.of(context).brightness == Brightness.dark
            ? darkTheme
            : lightTheme,
        child: FToaster(child: child ?? const SizedBox.shrink()),
      ),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        FLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: widget.routerConfig ?? router,
    );
  }

  Future<void> _restoreLocaleFromProfile() async {
    try {
      final snapshot = await ref.read(healthContextSnapshotProvider.future);
      final locale = AppLocale.fromBackendPreference(snapshot.profile.locale);
      if (locale == null) {
        return;
      }

      final currentLocale = ref.read(appLocaleControllerProvider).asData?.value;
      if (currentLocale == locale) {
        return;
      }

      await ref.read(appLocaleControllerProvider.notifier).setLocale(locale);
    } catch (e) {
      debugPrint(
        'App._syncLocaleFromHealthContext: locale backfill failed: $e',
      );
    }
  }
}
