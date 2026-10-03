import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

class TodaySection extends StatelessWidget {
  const TodaySection({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final foreground = onAction == null
        ? SemanticColor.neutral.solid(context)
        : SemanticColor.primary.solid(context);
    final actionText = Text(
      actionLabel ?? '',
      style: TextStyle(
        color: foreground,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    final typography = context.theme.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题 + 动作按钮:按钮(FButton 内部 Row(mainAxisSize: min))是固有
        // 宽度,放进 Row 会先把 Expanded 标题挤成多行 / 自己向右溢出;Wrap 让
        // 按钮在放不下时换到标题下一行。标题/副标题仍叠在同一个 Column 里,
        // 保持原有「副标题在标题下方」的层次。
        Wrap(
          spacing: Spacing.md,
          runSpacing: Spacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: typography.display.xl.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: Spacing.xs),
                  Text(
                    subtitle!,
                    style: typography.body.xs2.copyWith(
                      color: SemanticColor.neutral.solid(context),
                    ),
                  ),
                ],
              ],
            ),
            if (actionLabel != null)
              FButton(
                variant: FButtonVariant.ghost,
                size: FButtonSizeVariant.xs,
                mainAxisSize: MainAxisSize.min,
                onPress: onAction ?? () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(child: actionText),
                    const SizedBox(width: Spacing.xs),
                    Icon(
                      SemanticIcons.actionNext,
                      size: IconSizeTokens.sm,
                      color: foreground,
                    ),
                  ],
                ),
              ),
          ],
        ),
        SizedBox(height: context.titleContentGap),
        child,
      ],
    );
  }
}
