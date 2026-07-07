import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

class TodaySection extends StatelessWidget {
  const TodaySection({
    super.key,
    required this.title,
    required this.child,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    final foreground = onAction == null
        ? colors.mutedForeground
        : colors.primary;
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
              child: Text(
                title,
                style: AppTypographyToken.level7
                    .display(context)
                    .copyWith(fontWeight: FontWeight.w600, letterSpacing: 0),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(width: AppSpacingTokens.level3),
              FButton(
                variant: FButtonVariant.ghost,
                size: FButtonSizeVariant.xs,
                mainAxisSize: MainAxisSize.min,
                onPress: onAction ?? () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    actionText,
                    const SizedBox(width: AppSpacingTokens.level1),
                    Icon(
                      FLucideIcons.chevronRight,
                      size: AppSpacingTokens.level4,
                      color: foreground,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacingTokens.level3),
        child,
      ],
    );
  }
}
