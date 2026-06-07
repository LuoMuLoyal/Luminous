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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authSession = ref.watch(authSessionProvider);
    final dashboardAsync = ref.watch(mineDashboardProvider);
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    Widget body;
    if (!authSession.isAuthenticated) {
      body = MineDashboardView(
        dashboard: MockMineRepository.signedOutDashboard,
      );
    } else {
      body = dashboardAsync.when(
        data: (dashboard) => MineDashboardView(dashboard: dashboard),
        loading: () => const MineLoadingView(),
        error: (_, __) =>
            MineErrorView(onRetry: () => ref.invalidate(mineDashboardProvider)),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(color: surface.canvasSoft),
      child: SafeArea(
        bottom: false,
        child: ListView(
          key: const PageStorageKey<String>('mine-mobile-scroll'),
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
    );
  }
}

class MineLoadingView extends StatelessWidget {
  const MineLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppInlineSkeleton(
      spacing: AppSpacingTokens.md,
      children: [
        AppInlineSkeletonSection(
          children: [
            Row(
              children: [
                AppInlineSkeletonCircle(size: 72),
                SizedBox(width: AppSpacingTokens.md),
                Expanded(
                  child: AppInlineSkeleton(
                    children: [
                      AppInlineSkeletonBlock(height: 22, widthFactor: 0.5),
                      AppInlineSkeletonBlock(height: 18, widthFactor: 0.72),
                      AppInlineSkeletonBlock(height: 12, widthFactor: 0.62),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        AppInlineSkeletonSection(
          children: [
            AppInlineSkeletonBlock(height: 92),
            AppInlineSkeletonBlock(height: 92),
          ],
        ),
        AppInlineSkeletonSection(
          children: [
            AppInlineSkeletonBlock(height: 18, widthFactor: 0.36),
            AppInlineSkeletonBlock(height: 220),
          ],
        ),
      ],
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
