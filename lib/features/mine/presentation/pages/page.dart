import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/auth/presentation/providers/session/session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/mine/domain/entities/dashboard.dart';
import 'package:luminous/features/mine/presentation/providers/dashboard.dart';
import 'package:luminous/features/mine/presentation/widgets/views/dashboard_view.dart';
import 'package:luminous/features/mine/presentation/widgets/views/skeleton_view.dart';
import 'package:luminous/features/shell/presentation/deferred_content.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/sections.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MinePage extends ConsumerWidget {
  const MinePage({super.key});

  Future<void> _refreshDashboard(WidgetRef ref) async {
    ref.invalidate(mineDashboardProvider);
    await ref.read(mineDashboardProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= Breakpoints.desktop;

    // Always watch the provider — when signed out it returns preview data.
    final dashboardAsync = ref.watch(mineDashboardProvider);

    final pageState = resolvePageViewState<MineDashboard>(
      session: session,
      data: dashboardAsync,
    );

    Widget body = PageStateSwitch<MineDashboard>(
      state: pageState,
      loadingBuilder: () => const MineSkeletonView(),
      fatalErrorBuilder: (error) =>
          MineErrorView(onRetry: () => ref.invalidate(mineDashboardProvider)),
      readyBuilder: (dashboard, isPreview) {
        final content = MineDashboardView(dashboard: dashboard);
        if (!isPreview) return content;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SignInHintBanner(
              onSignIn: () =>
                  context.push(loginRouteForCurrentLocation(context)),
            ),
            const SizedBox(height: Spacing.level4),
            content,
          ],
        );
      },
    );

    return ShellDeferredContent(
      child: isDesktop
          ? _MineDesktopShell(
              onRefresh: () => _refreshDashboard(ref),
              topBar: MineTopBar(
                onNotificationsTap: () => context.push(AppRoutes.notifications),
                onSettingsTap: () => context.push(AppRoutes.settings),
              ),
              child: body,
            )
          : DecoratedBox(
              decoration: BoxDecoration(
                color: SemanticColor.neutral
                    .muted(context)
                    .withValues(alpha: 0.32),
              ),
              child: SafeArea(
                bottom: false,
                child: RefreshIndicator(
                  onRefresh: () => _refreshDashboard(ref),
                  child: ListView(
                    key: const PageStorageKey<String>('mine-mobile-scroll'),
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      Spacing.level4,
                      Spacing.level4,
                      Spacing.level4,
                      Spacing.level10,
                    ),
                    children: [
                      MineTopBar(
                        onNotificationsTap: () =>
                            context.push(AppRoutes.notifications),
                        onSettingsTap: () => context.push(AppRoutes.settings),
                      ),
                      const SizedBox(height: Spacing.level4),
                      body,
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class MineErrorView extends StatelessWidget {
  const MineErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppStateErrorView(
      title: l10n.mineErrorTitle,
      description: l10n.mineErrorDescription,
      icon: FLucideIcons.searchX,
      actionLabel: l10n.todayRetryAction,
      onAction: onRetry,
      tone: AppStateTone.warning,
    );
  }
}

class _MineDesktopShell extends StatelessWidget {
  const _MineDesktopShell({
    required this.child,
    required this.topBar,
    required this.onRefresh,
  });

  final Widget child;
  final MineTopBar topBar;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SemanticColor.neutral.muted(context).withValues(alpha: 0.32),
      ),
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            key: const PageStorageKey<String>('mine-desktop-scroll'),
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              Spacing.level6,
              Spacing.level6,
              Spacing.level6,
              Spacing.level6,
            ),
            children: [
              topBar,
              const SizedBox(height: Spacing.level5),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
