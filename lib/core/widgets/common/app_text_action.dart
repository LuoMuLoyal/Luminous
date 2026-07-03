import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_colors.dart';
import 'package:luminous/core/design/app_design.dart';

/// A thin wrapper around Forui's [FButton] ghost variant.
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
  final AppColors? color;
  final bool flexible;

  @override
  Widget build(BuildContext context) {
    final foreground =
        color?.resolve(context.theme.colors) ?? context.theme.colors.foreground;

    final text = Text(
      label,
      style: TextStyle(
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
      mainAxisSize: MainAxisSize.min,
      onPress: onTap,
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
