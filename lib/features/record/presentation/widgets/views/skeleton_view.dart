import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';

/// Skeleton placeholder for the Record tab loading state.
///
/// Mirrors the date bar, AI input, quick actions, filters, and timeline
/// without using any mock domain data.
class RecordSkeletonView extends StatelessWidget {
  const RecordSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= Breakpoints.desktop;

    return SkeletonShimmer(
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
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DateBarPlaceholder(),
        SizedBox(height: Spacing.level4),
        _AiInputPlaceholder(),
        SizedBox(height: Spacing.level4),
        _QuickEntryPlaceholder(),
        SizedBox(height: Spacing.level4),
        _FilterPlaceholder(),
        SizedBox(height: Spacing.level4),
        _TimelinePlaceholder(itemCount: 5),
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
        // Left rail: calendar + filter
        SizedBox(
          width: ResponsiveSizing.sidebarWidth(context),
          child: const InlineSkeletonSection(
            height: 420,
            children: [
              InlineSkeletonBlock(height: 18, widthFactor: 0.6),
              SizedBox(height: Spacing.level4),
              InlineSkeletonBlock(height: 280),
              SizedBox(height: Spacing.level4),
              InlineSkeletonBlock(height: 72),
            ],
          ),
        ),
        const SizedBox(width: Spacing.level5),
        // Center: summary + timeline
        const Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InlineSkeletonBlock(height: 120),
              SizedBox(height: Spacing.level4),
              _TimelinePlaceholder(itemCount: 6),
            ],
          ),
        ),
        const SizedBox(width: Spacing.level5),
        // Right rail: new entry panel
        SizedBox(
          width: ResponsiveSizing.sidebarWidth(context),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [InlineSkeletonBlock(height: 200)],
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
    final borderRadius = context.theme.style.borderRadius;
    return Row(
      children: [
        InlineSkeletonBlock(
          height: 40,
          width: 40,
          radius: borderRadius.pill.topLeft.x,
        ),
        const SizedBox(width: Spacing.level2),
        Expanded(
          child: InlineSkeletonBlock(
            height: 44,
            radius: borderRadius.pill.topLeft.x,
          ),
        ),
        const SizedBox(width: Spacing.level2),
        InlineSkeletonBlock(
          height: 40,
          width: 40,
          radius: borderRadius.pill.topLeft.x,
        ),
      ],
    );
  }
}

class _AiInputPlaceholder extends StatelessWidget {
  const _AiInputPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const InlineSkeletonBlock(height: 52);
  }
}

class _QuickEntryPlaceholder extends StatelessWidget {
  const _QuickEntryPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 4; i += 1) ...[
          if (i > 0) const SizedBox(width: Spacing.level3),
          const Expanded(child: InlineSkeletonBlock(height: 72)),
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
      spacing: Spacing.level3,
      runSpacing: Spacing.level3,
      children: List.generate(
        5,
        (_) => InlineSkeletonBlock(
          height: 36,
          width: 72,
          radius: context.theme.style.borderRadius.pill.topLeft.x,
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
    return InlineSkeletonSection(
      children: [
        const InlineSkeletonBlock(height: 20, widthFactor: 0.45),
        const SizedBox(height: Spacing.level3),
        for (var i = 0; i < itemCount; i += 1) ...[
          if (i > 0) const SizedBox(height: Spacing.level4),
          Row(
            children: [
              const InlineSkeletonBlock(height: 14, width: 40),
              const SizedBox(width: Spacing.level4),
              const InlineSkeletonCircle(size: Spacing.level3),
              const SizedBox(width: Spacing.level4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const InlineSkeletonBlock(height: 16, widthFactor: 0.55),
                    const SizedBox(height: Spacing.level2),
                    InlineSkeletonBlock(
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
