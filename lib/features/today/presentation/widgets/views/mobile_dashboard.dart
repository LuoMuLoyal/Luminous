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
import 'package:luminous/features/today/presentation/widgets/views/health_event_section.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MobileTodayDashboard extends StatelessWidget {
  const MobileTodayDashboard({
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
          style: context.theme.typography.body.sm.copyWith(
            color: SemanticColor.neutral.solid(context),
          ),
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
        child: HealthEventSection(isPreview: isPreview, onRefresh: onRefresh),
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
