import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';

class AppSettingRow extends StatelessWidget {
  const AppSettingRow({
    super.key,
    required this.title,
    required this.onTap,
    this.icon,
    this.subtitle,
    this.value,
    this.trailing,
    this.showChevron = false,
    this.showDivider = false,
  });

  final String title;
  final VoidCallback onTap;
  final IconData? icon;
  final String? subtitle;
  final String? value;
  final Widget? trailing;
  final bool showChevron;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appSurface = theme.extension<AppThemeSurface>()!;
    final width = MediaQuery.sizeOf(context).width;
    final typography = width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);

    final row = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadiusTokens.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacingTokens.sm,
            vertical: AppSpacingTokens.md,
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: appSurface.body),
                const SizedBox(width: AppSpacingTokens.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: typography.bodyMd.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacingTokens.xxs),
                      Text(
                        subtitle!,
                        style: typography.bodySm.copyWith(
                          color: appSurface.mute,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacingTokens.md),
                trailing!,
              ] else if (value != null) ...[
                const SizedBox(width: AppSpacingTokens.sm),
                Flexible(
                  child: Text(
                    value!,
                    style: typography.bodySm.copyWith(color: appSurface.body),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
              if (showChevron) ...[
                const SizedBox(width: AppSpacingTokens.xs),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: appSurface.mute,
                ),
              ],
            ],
          ),
        ),
      ),
    );
    if (!showDivider) return row;
    return Column(
      children: [
        row,
        Divider(height: 1, color: appSurface.hairline),
      ],
    );
  }
}
