import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/health_event/presentation/providers/active_event.dart';
import 'package:luminous/features/shell/presentation/deferred_content.dart';
import 'package:luminous/features/shell/presentation/desktop_tab_shell.dart';
import 'package:luminous/features/today/presentation/providers/dashboard.dart';
import 'package:luminous/features/today/presentation/providers/suggestion.dart';
import 'package:luminous/features/today/presentation/widgets/views/dashboard_view.dart';
import 'package:luminous/features/today/presentation/widgets/views/skeleton_view.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Today page.
class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  Future<void> _refreshAll(BuildContext context, WidgetRef ref) async {
    ref.invalidate(todayDashboardProvider);
    ref.invalidate(todaySuggestionProvider);
    final session = ref.read(authSessionProvider);
    final isMobile = MediaQuery.sizeOf(context).width < Breakpoints.desktop;
    if (session.canAccessProtectedData && isMobile) {
      ref.invalidate(activeHealthEventProvider);
    }
    try {
      final futures = <Future<Object?>>[
        ref.read(todayDashboardProvider.future),
        ref.read(todaySuggestionProvider.future),
      ];
      if (session.canAccessProtectedData && isMobile) {
        futures.add(ref.read(activeHealthEventProvider.future));
      }
      await Future.wait(futures);
    } catch (e) {
      appTalker.warning('TodayPage: refreshAll failed: $e');
      if (!context.mounted) return;
      final l10n = AppLocalizations.of(context)!;
      await Toast.show(context, l10n.todayRefreshErrorToast);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= Breakpoints.desktop;
    final l10n = AppLocalizations.of(context)!;

    // Always watch the provider — when signed out it returns preview data.
    final dashboardAsync = ref.watch(todayDashboardProvider);

    final pageState = resolvePageViewState(
      session: session,
      data: dashboardAsync,
    );

    final content = PageStateSwitch(
      state: pageState,
      loadingBuilder: () => const TodaySkeletonView(),
      fatalErrorBuilder: (error) =>
          TodayErrorView(onRetry: () => ref.invalidate(todayDashboardProvider)),
      readyBuilder: (dashboard, isPreview) => TodayDashboardView(
        dashboard: dashboard,
        isPreview: isPreview,
        onSignIn: isPreview
            ? () => context.push(loginRouteForCurrentLocation(context))
            : null,
        onRefresh: () => _refreshAll(context, ref),
      ),
    );

    return ShellDeferredContent(
      child: isDesktop
          ? DesktopTabShell(
              title: l10n.tabToday,
              scrollable: false,
              // Today content includes its own TodayTopBar with title +
              // assistant/notification buttons. Skip the shell header to
              // avoid a double title on desktop.
              showHeader: false,
              child: content,
            )
          : SafeArea(bottom: false, child: content),
    );
  }
}
