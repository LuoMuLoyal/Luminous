import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart' as fl;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/app/auth_session_adapter.dart';
import 'package:luminous/app/composition/health_context/health_context.dart';
import 'package:luminous/app/composition/settings/cache_cleanup.dart';
import 'package:luminous/app/composition/settings/sleep_reminder_sync.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/accessibility/settings.dart';
import 'package:luminous/core/database/sync/background.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/i18n/locale.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/push/lifecycle.dart';
import 'package:luminous/core/push/message_handler.dart';
import 'package:luminous/core/shortcuts/bindings.dart';
import 'package:luminous/core/theme/family.dart';
import 'package:luminous/core/theme/preference.dart';
import 'package:luminous/core/widgets/common/control/desktop/window_chrome.dart';
import 'package:luminous/features/medicine/presentation/providers/reminder_delivery_reporter.dart';
import 'package:luminous/features/medicine/presentation/providers/reminder_notification_coordinator.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

class LuminousApp extends ConsumerStatefulWidget {
  const LuminousApp({super.key, this.routerConfig, this.desktopChrome = true});

  final RouterConfig<Object>? routerConfig;

  /// 是否渲染桌面窗口条（最小化 / 最大化 / 关闭）。
  ///
  /// 默认开启，生产行为不变。截图生成器传 `false`：那是**移动端页面**的证据集，
  /// 顶上一条 Windows 窗口控件既不属于任何屏幕尺寸下的真实 UI，也会让
  /// 平台判断（`Platform.isWindows`）把「这台机器在跑测试」泄漏进产物。
  final bool desktopChrome;

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
      unawaited(_restoreAuthAndStartPush());
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthSessionState>(authSessionProvider, (previous, next) {
      // Re-evaluate the router redirect whenever auth state changes.
      ref.read(appRouterProvider).refresh();

      final previousUserId = previous?.userId;
      final nextUserId = next.userId;

      // Logout: invalidate health context + sync push alias to null, then return.
      if (previous?.isAuthenticated == true && !next.isAuthenticated) {
        ref.invalidate(healthContextSnapshotProvider);
        unawaited(_syncPushAuth(null));
        unawaited(ref.read(backgroundSyncSchedulerProvider).cancel());
        return;
      }

      // Login / session restore / user switch: sync push alias.
      if (!next.isLoading) {
        unawaited(_syncPushAuth(next.isAuthenticated ? next.userId : null));
      }

      if (!next.isAuthenticated || next.isLoading) return;

      final becameAuthenticated = previous?.isAuthenticated != true;
      final switchedUser =
          previousUserId != null && previousUserId != nextUserId;
      if (!becameAuthenticated && !switchedUser) {
        return;
      }

      ref.invalidate(healthContextSnapshotProvider);
      unawaited(_restoreLocaleFromProfile());
      unawaited(ref.read(backgroundSyncSchedulerProvider).schedule());
    });
    ref.listen<AsyncValue<void>>(
      medicineReminderNotificationSyncProvider,
      (_, _) {},
    );
    ref.listen<AsyncValue<void>>(
      sleepReminderNotificationSyncProvider,
      (_, _) {},
    );
    ref.watch(medicineReminderDeliveryReporterProvider);
    ref.watch(pushCoordinatorProvider);
    ref.watch(localNotificationRouterProvider);
    ref.listen<AsyncValue<Map<String, dynamic>>>(
      aiTodaySummaryPushEventsProvider,
      (previous, next) {
        next.whenData((event) => _showAiTodaySummaryToast(context, event));
      },
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
        // 窄屏（≤360dp）上把生效字号降档：1.3 档在 360dp 机器上等于把可用宽度
        // 再砍 23%，是成片溢出的最坏组合；布局按 1.15 设计即可安全。
        ? TextScaler.linear(
            LayoutScaleResolver.effectiveTextScale(
              MediaQuery.sizeOf(context).width,
              accessibility.fontSize.scaleFactor,
            ),
          )
        : TextScaler.noScaling;
    final reduceAnimations = accessibility?.reduceAnimations ?? false;

    return MaterialApp.router(
      onGenerateTitle: (context) =>
          AppLocalizations.of(context)?.appTitle ?? 'Luminous',
      debugShowCheckedModeBanner: false,
      theme: foruiMaterialTheme(lightTheme),
      darkTheme: foruiMaterialTheme(darkTheme),
      themeMode: themeMode,
      // 桌面端滚动条常驻且更宽：鼠标滚轮与拖动条是桌面阅读的主要方式，
      // Flutter 默认的「窄条 + 悬停才显形」在桌面观感上像网页浮层。
      // 触屏平台不受影响（Scrollbar 在移动端不绘制）。
      scrollBehavior: const _DesktopScrollBehavior(),
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
                enabled: widget.desktopChrome,
              ),
            ),
          ),
        );
      },
      // material_ui's GlobalMaterialLocalizations.delegates covers
      // material_ui's own MaterialLocalizations type (for forui widgets).
      // flutter_localizations' fl.* delegates cover Flutter framework's
      // MaterialLocalizations / WidgetsLocalizations / CupertinoLocalizations
      // (for widgets like RefreshIndicator, TextField, etc.).
      // Both sets are needed — they register different interface types.
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        FLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
        fl.GlobalMaterialLocalizations.delegate,
        fl.GlobalWidgetsLocalizations.delegate,
        fl.GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: widget.routerConfig ?? ref.watch(appRouterProvider),
    );
  }

  Future<void> _restoreAuthAndStartPush() async {
    try {
      await ref.read(authSessionProvider.notifier).restore();
      if (!mounted) return;

      // Keep cache cleanup startup work in the same post-frame bootstrap.
      ref.read(cacheCleanupProvider);

      final coordinator = ref.read(pushCoordinatorProvider);
      await coordinator.start();
      final session = ref.read(authSessionProvider);
      await coordinator.onAuthChanged(
        userId: session.isAuthenticated ? session.userId : null,
      );
    } catch (error) {
      ref.read(talkerProvider).error('Push startup failed: $error');
    }
  }

  Future<void> _syncPushAuth(String? userId) async {
    try {
      await ref.read(pushCoordinatorProvider).onAuthChanged(userId: userId);
    } catch (error) {
      ref.read(talkerProvider).error('Push alias sync failed: $error');
    }
  }

  void _showAiTodaySummaryToast(
    BuildContext context,
    Map<String, dynamic> event,
  ) {
    final title =
        event['title']?.toString() ?? event['alert']?.toString() ?? '';
    final body =
        event['content']?.toString() ??
        event['body']?.toString() ??
        event['message']?.toString() ??
        '';
    final message = <String>[title, body].where((s) => s.isNotEmpty).join('\n');
    if (message.isEmpty) return;

    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    unawaited(
      Toast.showWithAction(
        context,
        message,
        l10n.todayViewDetailsAction,
        () => ref.read(appRouterProvider).go(Routes.home),
      ),
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
/// On other platforms — or when [enabled] is false — returns [child] unchanged.
Widget _withDesktopChrome(Widget child, {bool enabled = true}) {
  if (!enabled) return child;
  if (kIsWeb) return child;
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
///
/// `touch` must stay `false` to match the app's compact baseline — flipping it
/// here would inflate every component dimension only while high contrast is on.
///
/// Because this rebuilds the theme from scratch, [theme]'s custom typography
/// (the touch typeface the app keeps on a compact geometry) and toaster style
/// (top-center) are carried over explicitly. Dropping them would silently fall
/// back to `touch: false` defaults — body.sm 16→14 and toasts back to the
/// bottom-right corner.
FThemeData _applyHighContrast(FThemeData theme) {
  final colors = theme.colors;
  final isDark = colors.brightness == Brightness.dark;
  return FThemeData(
    touch: false,
    debugLabel: theme.debugLabel,
    typography: theme.typography,
    toasterStyle: theme.toasterStyle,
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

/// 桌面端的滚动条行为：常驻、更宽、与主题色一致。
///
/// Flutter 默认在桌面端使用 `Scrollbar` 的「悬停才显形」窄条，鼠标用户
/// 看不到自己在一篇长内容里的位置。桌面工作台的通行做法是常驻细条——
/// 它同时是位置指示（拇指长度 = 可视比例），不是装饰。
///
/// 「桌面」要同时满足**平台是桌面**和**窗口至少平板宽**。只看平台不够：
/// Flutter web 的 OS 探测只读 `navigator.platform` / UA，鸿蒙壳（ArkWeb）的
/// platform 以 `Linux` 开头、UA 里又没有 `Android`，因此被判成 Linux 桌面
/// （`ui_web/browser_detection.dart`）——手机形态的壳上于是多出一条常驻的
/// 粗黑滚动条（2026-11-04 在模拟器复现）。原生桌面的最小窗口是 960×640
/// （`window_manager_setup.dart`），短边不会低于 `Breakpoints.mobile`；
/// 手机无论竖屏还是横屏，短边都在 426dp 上下，永远不满足这一条。
class _DesktopScrollBehavior extends MaterialScrollBehavior {
  const _DesktopScrollBehavior();

  bool get _isDesktopPlatform =>
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux;

  bool _shouldDrawScrollbar(BuildContext context) {
    if (!_isDesktopPlatform) return false;
    return MediaQuery.sizeOf(context).shortestSide >= Breakpoints.mobile;
  }

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    if (!_shouldDrawScrollbar(context)) return child;
    final colors = Theme.of(context).colorScheme;
    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thickness: const WidgetStatePropertyAll(10),
        radius: const Radius.circular(999),
        thumbVisibility: const WidgetStatePropertyAll(true),
        thumbColor: WidgetStatePropertyAll(colors.outlineVariant),
        crossAxisMargin: 2,
      ),
      child: Scrollbar(controller: details.controller, child: child),
    );
  }
}
