import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';

class MedicineRiskCheckLoading extends StatelessWidget {
  const MedicineRiskCheckLoading({super.key});
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: Spacing.level4),
      child: InlineSkeletonSection(
        children: [
          InlineSkeletonBlock(height: 96),
          InlineSkeletonBlock(height: 220),
          InlineSkeletonBlock(height: 140),
        ],
      ),
    );
  }
}
