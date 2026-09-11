import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/feedback/skeleton.dart';

class RecordDetailLoading extends StatelessWidget {
  const RecordDetailLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InlineSkeletonSection(
          children: [
            InlineSkeletonBlock(height: 18, widthFactor: 0.34),
            InlineSkeletonBlock(height: 42),
            InlineSkeletonBlock(height: 18, widthFactor: 0.74),
          ],
        ),
        SizedBox(height: Spacing.lg),
        InlineSkeletonSection(
          children: [
            InlineSkeletonBlock(height: 160),
            InlineSkeletonBlock(height: 18, widthFactor: 0.42),
          ],
        ),
      ],
    );
  }
}
