import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/presentation/widgets/sections/observation.dart';
import 'package:luminous/features/today/presentation/widgets/sections/quick_actions.dart';
import 'package:luminous/features/today/presentation/widgets/sections/suggestion.dart';
import 'package:luminous/features/today/presentation/widgets/sections/summary.dart';
import 'package:luminous/features/today/presentation/widgets/shared/top_bar.dart';
import 'package:luminous/features/today/presentation/widgets/shared/view_models.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    // Each section carries its own bottom spacing so that the
    // conditional banner slot (SignInHintBanner or SizedBox.shrink)
    // doesn't leave an unwanted gap when hidden.
    final sections = <Widget>[
      // Preview banner slot — always present to keep list indices stable.
      // SizedBox.shrink has zero height, so no gap when hidden.
      if (isPreview)
        Padding(
          padding: const EdgeInsets.only(bottom: Spacing.level5),
          child: SignInHintBanner(
            onSignIn: onSignIn,
            message: l10n.todayPreviewBannerMessage,
          ),
        )
      else
        const SizedBox.shrink(),
      // 问候语从 Header 拆分，放到内容区
      Padding(
        padding: const EdgeInsets.only(bottom: Spacing.level5),
        child: Text(
          greetingSubtitle(l10n, dashboard),
          style: TypographyToken.level4
              .body(context)
              .copyWith(color: colors.mutedForeground),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: Spacing.level5),
        child: TodayPrimarySuggestionSection(dashboard: dashboard),
      ),
      const Padding(
        padding: EdgeInsets.only(bottom: Spacing.level5),
        child: TodaySecondarySuggestionsSection(
          key: Key('today-secondary-suggestions-card'),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: Spacing.level5),
        child: TodaySummarySection(dashboard: dashboard),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: Spacing.level5),
        child: TodayObservationSection(dashboard: dashboard),
      ),
      TodayQuickActionsSection(dashboard: dashboard),
    ];

    return Column(
      children: [
        const TodayTopBar(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: CustomScrollView(
              key: const PageStorageKey<String>('today-dashboard-scroll'),
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    Spacing.level4,
                    Spacing.level4,
                    Spacing.level4,
                    Spacing.level10 + MediaQuery.paddingOf(context).bottom,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate.fixed(sections),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    // Fixed list — always same item count to keep indices stable.
    // The banner slot uses Padding so SizedBox.shrink is truly zero-height.
    final items = <Widget>[
      // 问候语从 Header 拆分，放到内容区
      Text(
        greetingSubtitle(l10n, dashboard),
        style: TypographyToken.level4
            .body(context)
            .copyWith(color: colors.mutedForeground),
      ),
      // Preview banner slot — SizedBox.shrink has zero height when hidden
      if (isPreview)
        Padding(
          padding: const EdgeInsets.only(
            top: Spacing.level3,
            bottom: Spacing.level6,
          ),
          child: SignInHintBanner(
            onSignIn: onSignIn,
            message: l10n.todayPreviewBannerMessage,
          ),
        )
      else
        const SizedBox.shrink(),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
            child: Column(
              children: [
                TodayPrimarySuggestionSection(dashboard: dashboard),
                const SizedBox(height: Spacing.level6),
                TodaySummarySection(dashboard: dashboard),
              ],
            ),
          ),
          const SizedBox(width: Spacing.level6),
          Expanded(
            flex: 5,
            child: Column(
              children: [
                const TodaySecondarySuggestionsSection(
                  key: Key('today-secondary-suggestions-card'),
                ),
                const SizedBox(height: Spacing.level6),
                TodayObservationSection(dashboard: dashboard),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: Spacing.level6),
      TodayQuickActionsSection(dashboard: dashboard),
    ];

    return Column(
      children: [
        const TodayTopBar(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: CustomScrollView(
              key: const PageStorageKey<String>(
                'today-dashboard-desktop-scroll',
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  // Horizontal padding is provided by DesktopTabShell's
                  // content area. Only add bottom padding for nav bar.
                  padding: const EdgeInsets.only(bottom: Spacing.level10),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate.fixed(items),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
