import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';

/// Skeleton placeholder for the Mine tab loading state.
///
/// Mirrors the real dashboard section order so the loading-to-loaded
/// transition doesn't cause a large layout jump:
///
/// **Mobile:** SyncBanner → AccountHero → Archive → AiPrivacy
/// → NotificationsReminders → AccountSecurity
///
/// **Desktop:** SyncBanner → AccountHero →
/// Row[左7: Archive+NotificationsReminders | 右5: AiPrivacy+AccountSecurity]
class MineSkeletonView extends StatelessWidget {
  const MineSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= Breakpoints.desktop;

    return AppSkeletonShimmer(
      child: isDesktop
          ? const _DesktopMineSkeleton()
          : const _MobileMineSkeleton(),
    );
  }
}

class _MobileMineSkeleton extends StatelessWidget {
  const _MobileMineSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SyncBannerPlaceholder(),
        SizedBox(height: Spacing.level4),
        _AccountHeroPlaceholder(),
        SizedBox(height: Spacing.level5),
        _ArchivePlaceholder(),
        SizedBox(height: Spacing.level5),
        _AiPrivacyPlaceholder(),
        SizedBox(height: Spacing.level5),
        _NotificationsRemindersPlaceholder(),
        SizedBox(height: Spacing.level5),
        _AccountSecurityPlaceholder(),
      ],
    );
  }
}

class _DesktopMineSkeleton extends StatelessWidget {
  const _DesktopMineSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SyncBannerPlaceholder(),
        SizedBox(height: Spacing.level4),
        _AccountHeroPlaceholder(),
        SizedBox(height: Spacing.level5),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ArchivePlaceholder(),
                  SizedBox(height: Spacing.level5),
                  _NotificationsRemindersPlaceholder(),
                ],
              ),
            ),
            SizedBox(width: Spacing.level5),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AiPrivacyPlaceholder(),
                  SizedBox(height: Spacing.level5),
                  _AccountSecurityPlaceholder(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SyncBannerPlaceholder extends StatelessWidget {
  const _SyncBannerPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(RadiusTokens.level4),
        border: Border.all(color: colors.border),
      ),
      child: const Padding(
        padding: EdgeInsets.all(Spacing.level4),
        child: Row(
          children: [
            AppInlineSkeletonCircle(size: 24),
            SizedBox(width: Spacing.level3),
            Expanded(child: AppInlineSkeletonBlock(height: 14)),
            SizedBox(width: Spacing.level3),
            AppInlineSkeletonBlock(height: 14, width: 56),
          ],
        ),
      ),
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
            SizedBox(width: Spacing.level5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppInlineSkeletonBlock(height: 28, widthFactor: 0.45),
                      SizedBox(width: Spacing.level3),
                      AppInlineSkeletonBlock(
                        height: 18,
                        width: 56,
                        radius: RadiusTokens.levelFull,
                      ),
                    ],
                  ),
                  SizedBox(height: Spacing.level2),
                  AppInlineSkeletonBlock(height: 14, widthFactor: 0.65),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: Spacing.level4),
        AppInlineSkeletonBlock(height: 14, widthFactor: 0.55),
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
        const SizedBox(height: Spacing.level3),
        AppInlineSkeletonSection(
          children: [
            for (var i = 0; i < 4; i += 1) ...[
              if (i > 0) const SizedBox(height: Spacing.level4),
              const Row(
                children: [
                  AppInlineSkeletonCircle(size: 40),
                  SizedBox(width: Spacing.level4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppInlineSkeletonBlock(height: 16, widthFactor: 0.55),
                        SizedBox(height: Spacing.level2),
                        AppInlineSkeletonBlock(height: 14, widthFactor: 0.72),
                      ],
                    ),
                  ),
                  Icon(
                    FLucideIcons.chevronRight,
                    color: Colors.transparent,
                    size: Spacing.level5,
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

class _AiPrivacyPlaceholder extends StatelessWidget {
  const _AiPrivacyPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(RadiusTokens.level4),
        border: Border.all(color: colors.border),
      ),
      child: const Padding(
        padding: EdgeInsets.all(Spacing.level4),
        child: Row(
          children: [
            AppInlineSkeletonCircle(size: 24),
            SizedBox(width: Spacing.level3),
            Expanded(child: AppInlineSkeletonBlock(height: 14)),
            SizedBox(width: Spacing.level3),
            AppInlineSkeletonBlock(height: 14, width: 56),
            Icon(
              FLucideIcons.chevronRight,
              color: Colors.transparent,
              size: Spacing.level5,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsRemindersPlaceholder extends StatelessWidget {
  const _NotificationsRemindersPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppInlineSkeletonBlock(height: 18, widthFactor: 0.35),
        const SizedBox(height: Spacing.level3),
        AppInlineSkeletonSection(
          children: [
            for (var i = 0; i < 3; i += 1) ...[
              if (i > 0) const SizedBox(height: Spacing.level4),
              const Row(
                children: [
                  AppInlineSkeletonCircle(size: 40),
                  SizedBox(width: Spacing.level4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppInlineSkeletonBlock(height: 16, widthFactor: 0.5),
                        SizedBox(height: Spacing.level2),
                        AppInlineSkeletonBlock(height: 14, widthFactor: 0.72),
                      ],
                    ),
                  ),
                  Icon(
                    FLucideIcons.chevronRight,
                    color: Colors.transparent,
                    size: Spacing.level5,
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

class _AccountSecurityPlaceholder extends StatelessWidget {
  const _AccountSecurityPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppInlineSkeletonBlock(height: 18, widthFactor: 0.3),
        const SizedBox(height: Spacing.level3),
        AppInlineSkeletonSection(
          children: [
            for (var i = 0; i < 3; i += 1) ...[
              if (i > 0) const SizedBox(height: Spacing.level4),
              const Row(
                children: [
                  AppInlineSkeletonCircle(size: 40),
                  SizedBox(width: Spacing.level4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppInlineSkeletonBlock(height: 16, widthFactor: 0.45),
                        SizedBox(height: Spacing.level2),
                        AppInlineSkeletonBlock(height: 14, widthFactor: 0.6),
                      ],
                    ),
                  ),
                  Icon(
                    FLucideIcons.chevronRight,
                    color: Colors.transparent,
                    size: Spacing.level5,
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
