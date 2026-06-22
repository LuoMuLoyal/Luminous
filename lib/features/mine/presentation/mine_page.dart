import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/mine/data/repositories/mock_mine_repository.dart';
import 'package:luminous/features/mine/presentation/providers/mine_dashboard_provider.dart';
import 'package:luminous/features/mine/presentation/widgets/mine_components.dart';
import 'package:luminous/features/mine/presentation/widgets/mine_dashboard_view.dart';
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
    final authSession = ref.watch(authSessionProvider);
    final dashboardAsync = ref.watch(mineDashboardProvider);
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    final body = dashboardAsync.when(
      data: (dashboard) => MineDashboardView(dashboard: dashboard),
      loading: () => MineDashboardView(
        dashboard: MockMineRepository.loadingDashboard(
          displayName: authSession.user?.nickname?.trim().isNotEmpty == true
              ? authSession.user!.nickname!.trim()
              : authSession.user?.email ?? authSession.user?.id,
          email: authSession.user?.email ?? '',
        ),
        isLoading: true,
      ),
      error: (_, __) =>
          MineErrorView(onRetry: () => ref.invalidate(mineDashboardProvider)),
    );

    return DecoratedBox(
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
                onNotificationsTap: () => showMineToast(
                  context,
                  AppLocalizations.of(context)!.mineHeaderNotifications,
                ),
                onSettingsTap: () => context.push('/settings'),
              ),
              const SizedBox(height: AppSpacingTokens.md),
              body,
            ],
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
