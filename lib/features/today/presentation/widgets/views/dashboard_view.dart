import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/presentation/widgets/sections/observation_section.dart';
import 'package:luminous/features/today/presentation/widgets/sections/quick_actions_section.dart';
import 'package:luminous/features/today/presentation/widgets/sections/record_hint_section.dart';
import 'package:luminous/features/today/presentation/widgets/sections/summary_section.dart';
import 'package:luminous/features/today/presentation/widgets/sections/suggestion_section.dart';
import 'package:luminous/features/today/presentation/widgets/shared/top_bar.dart';
import 'package:luminous/l10n/app_localizations.dart';

class TodayDashboardView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AppBreakpoints.desktop;

    final content = isDesktop
        ? _DesktopTodayDashboard(
            dashboard: dashboard,
            isPreview: isPreview,
            onSignIn: onSignIn,
            onRefresh: onRefresh,
          )
        : _MobileTodayDashboard(
            dashboard: dashboard,
            isPreview: isPreview,
            onSignIn: onSignIn,
            onRefresh: onRefresh,
          );

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
      icon: FLucideIcons.circleHelp,
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
          icon: FLucideIcons.info,
          actionLabel: l10n.todayEmptyAction,
          onAction: () => context.push(AppRoutes.recordCreate),
          tone: AppStateTone.success,
        ),
      ),
    );
  }
}

class _MobileTodayDashboard extends StatelessWidget {
  const _MobileTodayDashboard({
    required this.dashboard,
    required this.isPreview,
    required this.onSignIn,
    required this.onRefresh,
  });

  final TodayDashboard dashboard;
  final bool isPreview;
  final VoidCallback? onSignIn;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[
      TodayTopBar(dashboard: dashboard),
      if (isPreview)
        SignInHintBanner(
          onSignIn: onSignIn,
          message: AppLocalizations.of(context)!.todayPreviewBannerMessage,
        ),
      TodayRecordHintSection(dashboard: dashboard),
      TodayPrimarySuggestionSection(dashboard: dashboard),
      TodaySecondarySuggestionsSection(dashboard: dashboard),
      TodaySummarySection(dashboard: dashboard),
      TodayObservationSection(dashboard: dashboard),
      TodayQuickActionsSection(dashboard: dashboard),
    ];

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        key: const PageStorageKey<String>('today-dashboard-scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppSpacingTokens.level4,
          AppSpacingTokens.level4,
          AppSpacingTokens.level4,
          AppSpacingTokens.level10 + MediaQuery.paddingOf(context).bottom,
        ),
        itemBuilder: (context, index) => sections[index],
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSpacingTokens.level5),
        itemCount: sections.length,
      ),
    );
  }
}

class _DesktopTodayDashboard extends StatelessWidget {
  const _DesktopTodayDashboard({
    required this.dashboard,
    required this.isPreview,
    required this.onSignIn,
    required this.onRefresh,
  });

  final TodayDashboard dashboard;
  final bool isPreview;
  final VoidCallback? onSignIn;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        key: const PageStorageKey<String>('today-dashboard-desktop-scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacingTokens.level6,
          AppSpacingTokens.level6,
          AppSpacingTokens.level6,
          AppSpacingTokens.level6,
        ),
        children: [
          TodayTopBar(dashboard: dashboard),
          if (isPreview) ...[
            const SizedBox(height: AppSpacingTokens.level3),
            SignInHintBanner(
              onSignIn: onSignIn,
              message: AppLocalizations.of(context)!.todayPreviewBannerMessage,
            ),
          ],
          const SizedBox(height: AppSpacingTokens.level6),
          TodayRecordHintSection(dashboard: dashboard),
          const SizedBox(height: AppSpacingTokens.level6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    TodayPrimarySuggestionSection(dashboard: dashboard),
                    const SizedBox(height: AppSpacingTokens.level6),
                    TodaySummarySection(dashboard: dashboard),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacingTokens.level6),
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    TodaySecondarySuggestionsSection(dashboard: dashboard),
                    const SizedBox(height: AppSpacingTokens.level6),
                    TodayObservationSection(dashboard: dashboard),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacingTokens.level6),
          TodayQuickActionsSection(dashboard: dashboard),
        ],
      ),
    );
  }
}
