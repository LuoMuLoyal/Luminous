import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';

class MedicineRiskCheckLoading extends StatelessWidget {
  const MedicineRiskCheckLoading({super.key});
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacingTokens.level4),
      child: AppInlineSkeletonSection(
        children: [
          AppInlineSkeletonBlock(height: 96),
          AppInlineSkeletonBlock(height: 220),
          AppInlineSkeletonBlock(height: 140),
        ],
      ),
    );
  }
}
