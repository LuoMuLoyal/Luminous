import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';

/// Skeleton placeholder for the Mine tab loading state.
///
/// Avoids exposing fake display names, emails, or completion percentages.
class MineSkeletonView extends StatelessWidget {
  const MineSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AppBreakpoints.desktop;
    final content = isDesktop
        ? const _DesktopMineSkeleton()
        : const _MobileMineSkeleton();

    return AppSkeletonShimmer(child: content);
  }
}

class _MobileMineSkeleton extends StatelessWidget {
  const _MobileMineSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AccountHeroPlaceholder(),
        SizedBox(height: AppSpacingTokens.level4),
        _StatusOverviewPlaceholder(),
        SizedBox(height: AppSpacingTokens.level5),
        _ArchivePlaceholder(),
        SizedBox(height: AppSpacingTokens.level5),
        _CampusServicePlaceholder(),
        SizedBox(height: AppSpacingTokens.level4),
        _PrivacyNoticePlaceholder(),
      ],
    );
  }
}

class _DesktopMineSkeleton extends StatelessWidget {
  const _DesktopMineSkeleton();

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
              _AccountHeroPlaceholder(),
              SizedBox(height: AppSpacingTokens.level5),
              _ArchivePlaceholder(),
              SizedBox(height: AppSpacingTokens.level5),
              _PrivacyNoticePlaceholder(),
            ],
          ),
        ),
        SizedBox(width: AppSpacingTokens.level5),
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusOverviewPlaceholder(),
              SizedBox(height: AppSpacingTokens.level5),
              _CampusServicePlaceholder(),
            ],
          ),
        ),
      ],
    );
  }
}

class _AccountHeroPlaceholder extends StatelessWidget {
  const _AccountHeroPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const AppInlineSkeletonSection(
      children: [
        Row(
          children: [
            AppInlineSkeletonCircle(size: 64),
            SizedBox(width: AppSpacingTokens.level5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppInlineSkeletonBlock(height: 28, widthFactor: 0.45),
                      SizedBox(width: AppSpacingTokens.level3),
                      AppInlineSkeletonBlock(
                        height: 18,
                        width: 56,
                        radius: AppRadiusTokens.levelFull,
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacingTokens.level2),
                  AppInlineSkeletonBlock(height: 14, widthFactor: 0.65),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacingTokens.level4),
        AppInlineSkeletonBlock(height: 14, widthFactor: 0.55),
      ],
    );
  }
}

class _StatusOverviewPlaceholder extends StatelessWidget {
  const _StatusOverviewPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return AppInlineSkeletonSection(
      children: [
        Row(
          children: [
            for (var i = 0; i < 3; i += 1) ...[
              if (i > 0) ...[
                Container(
                  width: 1,
                  height: 58,
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacingTokens.level2,
                  ),
                  color: colors.border,
                ),
              ],
              const Expanded(
                child: Column(
                  children: [
                    AppInlineSkeletonCircle(size: 42),
                    SizedBox(height: AppSpacingTokens.level3),
                    AppInlineSkeletonBlock(height: 14, widthFactor: 0.85),
                    SizedBox(height: AppSpacingTokens.level2),
                    AppInlineSkeletonBlock(height: 18, width: 44),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _ArchivePlaceholder extends StatelessWidget {
  const _ArchivePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppInlineSkeletonBlock(height: 18, widthFactor: 0.3),
        const SizedBox(height: AppSpacingTokens.level3),
        AppInlineSkeletonSection(
          children: [
            for (var i = 0; i < 4; i += 1) ...[
              if (i > 0) const SizedBox(height: AppSpacingTokens.level4),
              const Row(
                children: [
                  AppInlineSkeletonCircle(size: 40),
                  SizedBox(width: AppSpacingTokens.level4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppInlineSkeletonBlock(height: 16, widthFactor: 0.55),
                        SizedBox(height: AppSpacingTokens.level2),
                        AppInlineSkeletonBlock(height: 14, widthFactor: 0.72),
                      ],
                    ),
                  ),
                  Icon(
                    FLucideIcons.chevronRight,
                    color: Colors.transparent,
                    size: AppSpacingTokens.level5,
                  ),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _CampusServicePlaceholder extends StatelessWidget {
  const _CampusServicePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppInlineSkeletonBlock(height: 18, widthFactor: 0.35),
        const SizedBox(height: AppSpacingTokens.level3),
        AppInlineSkeletonSection(
          children: [
            for (var i = 0; i < 3; i += 1) ...[
              if (i > 0) const SizedBox(height: AppSpacingTokens.level4),
              const Row(
                children: [
                  AppInlineSkeletonCircle(size: 40),
                  SizedBox(width: AppSpacingTokens.level4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppInlineSkeletonBlock(height: 16, widthFactor: 0.5),
                        SizedBox(height: AppSpacingTokens.level2),
                        AppInlineSkeletonBlock(height: 14, widthFactor: 0.72),
                      ],
                    ),
                  ),
                  Icon(
                    FLucideIcons.chevronRight,
                    color: Colors.transparent,
                    size: AppSpacingTokens.level5,
                  ),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _PrivacyNoticePlaceholder extends StatelessWidget {
  const _PrivacyNoticePlaceholder();

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppRadiusTokens.level4),
        border: Border.all(color: colors.border),
      ),
      child: const Padding(
        padding: EdgeInsets.all(AppSpacingTokens.level4),
        child: Row(
          children: [
            AppInlineSkeletonCircle(size: 24),
            SizedBox(width: AppSpacingTokens.level3),
            Expanded(child: AppInlineSkeletonBlock(height: 14)),
            SizedBox(width: AppSpacingTokens.level3),
            AppInlineSkeletonBlock(height: 14, width: 56),
            Icon(
              FLucideIcons.chevronRight,
              color: Colors.transparent,
              size: AppSpacingTokens.level5,
            ),
          ],
        ),
      ),
    );
  }
}
