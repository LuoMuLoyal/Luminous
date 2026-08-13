import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

/// 全宽动作按钮：让长文案（en / 大字体）在可用宽度内换行或省略，而不是
/// 撑破 Forui 按钮内容 Row（RenderFlex overflow，Task 9 en / 大字体矩阵
/// 回归）。
///
/// Forui 按钮内容 Row 对非 flex 子项给出无界宽度，label 不会自动换行；
/// 因此在按钮**外层**用 LayoutBuilder 取真实可用宽度，再在按钮子项上
/// 施加 maxWidth 上限。视觉上按钮保持全宽、文案居中，超出 [maxLines]
/// 时省略号截断。
class ConstrainedActionButton extends StatelessWidget {
  const ConstrainedActionButton({
    super.key,
    required this.onPress,
    required this.label,
    this.maxLines = 2,
  });

  final VoidCallback onPress;
  final String label;

  /// 超出可用宽度时最多显示的行数，超出部分省略号截断。
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 按钮内容横向 padding 12+12（Forui 默认 contentPadding）。
        final maxLabelWidth = constraints.maxWidth - Spacing.level6;
        return FButton(
          onPress: onPress,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxLabelWidth > 0 ? maxLabelWidth : double.infinity,
            ),
            child: Text(
              label,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}
