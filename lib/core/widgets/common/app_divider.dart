import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// 项目统一分隔线。
///
/// 基于 [FDivider]，默认使用主题 [FColors.border] 颜色并去除默认内边距。
/// 可通过 [axis] 控制水平/垂直方向，通过 [width] 覆盖分割线粗细。
class AppDivider extends StatelessWidget {
  const AppDivider({
    super.key,
    this.axis = Axis.horizontal,
    this.color,
    this.width,
  });

  /// 分隔线方向，默认水平。
  final Axis axis;

  /// 分隔线颜色，默认使用主题 `border` 颜色。
  final Color? color;

  /// 分隔线粗细（水平时为高度，垂直时为宽度）。
  ///
  /// 不传则沿用 [FDivider] 默认样式粗细。
  final double? width;

  @override
  Widget build(BuildContext context) {
    return FDivider(
      axis: axis,
      style: FDividerStyleDelta.delta(
        color: color ?? context.theme.colors.border,
        padding: const EdgeInsetsGeometryDelta.value(EdgeInsets.zero),
        width: width,
      ),
    );
  }
}
