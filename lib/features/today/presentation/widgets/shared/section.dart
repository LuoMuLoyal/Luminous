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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.theme.typography.display.xl.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: Spacing.level1),
                    Text(
                      subtitle!,
                      style: context.theme.typography.body.xs2.copyWith(
                        color: SemanticColor.neutral.solid(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(width: Spacing.level3),
              FButton(
                variant: FButtonVariant.ghost,
                size: FButtonSizeVariant.xs,
                mainAxisSize: MainAxisSize.min,
                onPress: onAction ?? () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    actionText,
                    const SizedBox(width: Spacing.level1),
                    Icon(
                      SemanticIcons.actionNext,
                      size: IconSizeTokens.level2,
                      color: foreground,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: Spacing.level3),
        child,
      ],
    );
  }
}
