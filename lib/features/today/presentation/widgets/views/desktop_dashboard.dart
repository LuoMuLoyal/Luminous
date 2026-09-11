import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/feedback/page_state.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/presentation/widgets/sections/observation.dart';
import 'package:luminous/features/today/presentation/widgets/sections/quick_actions.dart';
import 'package:luminous/features/today/presentation/widgets/sections/suggestion.dart';
import 'package:luminous/features/today/presentation/widgets/sections/summary.dart';
import 'package:luminous/features/today/presentation/widgets/shared/top_bar.dart';
import 'package:luminous/features/today/presentation/widgets/shared/view_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

class DesktopTodayDashboard extends StatelessWidget {
  const DesktopTodayDashboard({
    super.key,
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

    // Fixed list — always same item count to keep indices stable.
    // The banner slot uses Padding so SizedBox.shrink is truly zero-height.
    final items = <Widget>[
      // 问候语从 Header 拆分，放到内容区
      Text(
        greetingSubtitle(l10n, dashboard),
        style: context.theme.typography.body.sm.copyWith(
          color: SemanticColor.neutral.solid(context),
        ),
      ),
      // Preview banner slot — SizedBox.shrink has zero height when hidden
      if (isPreview)
        Padding(
          padding: const EdgeInsets.only(top: Spacing.md, bottom: Spacing.xl2),
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
                const SizedBox(height: Spacing.xl2),
                TodaySummarySection(dashboard: dashboard),
              ],
            ),
          ),
          const SizedBox(width: Spacing.xl2),
          Expanded(
            flex: 5,
            child: Column(
              children: [
                const TodaySecondarySuggestionsSection(
                  key: Key('today-secondary-suggestions-card'),
                ),
                const SizedBox(height: Spacing.xl2),
                TodayObservationSection(dashboard: dashboard),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: Spacing.xl2),
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
                  padding: const EdgeInsets.only(bottom: Spacing.xl6),
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
