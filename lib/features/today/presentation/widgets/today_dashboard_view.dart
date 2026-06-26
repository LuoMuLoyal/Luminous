import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/today/domain/entities/today_dashboard.dart';
import 'package:luminous/features/today/presentation/widgets/today_ai_summary_section.dart';
import 'package:luminous/features/today/presentation/widgets/today_overview_section.dart';
import 'package:luminous/features/today/presentation/widgets/today_priority_section.dart';
import 'package:luminous/features/today/presentation/widgets/today_recommendation_section.dart';
import 'package:luminous/features/today/presentation/widgets/today_todo_section.dart';
import 'package:luminous/features/today/presentation/widgets/today_top_bar.dart';
import 'package:luminous/l10n/app_localizations.dart';

class TodayDashboardView extends StatelessWidget {
  const TodayDashboardView({
    super.key,
    required this.dashboard,
    this.isLoading = false,
    required this.onRefresh,
  });

  final TodayDashboard dashboard;
  final bool isLoading;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AppBreakpoints.desktop;

    final content = isDesktop
        ? _DesktopTodayDashboard(dashboard: dashboard, onRefresh: onRefresh)
        : _MobileTodayDashboard(dashboard: dashboard, onRefresh: onRefresh);

    return AppSkeletonScope(isLoading: isLoading, child: content);
  }
}

class TodayErrorView extends StatelessWidget {
  const TodayErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppStateErrorView(
      title: l10n.todayErrorTitle,
      description: l10n.todayErrorDescription,
      icon: Icons.question_mark_rounded,
      actionLabel: l10n.todayRetryAction,
      onAction: onRetry,
      tone: AppStateTone.danger,
    );
  }
}

class TodayEmptyView extends StatelessWidget {
  const TodayEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: AppStateMessageView(
          title: l10n.todayEmptyTitle,
          description: l10n.todayEmptyDescription,
          icon: Icons.medical_information_outlined,
          actionLabel: l10n.todayEmptyAction,
          onAction: () {},
          tone: AppStateTone.success,
        ),
      ),
    );
  }
}

class _MobileTodayDashboard extends StatelessWidget {
  const _MobileTodayDashboard({
    required this.dashboard,
    required this.onRefresh,
  });

  final TodayDashboard dashboard;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[
      TodayTopBar(moment: dashboard.user.moment),
      TodayOverviewSection(dashboard: dashboard),
      TodayAiSummarySection(dashboard: dashboard),
      TodayPrioritySection(dashboard: dashboard),
      TodayRecommendationSection(dashboard: dashboard),
      TodayTodoSection(dashboard: dashboard),
    ];

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        key: const PageStorageKey<String>('today-dashboard-scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacingTokens.md,
          AppSpacingTokens.md,
          AppSpacingTokens.md,
          AppSpacingTokens.x5l + AppSpacingTokens.xs,
        ),
        itemBuilder: (context, index) => sections[index],
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSpacingTokens.lg),
        itemCount: sections.length,
      ),
    );
  }
}

class _DesktopTodayDashboard extends StatelessWidget {
  const _DesktopTodayDashboard({
    required this.dashboard,
    required this.onRefresh,
  });

  final TodayDashboard dashboard;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        key: const PageStorageKey<String>('today-dashboard-desktop-scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacingTokens.xl,
          AppSpacingTokens.xl,
          AppSpacingTokens.xl,
          AppSpacingTokens.xl,
        ),
        children: [
          TodayTopBar(moment: dashboard.user.moment),
          const SizedBox(height: AppSpacingTokens.lg),
          TodayOverviewSection(dashboard: dashboard),
          const SizedBox(height: AppSpacingTokens.lg),
          TodayAiSummarySection(dashboard: dashboard),
          const SizedBox(height: AppSpacingTokens.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    TodayPrioritySection(dashboard: dashboard),
                    const SizedBox(height: AppSpacingTokens.lg),
                    TodayTodoSection(dashboard: dashboard),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacingTokens.lg),
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    TodayRecommendationSection(
                      dashboard: dashboard,
                      compact: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
