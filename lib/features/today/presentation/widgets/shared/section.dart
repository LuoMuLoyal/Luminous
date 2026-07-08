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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypographyToken.level7
                        .display(context)
                        .copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacingTokens.level1),
                    Text(
                      subtitle!,
                      style: AppTypographyToken.level2
                          .body(context)
                          .copyWith(color: colors.mutedForeground),
                    ),
                  ],
                ],
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
