import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/control/divider.dart';
import 'package:luminous/core/widgets/common/state_views.dart';

/// Skeleton placeholder for the Medicine tab loading state.
///
/// Avoids showing fake medicine names, adherence percentages, or dosage data.
class MedicineSkeletonView extends StatelessWidget {
  const MedicineSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= Breakpoints.desktop;

    return SkeletonShimmer(
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
        SizedBox(height: Spacing.level4),
        _RecordsPlaceholder(),
        SizedBox(height: Spacing.level4),
        _SafetyEnginePlaceholder(),
        SizedBox(height: Spacing.level4),
        _QuickOperationsPlaceholder(),
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
              SizedBox(height: Spacing.level5),
              _RecordsPlaceholder(),
              SizedBox(height: Spacing.level5),
              _SafetyEnginePlaceholder(),
            ],
          ),
        ),
        SizedBox(width: Spacing.level5),
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_QuickOperationsPlaceholder()],
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
    return InlineSkeletonSection(
      children: [
        const Row(
          children: [
            InlineSkeletonCircle(size: 40),
            SizedBox(width: Spacing.level3),
            Expanded(child: InlineSkeletonBlock(height: 18, widthFactor: 0.45)),
            SizedBox(width: Spacing.level3),
            InlineSkeletonBlock(height: 14, width: 80),
          ],
        ),
        const SizedBox(height: Spacing.level2),
        const InlineSkeletonBlock(height: 14, widthFactor: 0.55),
        const SizedBox(height: Spacing.level4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const InlineSkeletonBlock(height: 64, width: 64),
            const SizedBox(width: Spacing.level3),
            Container(
              width: 1,
              height: 64,
              color: SemanticColor.neutral.border(context),
            ),
            const SizedBox(width: Spacing.level3),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InlineSkeletonBlock(height: 16, widthFactor: 0.8),
                  SizedBox(height: Spacing.level2),
                  InlineSkeletonBlock(height: 14, widthFactor: 0.55),
                  SizedBox(height: Spacing.level3),
                  InlineSkeletonBlock(height: 14, widthFactor: 0.7),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.level3),
        const AppDivider(),
        const SizedBox(height: Spacing.level3),
        Row(
          children: [
            const InlineSkeletonCircle(size: 32),
            const SizedBox(width: Spacing.level3),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InlineSkeletonBlock(height: 14, widthFactor: 0.6),
                  SizedBox(height: Spacing.level2),
                  InlineSkeletonBlock(height: 12, widthFactor: 0.45),
                ],
              ),
            ),
            InlineSkeletonBlock(
              height: 32,
              width: 72,
              radius: context.theme.style.borderRadius.pill.topLeft.x,
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
    return InlineSkeletonSection(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InlineSkeletonBlock(height: 18, widthFactor: 0.4),
            InlineSkeletonBlock(height: 14, width: 80),
          ],
        ),
        const SizedBox(height: Spacing.level3),
        for (var i = 0; i < 3; i += 1) ...[
          if (i > 0) const SizedBox(height: Spacing.level4),
          const Row(
            children: [
              InlineSkeletonCircle(size: 40),
              SizedBox(width: Spacing.level3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InlineSkeletonBlock(height: 16, widthFactor: 0.72),
                    SizedBox(height: Spacing.level2),
                    InlineSkeletonBlock(height: 14, widthFactor: 0.55),
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
          if (i > 0) const SizedBox(width: Spacing.level3),
          const Expanded(child: InlineSkeletonBlock(height: 80)),
        ],
      ],
    );
  }
}

class _RecordsPlaceholder extends StatelessWidget {
  const _RecordsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return InlineSkeletonSection(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InlineSkeletonBlock(height: 18, widthFactor: 0.35),
            InlineSkeletonBlock(height: 14, width: 120),
          ],
        ),
        const SizedBox(height: Spacing.level4),
        for (var i = 0; i < 3; i += 1) ...[
          if (i > 0) const SizedBox(height: Spacing.level4),
          Row(
            children: [
              const InlineSkeletonCircle(size: 40),
              const SizedBox(width: Spacing.level3),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InlineSkeletonBlock(height: 16, widthFactor: 0.65),
                    SizedBox(height: Spacing.level2),
                    InlineSkeletonBlock(height: 14, widthFactor: 0.5),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.level3),
              InlineSkeletonBlock(
                height: 28,
                width: 56,
                radius: context.theme.style.borderRadius.pill.topLeft.x,
              ),
            ],
          ),
        ],
      ],
    );
  }
}
