import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/accessibility/settings_controller.dart';
import 'package:luminous/core/database/cache_cleanup.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/i18n/locale.dart';
import 'package:luminous/core/i18n/locale_controller.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/shortcuts/app_shortcuts.dart';
import 'package:luminous/core/theme/preference.dart';
import 'package:luminous/core/theme/theme.dart';
import 'package:luminous/core/widgets/common/desktop_window_chrome.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/medicine/presentation/providers/reminder_notification_coordinator.dart';
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
      // Trigger cache cleanup based on data retention setting
      ref.read(cacheCleanupProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthSessionState>(authSessionProvider, (previous, next) {
      // Re-evaluate the router redirect whenever auth state changes.
      ref.read(appRouterProvider).refresh();

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
        .watch(themeControllerProvider)
        .maybeWhen(
          data: (preference) => preference,
          orElse: () => const ThemePreference(),
        );
    final themeMode = themePreference.mode.themeMode;
    var lightTheme = appThemeData(themePreference.family, Brightness.light);
    var darkTheme = appThemeData(themePreference.family, Brightness.dark);
    final locale = ref.watch(localeControllerProvider).asData?.value;

    final accessibility = ref
        .watch(accessibilitySettingsControllerProvider)
        .asData
        ?.value;
    final highContrast = accessibility?.highContrast ?? false;
    if (highContrast) {
      lightTheme = _applyHighContrast(lightTheme);
      darkTheme = _applyHighContrast(darkTheme);
    }

    final textScaler = accessibility != null
        ? TextScaler.linear(accessibility.fontSize.scaleFactor)
        : TextScaler.noScaling;
    final reduceAnimations = accessibility?.reduceAnimations ?? false;

    return MaterialApp.router(
      onGenerateTitle: (context) =>
          AppLocalizations.of(context)?.appTitle ?? 'Luminous',
      debugShowCheckedModeBanner: false,
      theme: foruiMaterialTheme(lightTheme),
      darkTheme: foruiMaterialTheme(darkTheme),
      themeMode: themeMode,
      locale: locale?.flutterLocale,
      builder: (context, child) {
        final brightness = Theme.of(context).brightness;
        final fTheme = brightness == Brightness.dark ? darkTheme : lightTheme;
        return FTheme(
          data: fTheme,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: textScaler,
              accessibleNavigation: reduceAnimations,
            ),
            child: FToaster(
              child: _withDesktopChrome(
                AppShortcuts(child: child ?? const SizedBox.shrink()),
              ),
            ),
          ),
        );
      },
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        FLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: widget.routerConfig ?? ref.watch(appRouterProvider),
    );
  }

  Future<void> _restoreLocaleFromProfile() async {
    try {
      final snapshot = await ref.read(healthContextSnapshotProvider.future);
      final locale = AppLocale.fromBackendPreference(snapshot.profile.locale);
      if (locale == null) {
        return;
      }

      final currentLocale = ref.read(localeControllerProvider).asData?.value;
      if (currentLocale == locale) {
        return;
      }

      await ref.read(localeControllerProvider.notifier).setLocale(locale);
    } catch (e) {
      ref
          .read(talkerProvider)
          .error(
            'App._syncLocaleFromHealthContext: locale backfill failed: $e',
          );
    }
  }
}

/// Wraps [child] with [DesktopWindowChrome] on Windows/Linux desktop,
/// adding a full-width drag area and window control buttons at the top.
/// On other platforms, returns [child] unchanged.
Widget _withDesktopChrome(Widget child) {
  if (!Platform.isWindows && !Platform.isLinux) return child;
  return Column(
    children: [
      const DesktopWindowChrome(),
      Expanded(child: child),
    ],
  );
}

/// Creates a high-contrast variant of [theme] by maximizing foreground/
/// background contrast and strengthening borders.
FThemeData _applyHighContrast(FThemeData theme) {
  final colors = theme.colors;
  final isDark = colors.brightness == Brightness.dark;
  return FThemeData(
    touch: true,
    debugLabel: theme.debugLabel,
    colors: colors.copyWith(
      foreground: isDark
          ? HighContrastColors.darkForeground
          : HighContrastColors.lightForeground,
      mutedForeground: isDark
          ? HighContrastColors.darkMutedForeground
          : HighContrastColors.lightMutedForeground,
      border: isDark
          ? HighContrastColors.darkBorder
          : HighContrastColors.lightBorder,
    ),
  );
}
