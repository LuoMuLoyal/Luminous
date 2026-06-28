import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/widgets/app_state_views.dart';

/// Skeleton placeholder for the Report tab loading state.
///
/// Avoids rendering fake scores, metrics, dates, or AI summary text.
class ReportSkeletonView extends StatelessWidget {
  const ReportSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AppBreakpoints.desktop;

    return AppSkeletonShimmer(
      child: isDesktop
          ? const _DesktopReportSkeleton()
          : const _MobileReportSkeleton(),
    );
  }
}

class _MobileReportSkeleton extends StatelessWidget {
  const _MobileReportSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ScoreHeroPlaceholder(),
        SizedBox(height: AppSpacingTokens.md),
        _MetricsGridPlaceholder(),
        SizedBox(height: AppSpacingTokens.md),
        _TrendPlaceholder(),
        SizedBox(height: AppSpacingTokens.md),
        _FindingsPlaceholder(),
        SizedBox(height: AppSpacingTokens.md),
        _AiSummaryPlaceholder(),
        SizedBox(height: AppSpacingTokens.md),
        _ExportPlaceholder(),
        SizedBox(height: AppSpacingTokens.md),
        _PatternsPlaceholder(),
        SizedBox(height: AppSpacingTokens.md),
        _ReferenceNoticePlaceholder(),
      ],
    );
  }
}

class _DesktopReportSkeleton extends StatelessWidget {
  const _DesktopReportSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ScoreHeroPlaceholder(),
        SizedBox(height: AppSpacingTokens.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MetricsGridPlaceholder(),
                  SizedBox(height: AppSpacingTokens.md),
                  _TrendPlaceholder(),
                  SizedBox(height: AppSpacingTokens.md),
                  _FindingsPlaceholder(),
                  SizedBox(height: AppSpacingTokens.md),
                  _PatternsPlaceholder(),
                ],
              ),
            ),
            SizedBox(width: AppSpacingTokens.md),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AiSummaryPlaceholder(),
                  SizedBox(height: AppSpacingTokens.md),
                  _ExportPlaceholder(),
                  SizedBox(height: AppSpacingTokens.md),
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

class _ScoreHeroPlaceholder extends StatelessWidget {
  const _ScoreHeroPlaceholder();

  @override
  Widget build(BuildContext context) {
    return AppInlineSkeletonSection(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppInlineSkeletonBlock(height: 20, widthFactor: 0.45),
            AppInlineSkeletonCircle(size: 24),
          ],
        ),
        const SizedBox(height: AppSpacingTokens.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const AppInlineSkeletonBlock(
              height: 56,
              width: 80,
              radius: AppRadiusTokens.md,
            ),
            const SizedBox(width: AppSpacingTokens.sm),
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacingTokens.xs),
              child: AppInlineSkeletonBlock(height: 18, width: 48),
            ),
            const SizedBox(width: AppSpacingTokens.sm),
            const AppInlineSkeletonBlock(
              height: 24,
              width: 64,
              radius: AppRadiusTokens.pill,
            ),
          ],
        ),
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
      crossAxisSpacing: AppSpacingTokens.sm,
      mainAxisSpacing: AppSpacingTokens.sm,
      childAspectRatio: 1.55,
      children: List.generate(
        4,
        (_) => const AppInlineSkeletonBlock(
          height: 96,
          radius: AppRadiusTokens.lg,
        ),
      ),
    );
  }
}

class _TrendPlaceholder extends StatelessWidget {
  const _TrendPlaceholder();

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
        const SizedBox(height: AppSpacingTokens.md),
        const AppInlineSkeletonBlock(height: 160),
        const SizedBox(height: AppSpacingTokens.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            4,
            (_) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacingTokens.xs),
              child: AppInlineSkeletonBlock(
                height: 8,
                width: 24,
                radius: AppRadiusTokens.pill,
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
    return AppInlineSkeletonSection(
      children: [
        const AppInlineSkeletonBlock(height: 18, widthFactor: 0.4),
        const SizedBox(height: AppSpacingTokens.md),
        for (var i = 0; i < 3; i += 1) ...[
          if (i > 0) const SizedBox(height: AppSpacingTokens.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppInlineSkeletonCircle(size: 28),
              const SizedBox(width: AppSpacingTokens.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppInlineSkeletonBlock(height: 16, widthFactor: 0.7),
                    const SizedBox(height: AppSpacingTokens.xs),
                    AppInlineSkeletonBlock(
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
    return const AppInlineSkeletonSection(
      children: [
        Row(
          children: [
            AppInlineSkeletonCircle(size: 32),
            SizedBox(width: AppSpacingTokens.sm),
            Expanded(child: AppInlineSkeletonBlock(height: 18)),
          ],
        ),
        SizedBox(height: AppSpacingTokens.md),
        AppInlineSkeletonBlock(height: 16, widthFactor: 0.92),
        SizedBox(height: AppSpacingTokens.xs),
        AppInlineSkeletonBlock(height: 16, widthFactor: 0.84),
        SizedBox(height: AppSpacingTokens.xs),
        AppInlineSkeletonBlock(height: 16, widthFactor: 0.78),
        SizedBox(height: AppSpacingTokens.sm),
        AppInlineSkeletonBlock(
          height: 36,
          widthFactor: 0.5,
          radius: AppRadiusTokens.pill,
        ),
      ],
    );
  }
}

class _ExportPlaceholder extends StatelessWidget {
  const _ExportPlaceholder();

  @override
  Widget build(BuildContext context) {
    return AppInlineSkeletonSection(
      children: [
        const AppInlineSkeletonBlock(height: 18, widthFactor: 0.35),
        const SizedBox(height: AppSpacingTokens.md),
        Row(
          children: [
            for (var i = 0; i < 3; i += 1) ...[
              if (i > 0) const SizedBox(width: AppSpacingTokens.sm),
              const Expanded(
                child: AppInlineSkeletonBlock(
                  height: 80,
                  radius: AppRadiusTokens.lg,
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
    return AppInlineSkeletonSection(
      children: [
        const AppInlineSkeletonBlock(height: 18, widthFactor: 0.4),
        const SizedBox(height: AppSpacingTokens.md),
        for (var i = 0; i < 2; i += 1) ...[
          if (i > 0) const SizedBox(height: AppSpacingTokens.md),
          const Row(
            children: [
              AppInlineSkeletonCircle(size: 32),
              SizedBox(width: AppSpacingTokens.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppInlineSkeletonBlock(height: 16, widthFactor: 0.65),
                    SizedBox(height: AppSpacingTokens.xs),
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

class _ReferenceNoticePlaceholder extends StatelessWidget {
  const _ReferenceNoticePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const AppInlineSkeletonSection(
      children: [
        AppInlineSkeletonBlock(height: 14, widthFactor: 0.92),
        SizedBox(height: AppSpacingTokens.xs),
        AppInlineSkeletonBlock(height: 14, widthFactor: 0.78),
      ],
    );
  }
}
