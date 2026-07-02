import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';

class AppTextAction extends StatelessWidget {
  const AppTextAction({
    super.key,
    required this.label,
    required this.onTap,
    this.icon = FLucideIcons.chevronRight,
    this.color,
    this.flexible = false,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? color;
  final bool flexible;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final foreground = color ?? context.theme.colors.foreground;

    final text = Text(
      label,
      style: textTheme.labelMedium?.copyWith(
        color: foreground,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    return FButton(
      variant: FButtonVariant.ghost,
      size: FButtonSizeVariant.xs,
      onPress: onTap,
      mainAxisSize: MainAxisSize.min,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (flexible) Flexible(child: text) else text,
          if (icon != null) ...[
            const SizedBox(width: AppSpacingTokens.level1),
            Icon(icon, size: AppSpacingTokens.level4, color: foreground),
          ],
        ],
      ),
    );
  }
}
