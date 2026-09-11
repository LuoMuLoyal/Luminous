import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';

/// Skeleton placeholder for the Mine tab loading state.
///
/// Mirrors the real dashboard section order so the loading-to-loaded
/// transition doesn't cause a large layout jump:
///
/// **Mobile:** MineSyncFailedBanner → AccountHero → Archive → AiPrivacy
/// → NotificationsReminders → AccountSecurity
///
/// **Desktop:** MineSyncFailedBanner → AccountHero →
/// Row[7: Archive+NotificationsReminders | 5: AiPrivacy+AccountSecurity]
class MineSkeletonView extends StatelessWidget {
  const MineSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= Breakpoints.desktop;

    return SkeletonShimmer(
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
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SyncBannerPlaceholder(),
        SizedBox(height: Spacing.lg),
        _AccountHeroPlaceholder(),
        SizedBox(height: Spacing.xl),
        _ArchivePlaceholder(),
        SizedBox(height: Spacing.xl),
        _AiPrivacyPlaceholder(),
        SizedBox(height: Spacing.xl),
        _NotificationsRemindersPlaceholder(),
        SizedBox(height: Spacing.xl),
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
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SyncBannerPlaceholder(),
        SizedBox(height: Spacing.lg),
        _AccountHeroPlaceholder(),
        SizedBox(height: Spacing.xl),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ArchivePlaceholder(),
                  SizedBox(height: Spacing.xl),
                  _NotificationsRemindersPlaceholder(),
                ],
              ),
            ),
            SizedBox(width: Spacing.xl),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AiPrivacyPlaceholder(),
                  SizedBox(height: Spacing.xl),
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
        borderRadius: context.theme.style.borderRadius.md,
        border: Border.all(color: SemanticColor.neutral.border(context)),
      ),
      child: const Padding(
        padding: EdgeInsets.all(Spacing.lg),
        child: Row(
          children: [
            InlineSkeletonCircle(size: 24),
            SizedBox(width: Spacing.md),
            Expanded(child: InlineSkeletonBlock(height: 14)),
            SizedBox(width: Spacing.md),
            InlineSkeletonBlock(height: 14, width: 56),
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
    return InlineSkeletonSection(
      children: [
        Row(
          children: [
            const InlineSkeletonCircle(size: 64),
            const SizedBox(width: Spacing.xl),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const InlineSkeletonBlock(height: 28, widthFactor: 0.45),
                      const SizedBox(width: Spacing.md),
                      InlineSkeletonBlock(
                        height: 18,
                        width: 56,
                        radius: context.theme.style.borderRadius.pill.topLeft.x,
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  const InlineSkeletonBlock(height: 14, widthFactor: 0.65),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.lg),
        const InlineSkeletonBlock(height: 14, widthFactor: 0.55),
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
        const InlineSkeletonBlock(height: 18, widthFactor: 0.3),
        const SizedBox(height: Spacing.md),
        InlineSkeletonSection(
          children: [
            for (var i = 0; i < 4; i += 1) ...[
              if (i > 0) const SizedBox(height: Spacing.lg),
              const Row(
                children: [
                  InlineSkeletonCircle(size: 40),
                  SizedBox(width: Spacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InlineSkeletonBlock(height: 16, widthFactor: 0.55),
                        SizedBox(height: Spacing.sm),
                        InlineSkeletonBlock(height: 14, widthFactor: 0.72),
                      ],
                    ),
                  ),
                  Icon(
                    SemanticIcons.actionNext,
                    color: Colors.transparent,
                    size: Spacing.xl,
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
        borderRadius: context.theme.style.borderRadius.md,
        border: Border.all(color: SemanticColor.neutral.border(context)),
      ),
      child: const Padding(
        padding: EdgeInsets.all(Spacing.lg),
        child: Row(
          children: [
            InlineSkeletonCircle(size: 24),
            SizedBox(width: Spacing.md),
            Expanded(child: InlineSkeletonBlock(height: 14)),
            SizedBox(width: Spacing.md),
            InlineSkeletonBlock(height: 14, width: 56),
            Icon(
              SemanticIcons.actionNext,
              color: Colors.transparent,
              size: Spacing.xl,
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
        const InlineSkeletonBlock(height: 18, widthFactor: 0.35),
        const SizedBox(height: Spacing.md),
        InlineSkeletonSection(
          children: [
            for (var i = 0; i < 3; i += 1) ...[
              if (i > 0) const SizedBox(height: Spacing.lg),
              const Row(
                children: [
                  InlineSkeletonCircle(size: 40),
                  SizedBox(width: Spacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InlineSkeletonBlock(height: 16, widthFactor: 0.5),
                        SizedBox(height: Spacing.sm),
                        InlineSkeletonBlock(height: 14, widthFactor: 0.72),
                      ],
                    ),
                  ),
                  Icon(
                    SemanticIcons.actionNext,
                    color: Colors.transparent,
                    size: Spacing.xl,
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
        const InlineSkeletonBlock(height: 18, widthFactor: 0.3),
        const SizedBox(height: Spacing.md),
        InlineSkeletonSection(
          children: [
            for (var i = 0; i < 3; i += 1) ...[
              if (i > 0) const SizedBox(height: Spacing.lg),
              const Row(
                children: [
                  InlineSkeletonCircle(size: 40),
                  SizedBox(width: Spacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InlineSkeletonBlock(height: 16, widthFactor: 0.45),
                        SizedBox(height: Spacing.sm),
                        InlineSkeletonBlock(height: 14, widthFactor: 0.6),
                      ],
                    ),
                  ),
                  Icon(
                    SemanticIcons.actionNext,
                    color: Colors.transparent,
                    size: Spacing.xl,
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
