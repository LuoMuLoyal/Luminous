import 'package:flutter/material.dart';
import 'package:luminous/core/widgets/common/feedback/skeleton.dart';

/// Loading skeleton for mine edit forms, used in profile/allergy/condition/current_medicine edit pages.
class MineEditFormLoading extends StatelessWidget {
  const MineEditFormLoading({
    super.key,
    this.blockHeights = const [56, 56, 56, 56, 96, 56],
  });

  final List<double> blockHeights;

  @override
  Widget build(BuildContext context) {
    return InlineSkeletonSection(
      children: [for (final h in blockHeights) InlineSkeletonBlock(height: h)],
    );
  }
}
