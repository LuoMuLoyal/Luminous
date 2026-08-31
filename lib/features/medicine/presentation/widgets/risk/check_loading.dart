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
        horizontal: Spacing.level4,
        vertical: Spacing.level4,
      ),
      child: InlineSkeleton(
        children: [
          // Tab bar area.
          InlineSkeletonBlock(height: 44, widthFactor: 0.6),
          SizedBox(height: Spacing.level4),
          // Hero (risk score ring + description).
          InlineSkeletonBlock(height: 160),
          SizedBox(height: Spacing.level5),
          // Metric grid.
          InlineSkeletonBlock(height: 72),
          SizedBox(height: Spacing.level5),
          // Finding items.
          InlineSkeletonBlock(height: 64),
          SizedBox(height: Spacing.level3),
          InlineSkeletonBlock(height: 64),
        ],
      ),
    );
  }
}
