import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';

/// Skeleton placeholder for the Review tab loading state.
///
/// Avoids rendering fake metrics, dates, or AI summary text.
class ReviewSkeletonView extends StatelessWidget {
  const ReviewSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= Breakpoints.desktop;

    return SkeletonShimmer(
      child: isDesktop
          ? const _DesktopReviewSkeleton()
          : const _MobileReviewSkeleton(),
    );
  }
}

class _MobileReviewSkeleton extends StatelessWidget {
  const _MobileReviewSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ReadinessPlaceholder(),
        SizedBox(height: Spacing.level4),
        _MetricsGridPlaceholder(),
        SizedBox(height: Spacing.level4),
        _TrendPlaceholder(),
        SizedBox(height: Spacing.level4),
        _FindingsPlaceholder(),
        SizedBox(height: Spacing.level4),
        _AiSummaryPlaceholder(),
        SizedBox(height: Spacing.level4),
        _ExportPlaceholder(),
        SizedBox(height: Spacing.level4),
        _PatternsPlaceholder(),
        SizedBox(height: Spacing.level4),
        _ReferenceNoticePlaceholder(),
      ],
    );
  }
}

class _DesktopReviewSkeleton extends StatelessWidget {
  const _DesktopReviewSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ReadinessPlaceholder(),
        SizedBox(height: Spacing.level5),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TrendPlaceholder(),
                  SizedBox(height: Spacing.level5),
                  _FindingsPlaceholder(),
                ],
              ),
            ),
            SizedBox(width: Spacing.level5),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MetricsGridPlaceholder(),
                  SizedBox(height: Spacing.level5),
                  _ExportPlaceholder(),
                  SizedBox(height: Spacing.level5),
                  _AiSummaryPlaceholder(),
                  SizedBox(height: Spacing.level5),
                  _PatternsPlaceholder(),
                  SizedBox(height: Spacing.level5),
                  _ReferenceNoticePlaceholder(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReadinessPlaceholder extends StatelessWidget {
  const _ReadinessPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const InlineSkeletonSection(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InlineSkeletonBlock(height: 20, widthFactor: 0.45),
            InlineSkeletonCircle(size: 24),
          ],
        ),
        SizedBox(height: Spacing.level4),
        InlineSkeletonBlock(height: 14, widthFactor: 0.6),
      ],
    );
  }
}

class _MetricsGridPlaceholder extends StatelessWidget {
  const _MetricsGridPlaceholder();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: Spacing.level3,
      mainAxisSpacing: Spacing.level3,
      childAspectRatio: 1.55,
      children: List.generate(
        4,
        (_) =>
            const InlineSkeletonBlock(height: 96, radius: RadiusTokens.level4),
      ),
    );
  }
}

class _TrendPlaceholder extends StatelessWidget {
  const _TrendPlaceholder();

  @override
  Widget build(BuildContext context) {
    return InlineSkeletonSection(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InlineSkeletonBlock(height: 18, widthFactor: 0.35),
            InlineSkeletonBlock(height: 14, width: 72),
          ],
        ),
        const SizedBox(height: Spacing.level4),
        const InlineSkeletonBlock(height: 160),
        const SizedBox(height: Spacing.level3),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            4,
            (_) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: Spacing.level2),
              child: InlineSkeletonBlock(
                height: 8,
                width: 24,
                radius: RadiusTokens.levelFull,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FindingsPlaceholder extends StatelessWidget {
  const _FindingsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return InlineSkeletonSection(
      children: [
        const InlineSkeletonBlock(height: 18, widthFactor: 0.4),
        const SizedBox(height: Spacing.level4),
        for (var i = 0; i < 3; i += 1) ...[
          if (i > 0) const SizedBox(height: Spacing.level4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const InlineSkeletonCircle(size: 28),
              const SizedBox(width: Spacing.level3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const InlineSkeletonBlock(height: 16, widthFactor: 0.7),
                    const SizedBox(height: Spacing.level2),
                    InlineSkeletonBlock(
                      height: 14,
                      widthFactor: i == 2 ? 0.45 : 0.85,
                    ),
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

class _AiSummaryPlaceholder extends StatelessWidget {
  const _AiSummaryPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const InlineSkeletonSection(
      children: [
        Row(
          children: [
            InlineSkeletonCircle(size: 32),
            SizedBox(width: Spacing.level3),
            Expanded(child: InlineSkeletonBlock(height: 18)),
          ],
        ),
        SizedBox(height: Spacing.level4),
        InlineSkeletonBlock(height: 16, widthFactor: 0.92),
        SizedBox(height: Spacing.level2),
        InlineSkeletonBlock(height: 16, widthFactor: 0.84),
        SizedBox(height: Spacing.level2),
        InlineSkeletonBlock(height: 16, widthFactor: 0.78),
        SizedBox(height: Spacing.level3),
        InlineSkeletonBlock(
          height: 36,
          widthFactor: 0.5,
          radius: RadiusTokens.levelFull,
        ),
      ],
    );
  }
}

class _ExportPlaceholder extends StatelessWidget {
  const _ExportPlaceholder();

  @override
  Widget build(BuildContext context) {
    return InlineSkeletonSection(
      children: [
        const InlineSkeletonBlock(height: 18, widthFactor: 0.35),
        const SizedBox(height: Spacing.level4),
        Row(
          children: [
            for (var i = 0; i < 3; i += 1) ...[
              if (i > 0) const SizedBox(width: Spacing.level3),
              const Expanded(
                child: InlineSkeletonBlock(
                  height: 80,
                  radius: RadiusTokens.level4,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _PatternsPlaceholder extends StatelessWidget {
  const _PatternsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return InlineSkeletonSection(
      children: [
        const InlineSkeletonBlock(height: 18, widthFactor: 0.4),
        const SizedBox(height: Spacing.level4),
        for (var i = 0; i < 2; i += 1) ...[
          if (i > 0) const SizedBox(height: Spacing.level4),
          const Row(
            children: [
              InlineSkeletonCircle(size: 32),
              SizedBox(width: Spacing.level3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InlineSkeletonBlock(height: 16, widthFactor: 0.65),
                    SizedBox(height: Spacing.level2),
                    InlineSkeletonBlock(height: 14, widthFactor: 0.5),
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

class _ReferenceNoticePlaceholder extends StatelessWidget {
  const _ReferenceNoticePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const InlineSkeletonSection(
      children: [
        InlineSkeletonBlock(height: 14, widthFactor: 0.92),
        SizedBox(height: Spacing.level2),
        InlineSkeletonBlock(height: 14, widthFactor: 0.78),
      ],
    );
  }
}
