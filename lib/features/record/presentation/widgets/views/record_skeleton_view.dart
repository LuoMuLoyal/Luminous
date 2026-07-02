import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/design/app_responsive_sizing.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';

/// Skeleton placeholder for the Record tab loading state.
///
/// Mirrors the date bar, AI input, quick actions, filters, and timeline
/// without using any mock domain data.
class RecordSkeletonView extends StatelessWidget {
  const RecordSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AppBreakpoints.desktop;

    return AppSkeletonShimmer(
      child: isDesktop
          ? const _DesktopRecordSkeleton()
          : const _MobileRecordSkeleton(),
    );
  }
}

class _MobileRecordSkeleton extends StatelessWidget {
  const _MobileRecordSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DateBarPlaceholder(),
        SizedBox(height: AppSpacingTokens.level4),
        _AiInputPlaceholder(),
        SizedBox(height: AppSpacingTokens.level4),
        _QuickEntryPlaceholder(),
        SizedBox(height: AppSpacingTokens.level4),
        _FilterPlaceholder(),
        SizedBox(height: AppSpacingTokens.level4),
        _TimelinePlaceholder(itemCount: 5),
        SizedBox(height: AppSpacingTokens.level4),
        _GuidePlaceholder(),
      ],
    );
  }
}

class _DesktopRecordSkeleton extends StatelessWidget {
  const _DesktopRecordSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: AppResponsiveSizing.sidebarWidth(context),
          child: const AppInlineSkeletonSection(
            height: 420,
            children: [
              AppInlineSkeletonBlock(height: 18, widthFactor: 0.6),
              SizedBox(height: AppSpacingTokens.level4),
              AppInlineSkeletonBlock(height: 280),
              SizedBox(height: AppSpacingTokens.level4),
              AppInlineSkeletonBlock(height: 72),
            ],
          ),
        ),
        const SizedBox(width: AppSpacingTokens.level4),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AiInputPlaceholder(),
              SizedBox(height: AppSpacingTokens.level4),
              _QuickEntryPlaceholder(),
              SizedBox(height: AppSpacingTokens.level4),
              _TimelinePlaceholder(itemCount: 6),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateBarPlaceholder extends StatelessWidget {
  const _DateBarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        AppInlineSkeletonBlock(
          height: 40,
          width: 40,
          radius: AppRadiusTokens.levelFull,
        ),
        SizedBox(width: AppSpacingTokens.level2),
        Expanded(
          child: AppInlineSkeletonBlock(
            height: 44,
            radius: AppRadiusTokens.levelFull,
          ),
        ),
        SizedBox(width: AppSpacingTokens.level2),
        AppInlineSkeletonBlock(
          height: 40,
          width: 40,
          radius: AppRadiusTokens.levelFull,
        ),
      ],
    );
  }
}

class _AiInputPlaceholder extends StatelessWidget {
  const _AiInputPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const AppInlineSkeletonBlock(height: 52, radius: AppRadiusTokens.level4);
  }
}

class _QuickEntryPlaceholder extends StatelessWidget {
  const _QuickEntryPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 4; i += 1) ...[
          if (i > 0) const SizedBox(width: AppSpacingTokens.level3),
          const Expanded(
            child: AppInlineSkeletonBlock(
              height: 72,
              radius: AppRadiusTokens.level4,
            ),
          ),
        ],
      ],
    );
  }
}

class _FilterPlaceholder extends StatelessWidget {
  const _FilterPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacingTokens.level3,
      runSpacing: AppSpacingTokens.level3,
      children: List.generate(
        5,
        (_) => const AppInlineSkeletonBlock(
          height: 36,
          width: 72,
          radius: AppRadiusTokens.levelFull,
        ),
      ),
    );
  }
}

class _TimelinePlaceholder extends StatelessWidget {
  const _TimelinePlaceholder({required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return AppInlineSkeletonSection(
      children: [
        const AppInlineSkeletonBlock(height: 20, widthFactor: 0.45),
        const SizedBox(height: AppSpacingTokens.level3),
        for (var i = 0; i < itemCount; i += 1) ...[
          if (i > 0) const SizedBox(height: AppSpacingTokens.level4),
          Row(
            children: [
              const AppInlineSkeletonBlock(height: 14, width: 40),
              const SizedBox(width: AppSpacingTokens.level4),
              const AppInlineSkeletonCircle(size: AppSpacingTokens.level3),
              const SizedBox(width: AppSpacingTokens.level4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppInlineSkeletonBlock(height: 16, widthFactor: 0.55),
                    const SizedBox(height: AppSpacingTokens.level2),
                    AppInlineSkeletonBlock(
                      height: 14,
                      widthFactor: i == itemCount - 1 ? 0.4 : 0.72,
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

class _GuidePlaceholder extends StatelessWidget {
  const _GuidePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        AppInlineSkeletonCircle(size: 16),
        SizedBox(width: AppSpacingTokens.level2),
        Expanded(child: AppInlineSkeletonBlock(height: 14)),
      ],
    );
  }
}
