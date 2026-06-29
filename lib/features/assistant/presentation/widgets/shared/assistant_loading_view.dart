import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';

class AssistantLoadingView extends StatelessWidget {
  const AssistantLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInlineSkeletonSection(
          children: [
            AppInlineSkeletonBlock(height: 28, widthFactor: 0.3),
            AppInlineSkeletonBlock(height: 18, widthFactor: 0.52),
            AppInlineSkeletonBlock(height: 18, widthFactor: 0.74),
          ],
        ),
        SizedBox(height: AppSpacingTokens.md),
        AppInlineSkeletonSection(
          children: [
            AppInlineSkeletonBlock(height: 240),
            AppInlineSkeletonBlock(height: 56),
          ],
        ),
        SizedBox(height: AppSpacingTokens.md),
        AppInlineSkeletonSection(
          children: [
            AppInlineSkeletonBlock(height: 56),
            AppInlineSkeletonBlock(height: 56),
            AppInlineSkeletonBlock(height: 56),
          ],
        ),
      ],
    );
  }
}
