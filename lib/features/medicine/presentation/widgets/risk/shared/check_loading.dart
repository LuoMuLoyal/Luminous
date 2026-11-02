import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/feedback/skeleton.dart';

/// Skeleton placeholder matching the new FTabs-based risk-check page layout.
///
/// Layout: tab bar skeleton → hero skeleton → metric grid skeleton →
/// two finding-item skeletons.
class MedicineRiskCheckLoading extends StatelessWidget {
  const MedicineRiskCheckLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.lg,
      ),
      child: InlineSkeleton(
        children: [
          // Tab bar area.
          InlineSkeletonBlock(height: 44, widthFactor: 0.6),
          SizedBox(height: Spacing.lg),
          // Hero (risk score ring + description).
          InlineSkeletonBlock(height: 160),
          SizedBox(height: Spacing.xl),
          // Metric grid.
          InlineSkeletonBlock(height: 72),
          SizedBox(height: Spacing.xl),
          // Finding items.
          InlineSkeletonBlock(height: 64),
          SizedBox(height: Spacing.md),
          InlineSkeletonBlock(height: 64),
        ],
      ),
    );
  }
}
