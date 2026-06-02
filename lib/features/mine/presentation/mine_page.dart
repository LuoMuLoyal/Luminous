import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/constants/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/mine/data/repositories/mock_mine_repository.dart';
import 'package:luminous/features/mine/presentation/providers/mine_dashboard_provider.dart';
import 'package:luminous/features/mine/presentation/widgets/mine_components.dart';
import 'package:luminous/features/mine/presentation/widgets/mine_dashboard_view.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MinePage extends ConsumerWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authSession = ref.watch(authSessionProvider);
    final dashboardAsync = ref.watch(mineDashboardProvider);
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.sizeOf(context).width;
    final typography = width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(Theme.of(context).colorScheme.onSurface)
        : AppTypographyTokens.desktop(Theme.of(context).colorScheme.onSurface);
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return PageScaffoldShell(
      title: l10n.tabMine,
      actions: [
        if (authSession.isAuthenticated)
          MineHeaderActionChip(
            label: l10n.authSignOut,
            icon: Icons.logout_rounded,
            typography: typography,
            surface: surface,
            onTap: authSession.isLoading
                ? null
                : () async {
                    await ref.read(authSessionProvider.notifier).logout();
                    if (!context.mounted) {
                      return;
                    }
                    context.go('/login');
                  },
          ),
        if (width >= AppBreakpoints.desktop)
          MineHeaderActionChip(
            label: l10n.mineHeaderNotifications,
            icon: Icons.notifications_none_rounded,
            typography: typography,
            surface: surface,
            onTap: () => showMineToast(context, l10n.mineHeaderNotifications),
          ),
        MineHeaderActionChip(
          label: l10n.mineHeaderSettings,
          icon: Icons.settings_outlined,
          typography: typography,
          surface: surface,
          onTap: () => context.push('/settings'),
        ),
      ],
      children: [
        if (!authSession.isAuthenticated)
          MineDashboardView(dashboard: MockMineRepository.signedOutDashboard)
        else
          dashboardAsync.when(
            data: (dashboard) => MineDashboardView(dashboard: dashboard),
            loading: () => const MineLoadingView(),
            error: (_, __) => MineErrorView(
              onRetry: () => ref.invalidate(mineDashboardProvider),
            ),
          ),
      ],
    );
  }
}
