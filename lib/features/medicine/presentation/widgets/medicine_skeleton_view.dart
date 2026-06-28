import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';

/// Skeleton placeholder for the Medicine tab loading state.
///
/// Avoids showing fake medicine names, adherence percentages, or dosage data.
class MedicineSkeletonView extends StatelessWidget {
  const MedicineSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AppBreakpoints.desktop;

    return AppSkeletonShimmer(
      child: isDesktop
          ? const _DesktopMedicineSkeleton()
          : const _MobileMedicineSkeleton(),
    );
  }
}

class _MobileMedicineSkeleton extends StatelessWidget {
  const _MobileMedicineSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DrugBoxPlaceholder(),
        SizedBox(height: AppSpacingTokens.md),
        _SafetyEnginePlaceholder(),
        SizedBox(height: AppSpacingTokens.md),
        _QuickOperationsPlaceholder(),
        SizedBox(height: AppSpacingTokens.md),
        _RecordsPlaceholder(),
        SizedBox(height: AppSpacingTokens.md),
        _ReferenceNoticePlaceholder(),
        SizedBox(height: AppSpacingTokens.md),
        _SafetyTipsPlaceholder(),
      ],
    );
  }
}

class _DesktopMedicineSkeleton extends StatelessWidget {
  const _DesktopMedicineSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DrugBoxPlaceholder(),
              SizedBox(height: AppSpacingTokens.lg),
              _SafetyEnginePlaceholder(),
              SizedBox(height: AppSpacingTokens.lg),
              _RecordsPlaceholder(),
            ],
          ),
        ),
        SizedBox(width: AppSpacingTokens.lg),
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ReferenceNoticePlaceholder(),
              SizedBox(height: AppSpacingTokens.lg),
              _QuickOperationsPlaceholder(),
              SizedBox(height: AppSpacingTokens.lg),
              _SafetyTipsPlaceholder(),
            ],
          ),
        ),
      ],
    );
  }
}

class _DrugBoxPlaceholder extends StatelessWidget {
  const _DrugBoxPlaceholder();

  @override
  Widget build(BuildContext context) {
    return AppInlineSkeletonSection(
      children: [
        const Row(
          children: [
            AppInlineSkeletonCircle(size: 40),
            SizedBox(width: AppSpacingTokens.sm),
            Expanded(
              child: AppInlineSkeletonBlock(height: 18, widthFactor: 0.45),
            ),
            SizedBox(width: AppSpacingTokens.sm),
            AppInlineSkeletonBlock(height: 14, width: 80),
          ],
        ),
        const SizedBox(height: AppSpacingTokens.xs),
        const AppInlineSkeletonBlock(height: 14, widthFactor: 0.55),
        const SizedBox(height: AppSpacingTokens.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppInlineSkeletonBlock(height: 64, width: 64),
            const SizedBox(width: AppSpacingTokens.sm),
            Container(
              width: 1,
              height: 64,
              color: Theme.of(context).extension<AppThemeSurface>()!.hairline,
            ),
            const SizedBox(width: AppSpacingTokens.sm),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppInlineSkeletonBlock(height: 16, widthFactor: 0.8),
                  SizedBox(height: AppSpacingTokens.xs),
                  AppInlineSkeletonBlock(height: 14, widthFactor: 0.55),
                  SizedBox(height: AppSpacingTokens.sm),
                  AppInlineSkeletonBlock(height: 14, widthFactor: 0.7),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        const Divider(height: 1, thickness: 1),
        const SizedBox(height: AppSpacingTokens.sm),
        const Row(
          children: [
            AppInlineSkeletonCircle(size: 32),
            SizedBox(width: AppSpacingTokens.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppInlineSkeletonBlock(height: 14, widthFactor: 0.6),
                  SizedBox(height: AppSpacingTokens.xs),
                  AppInlineSkeletonBlock(height: 12, widthFactor: 0.45),
                ],
              ),
            ),
            AppInlineSkeletonBlock(
              height: 32,
              width: 72,
              radius: AppRadiusTokens.pill,
            ),
          ],
        ),
      ],
    );
  }
}

class _SafetyEnginePlaceholder extends StatelessWidget {
  const _SafetyEnginePlaceholder();

  @override
  Widget build(BuildContext context) {
    return AppInlineSkeletonSection(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppInlineSkeletonBlock(height: 18, widthFactor: 0.4),
            AppInlineSkeletonBlock(height: 14, width: 80),
          ],
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        for (var i = 0; i < 3; i += 1) ...[
          if (i > 0) const SizedBox(height: AppSpacingTokens.md),
          const Row(
            children: [
              AppInlineSkeletonCircle(size: 40),
              SizedBox(width: AppSpacingTokens.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppInlineSkeletonBlock(height: 16, widthFactor: 0.72),
                    SizedBox(height: AppSpacingTokens.xs),
                    AppInlineSkeletonBlock(height: 14, widthFactor: 0.55),
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

class _QuickOperationsPlaceholder extends StatelessWidget {
  const _QuickOperationsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 4; i += 1) ...[
          if (i > 0) const SizedBox(width: AppSpacingTokens.sm),
          const Expanded(
            child: AppInlineSkeletonBlock(
              height: 80,
              radius: AppRadiusTokens.lg,
            ),
          ),
        ],
      ],
    );
  }
}

class _RecordsPlaceholder extends StatelessWidget {
  const _RecordsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return AppInlineSkeletonSection(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppInlineSkeletonBlock(height: 18, widthFactor: 0.35),
            AppInlineSkeletonBlock(height: 14, width: 120),
          ],
        ),
        const SizedBox(height: AppSpacingTokens.md),
        for (var i = 0; i < 3; i += 1) ...[
          if (i > 0) const SizedBox(height: AppSpacingTokens.md),
          const Row(
            children: [
              AppInlineSkeletonCircle(size: 40),
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
              SizedBox(width: AppSpacingTokens.sm),
              AppInlineSkeletonBlock(
                height: 28,
                width: 56,
                radius: AppRadiusTokens.pill,
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

class _SafetyTipsPlaceholder extends StatelessWidget {
  const _SafetyTipsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return AppInlineSkeletonSection(
      children: [
        const AppInlineSkeletonBlock(height: 18, widthFactor: 0.45),
        const SizedBox(height: AppSpacingTokens.md),
        for (var i = 0; i < 2; i += 1) ...[
          if (i > 0) const SizedBox(height: AppSpacingTokens.md),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppInlineSkeletonCircle(size: 24),
              SizedBox(width: AppSpacingTokens.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppInlineSkeletonBlock(height: 16, widthFactor: 0.8),
                    SizedBox(height: AppSpacingTokens.xs),
                    AppInlineSkeletonBlock(height: 14, widthFactor: 0.65),
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
