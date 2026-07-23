import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

/// 带 Tooltip 的图标按钮，用于页面顶栏的紧凑操作入口。
///
/// 当 [showBadge] 为 true 时，在按钮右上角叠加一个红色小圆点（用于
/// 未读消息提醒等场景）。
class IconActionButton extends StatelessWidget {
  const IconActionButton({
    super.key,
    required this.tooltip,
    required this.icon,
    this.onTap,
    this.showBadge = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return FTooltip(
      tipBuilder: (context, controller) => Text(tooltip),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          FButton.icon(
            onPress: onTap,
            variant: FButtonVariant.ghost,
            size: FButtonSizeVariant.sm,
            child: Icon(icon, size: Spacing.level5),
          ),
          if (showBadge)
            Positioned(
              right: Spacing.level2,
              top: Spacing.level2,
              child: FBadge.raw(
                style: .delta(
                  decoration: .shapeDelta(
                    color: colors.destructive,
                    shape: CircleBorder(
                      side: BorderSide(color: colors.background, width: 2),
                    ),
                  ),
                ),
                builder: (context, style) =>
                    const SizedBox.square(dimension: Spacing.level3),
              ),
            ),
        ],
      ),
    );
  }
}
