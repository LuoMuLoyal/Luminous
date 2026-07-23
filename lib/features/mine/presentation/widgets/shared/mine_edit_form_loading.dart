import 'package:flutter/material.dart';
import 'package:luminous/core/widgets/common/skeleton.dart';

/// Mine 编辑表单的加载骨架屏，用于 profile/allergy/condition/current_medicine 编辑页。
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
