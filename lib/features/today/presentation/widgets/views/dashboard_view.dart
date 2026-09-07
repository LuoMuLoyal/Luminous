import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/presentation/widgets/views/desktop_dashboard.dart';
import 'package:luminous/features/today/presentation/widgets/views/mobile_dashboard.dart';
import 'package:luminous/l10n/app_localizations.dart';

class TodayDashboardView extends ConsumerWidget {
  const TodayDashboardView({
    super.key,
    required this.dashboard,
    this.isLoading = false,
    this.isPreview = false,
    this.onSignIn,
    required this.onRefresh,
  });

  final TodayDashboard dashboard;
  final bool isLoading;
  final bool isPreview;
  final VoidCallback? onSignIn;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= Breakpoints.desktop;

    final content = isDesktop
        ? DesktopTodayDashboard(
            dashboard: dashboard,
            isPreview: isPreview,
            onSignIn: onSignIn,
            onRefresh: onRefresh,
          )
        : MobileTodayDashboard(
            dashboard: dashboard,
            isPreview: isPreview,
            onSignIn: onSignIn,
            onRefresh: onRefresh,
          );

    return SkeletonScope(isLoading: isLoading, child: content);
  }
}

class TodayErrorView extends StatelessWidget {
  const TodayErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return StateErrorView(
      title: l10n.todayErrorTitle,
      description: l10n.todayErrorDescription,
      icon: SemanticIcons.actionHelp,
      actionLabel: l10n.todayRetryAction,
      onAction: onRetry,
      tone: StateTone.danger,
    );
  }
}
