import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';

class AssistantLoadingView extends StatelessWidget {
  const AssistantLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InlineSkeletonSection(
          children: [
            InlineSkeletonBlock(height: 28, widthFactor: 0.3),
            InlineSkeletonBlock(height: 18, widthFactor: 0.52),
            InlineSkeletonBlock(height: 18, widthFactor: 0.74),
          ],
        ),
        SizedBox(height: Spacing.level4),
        InlineSkeletonSection(
          children: [
            InlineSkeletonBlock(height: 240),
            InlineSkeletonBlock(height: 56),
          ],
        ),
      ],
    );
  }
}
