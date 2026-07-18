import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';

/// Skeleton placeholder for the Today tab loading state.
///
/// Mirrors the real dashboard section order so the loading-to-loaded
/// transition doesn't cause a large layout jump:
///
/// **Mobile:** TopBar → RecordHint → PrimarySuggestion → SecondarySuggestions
/// → Summary → Observation → QuickActions
///
/// **Desktop:** TopBar → RecordHint →
/// Row[左7: PrimarySuggestion+Summary | 右5: SecondarySuggestions+Observation]
/// → QuickActions
class TodaySkeletonView extends StatelessWidget {
  const TodaySkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= Breakpoints.desktop;
    final horizontalPadding = isDesktop ? Spacing.level6 : Spacing.level4;
    final verticalPadding = isDesktop ? Spacing.level6 : Spacing.level4;

    return AppSkeletonShimmer(
      child: ListView(
        key: const PageStorageKey<String>('today-dashboard-skeleton-scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          verticalPadding,
          horizontalPadding,
          Spacing.level10 + Spacing.level2,
        ),
        children: [
          _TopBarPlaceholder(isDesktop: isDesktop),
          SizedBox(height: isDesktop ? Spacing.level6 : Spacing.level5),
          _RecordHintPlaceholder(),
          SizedBox(height: isDesktop ? Spacing.level6 : Spacing.level5),
          if (isDesktop) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PrimarySuggestionPlaceholder(),
                      const SizedBox(height: Spacing.level6),
                      _SummaryPlaceholder(),
                    ],
                  ),
                ),
                const SizedBox(width: Spacing.level6),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SecondarySuggestionsPlaceholder(),
                      const SizedBox(height: Spacing.level6),
                      _ObservationPlaceholder(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.level6),
          ] else ...[
            _PrimarySuggestionPlaceholder(),
            const SizedBox(height: Spacing.level5),
            _SecondarySuggestionsPlaceholder(),
            const SizedBox(height: Spacing.level5),
            _SummaryPlaceholder(),
            const SizedBox(height: Spacing.level5),
            _ObservationPlaceholder(),
            const SizedBox(height: Spacing.level5),
          ],
          _QuickActionsPlaceholder(),
        ],
      ),
    );
  }
}

class _TopBarPlaceholder extends StatelessWidget {
  const _TopBarPlaceholder({required this.isDesktop});

  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppInlineSkeletonBlock(
                height: isDesktop ? 48 : 40,
                widthFactor: 0.55,
              ),
              const SizedBox(height: Spacing.level2),
              const AppInlineSkeletonBlock(height: 18, widthFactor: 0.64),
            ],
          ),
        ),
        const SizedBox(width: Spacing.level4),
        AppInlineSkeletonCircle(size: isDesktop ? 44 : 40),
        const SizedBox(width: Spacing.level2),
        AppInlineSkeletonCircle(size: isDesktop ? 44 : 40),
      ],
    );
  }
}

class _RecordHintPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const AppInlineSkeletonSection(
      children: [
        Row(
          children: [
            AppInlineSkeletonCircle(size: 32),
            SizedBox(width: Spacing.level3),
            Expanded(
              child: AppInlineSkeletonBlock(height: 16, widthFactor: 0.7),
            ),
            SizedBox(width: Spacing.level3),
            AppInlineSkeletonBlock(height: 14, width: 64),
          ],
        ),
      ],
    );
  }
}

class _PrimarySuggestionPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const AppInlineSkeletonSection(
      children: [
        Row(
          children: [
            AppInlineSkeletonCircle(size: 40),
            SizedBox(width: Spacing.level3),
            Expanded(child: AppInlineSkeletonBlock(height: 18)),
            SizedBox(width: Spacing.level3),
            AppInlineSkeletonBlock(height: 14, width: 72),
          ],
        ),
        SizedBox(height: Spacing.level4),
        AppInlineSkeletonBlock(height: 16, widthFactor: 0.92),
        SizedBox(height: Spacing.level2),
        AppInlineSkeletonBlock(height: 16, widthFactor: 0.78),
        SizedBox(height: Spacing.level2),
        AppInlineSkeletonBlock(height: 16, widthFactor: 0.84),
        SizedBox(height: Spacing.level4),
        Row(
          children: [
            AppInlineSkeletonBlock(
              height: 32,
              width: 80,
              radius: RadiusTokens.levelFull,
            ),
            SizedBox(width: Spacing.level3),
            AppInlineSkeletonBlock(
              height: 32,
              width: 80,
              radius: RadiusTokens.levelFull,
            ),
          ],
        ),
      ],
    );
  }
}

class _SecondarySuggestionsPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppInlineSkeletonSection(
      children: [
        const AppInlineSkeletonBlock(height: 18, widthFactor: 0.4),
        const SizedBox(height: Spacing.level4),
        for (var i = 0; i < 2; i += 1) ...[
          if (i > 0) const SizedBox(height: Spacing.level4),
          const Row(
            children: [
              AppInlineSkeletonCircle(size: 32),
              SizedBox(width: Spacing.level3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppInlineSkeletonBlock(height: 16, widthFactor: 0.7),
                    SizedBox(height: Spacing.level2),
                    AppInlineSkeletonBlock(height: 14, widthFactor: 0.5),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SummaryPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const AppInlineSkeletonSection(
      children: [
        AppInlineSkeletonBlock(height: 18, widthFactor: 0.35),
        SizedBox(height: Spacing.level4),
        Row(
          children: [
            Expanded(
              child: AppInlineSkeletonBlock(
                height: 56,
                radius: RadiusTokens.level4,
              ),
            ),
            SizedBox(width: Spacing.level3),
            Expanded(
              child: AppInlineSkeletonBlock(
                height: 56,
                radius: RadiusTokens.level4,
              ),
            ),
            SizedBox(width: Spacing.level3),
            Expanded(
              child: AppInlineSkeletonBlock(
                height: 56,
                radius: RadiusTokens.level4,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ObservationPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppInlineSkeletonSection(
      children: [
        const AppInlineSkeletonBlock(height: 18, widthFactor: 0.35),
        const SizedBox(height: Spacing.level4),
        for (var i = 0; i < 2; i += 1) ...[
          if (i > 0) const SizedBox(height: Spacing.level4),
          const Row(
            children: [
              AppInlineSkeletonCircle(size: 32),
              SizedBox(width: Spacing.level3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppInlineSkeletonBlock(height: 16, widthFactor: 0.65),
                    SizedBox(height: Spacing.level2),
                    AppInlineSkeletonBlock(height: 14, widthFactor: 0.5),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _QuickActionsPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 4; i += 1) ...[
          if (i > 0) const SizedBox(width: Spacing.level3),
          const Expanded(
            child: AppInlineSkeletonBlock(
              height: 80,
              radius: RadiusTokens.level4,
            ),
          ),
        ],
      ],
    );
  }
}
