import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/mine/presentation/providers/mine_dashboard_provider.dart';
import 'package:luminous/features/mine/presentation/widgets/views/mine_dashboard_view.dart';
import 'package:luminous/features/mine/presentation/widgets/views/mine_skeleton_view.dart';
import 'package:luminous/features/shell/presentation/shell_deferred_content.dart';
import 'package:luminous/features/mine/presentation/widgets/mine_sections.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MinePage extends ConsumerWidget {
  const MinePage({super.key});

  Future<void> _refreshDashboard(WidgetRef ref) async {
    ref.invalidate(mineDashboardProvider);
    await ref.read(mineDashboardProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(mineDashboardProvider);
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AppBreakpoints.desktop;

    final body = dashboardAsync.when(
      data: (dashboard) => MineDashboardView(dashboard: dashboard),
      loading: () => const MineSkeletonView(),
      error: (_, __) =>
          MineErrorView(onRetry: () => ref.invalidate(mineDashboardProvider)),
    );

    return ShellDeferredContent(
      child: isDesktop
          ? _MineDesktopShell(
              onRefresh: () => _refreshDashboard(ref),
              topBar: MineTopBar(
                onNotificationsTap: () => context.push('/notifications'),
                onSettingsTap: () => context.push('/settings'),
              ),
              child: body,
            )
          : DecoratedBox(
              decoration: BoxDecoration(color: surface.canvasSoft),
              child: SafeArea(
                bottom: false,
                child: RefreshIndicator(
                  onRefresh: () => _refreshDashboard(ref),
                  child: ListView(
                    key: const PageStorageKey<String>('mine-mobile-scroll'),
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacingTokens.md,
                      AppSpacingTokens.md,
                      AppSpacingTokens.md,
                      AppSpacingTokens.x5l,
                    ),
                    children: [
                      MineTopBar(
                        onNotificationsTap: () =>
                            context.push('/notifications'),
                        onSettingsTap: () => context.push('/settings'),
                      ),
                      const SizedBox(height: AppSpacingTokens.md),
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
      icon: Icons.person_search_rounded,
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
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return DecoratedBox(
      decoration: BoxDecoration(color: surface.canvasSoft),
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            key: const PageStorageKey<String>('mine-desktop-scroll'),
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacingTokens.xl,
              AppSpacingTokens.xl,
              AppSpacingTokens.xl,
              AppSpacingTokens.xl,
            ),
            children: [
              topBar,
              const SizedBox(height: AppSpacingTokens.lg),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
