import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/widgets/app_state_views.dart';

class ReminderLoading extends StatelessWidget {
  const ReminderLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacingTokens.md),
      child: AppInlineSkeletonSection(
        children: [
          AppInlineSkeletonBlock(height: 86),
          AppInlineSkeletonBlock(height: 216),
          AppInlineSkeletonBlock(height: 116),
          AppInlineSkeletonBlock(height: 52),
        ],
      ),
    );
  }
}
