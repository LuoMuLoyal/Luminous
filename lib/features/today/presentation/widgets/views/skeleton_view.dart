import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';

/// Skeleton placeholder for the Today tab loading state.
///
/// Uses structural blocks instead of realistic mock data so users cannot
/// confuse loading with loaded content.
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
          _OverviewPlaceholder(isDesktop: isDesktop),
          SizedBox(height: isDesktop ? Spacing.level6 : Spacing.level5),
          _AiSummaryPlaceholder(),
          SizedBox(height: isDesktop ? Spacing.level6 : Spacing.level5),
          _PriorityPlaceholder(),
          SizedBox(height: isDesktop ? Spacing.level6 : Spacing.level5),
          _RecommendationPlaceholder(),
          SizedBox(height: isDesktop ? Spacing.level6 : Spacing.level5),
          _TodoPlaceholder(),
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

class _OverviewPlaceholder extends StatelessWidget {
  const _OverviewPlaceholder({required this.isDesktop});

  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return AppInlineSkeletonSection(
      children: [
        const AppInlineSkeletonBlock(height: 18, widthFactor: 0.4),
        const SizedBox(height: Spacing.level3),
        Row(
          children: [
            for (var i = 0; i < 3; i += 1) ...[
              if (i > 0) const SizedBox(width: Spacing.level3),
              const Expanded(child: AppInlineSkeletonBlock(height: 48)),
            ],
          ],
        ),
      ],
    );
  }
}

class _AiSummaryPlaceholder extends StatelessWidget {
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
      ],
    );
  }
}

class _PriorityPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppInlineSkeletonSection(
      children: [
        const AppInlineSkeletonBlock(height: 18, widthFactor: 0.4),
        const SizedBox(height: Spacing.level4),
        for (var i = 0; i < 3; i += 1) ...[
          if (i > 0) const SizedBox(height: Spacing.level4),
          Row(
            children: [
              const AppInlineSkeletonCircle(size: 40),
              const SizedBox(width: Spacing.level3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppInlineSkeletonBlock(height: 16, widthFactor: 0.6),
                    const SizedBox(height: Spacing.level2),
                    AppInlineSkeletonBlock(
                      height: 14,
                      widthFactor: i == 2 ? 0.5 : 0.8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.level3),
              const AppInlineSkeletonBlock(height: 14, width: 64),
            ],
          ),
        ],
      ],
    );
  }
}

class _RecommendationPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppInlineSkeletonSection(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppInlineSkeletonBlock(height: 18, widthFactor: 0.35),
            AppInlineSkeletonBlock(height: 14, width: 72),
          ],
        ),
        const SizedBox(height: Spacing.level4),
        for (var i = 0; i < 3; i += 1) ...[
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

class _TodoPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppInlineSkeletonSection(
      children: [
        const AppInlineSkeletonBlock(height: 18, widthFactor: 0.3),
        const SizedBox(height: Spacing.level4),
        for (var i = 0; i < 4; i += 1) ...[
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
              SizedBox(width: Spacing.level3),
              AppInlineSkeletonBlock(height: 24, width: 56),
            ],
          ),
        ],
      ],
    );
  }
}
