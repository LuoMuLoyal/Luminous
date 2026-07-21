import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';

class ReminderLoading extends StatelessWidget {
  const ReminderLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: Spacing.level4),
      child: InlineSkeletonSection(
        children: [
          InlineSkeletonBlock(height: 86),
          InlineSkeletonBlock(height: 216),
          InlineSkeletonBlock(height: 116),
          InlineSkeletonBlock(height: 52),
        ],
      ),
    );
  }
}
