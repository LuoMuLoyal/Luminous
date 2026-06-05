import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/constants/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/features/more/data/repositories/mock_more_repository.dart';
import 'package:luminous/features/more/presentation/providers/more_dashboard_provider.dart';
import 'package:luminous/features/more/presentation/widgets/more_components.dart';
import 'package:luminous/features/more/presentation/widgets/more_dashboard_view.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(moreDashboardProvider);
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.sizeOf(context).width;
    final typography = width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(Theme.of(context).colorScheme.onSurface)
        : AppTypographyTokens.desktop(Theme.of(context).colorScheme.onSurface);
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return PageScaffoldShell(
      title: l10n.tabMore,
      description: l10n.morePageDescription,
      actions: [
        if (width >= AppBreakpoints.desktop)
          MoreHeaderActionChip(
            label: l10n.moreHeaderNotifications,
            icon: Icons.notifications_none_rounded,
            typography: typography,
            surface: surface,
            onTap: () => showMoreToast(context, l10n.moreHeaderNotifications),
          ),
        MoreHeaderActionChip(
          label: l10n.moreHeaderSupport,
          icon: Icons.help_outline_rounded,
          typography: typography,
          surface: surface,
          onTap: () => showMoreToast(context, l10n.moreHeaderSupport),
          showLabel: width >= AppBreakpoints.desktop,
        ),
      ],
      children: [
        dashboardAsync.when(
          data: (dashboard) => MoreDashboardView(dashboard: dashboard),
          loading: () =>
              const MoreDashboardView(dashboard: MockMoreRepository.dashboard),
          error: (_, __) => MoreErrorView(
            onRetry: () => ref.invalidate(moreDashboardProvider),
          ),
        ),
      ],
    );
  }
}
