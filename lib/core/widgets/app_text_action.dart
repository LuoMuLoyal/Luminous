import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';

class AppTextAction extends StatelessWidget {
  const AppTextAction({
    super.key,
    required this.label,
    required this.onTap,
    this.icon = Icons.chevron_right_rounded,
    this.color,
    this.flexible = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? color;
  final bool flexible;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);
    final foreground = color ?? surface.body;

    final text = Text(
      label,
      style: typography.bodySmStrong.copyWith(
        color: foreground,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.xxs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (flexible) Flexible(child: text) else text,
              if (icon != null) ...[
                const SizedBox(width: AppSpacingTokens.xxs),
                Icon(icon, size: AppSpacingTokens.md, color: foreground),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
