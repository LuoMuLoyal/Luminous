import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/constants/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';

class SettingsBackButton extends StatelessWidget {
  const SettingsBackButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () => context.pop(),
        borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacingTokens.xs),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: surface.body,
          ),
        ),
      ),
    );
  }
}

class SettingsListRow extends StatelessWidget {
  const SettingsListRow({
    super.key,
    required this.title,
    required this.onTap,
    this.icon,
    this.subtitle,
    this.trailing,
    this.showChevron = false,
    this.showDivider = false,
  });

  final String title;
  final VoidCallback onTap;
  final IconData? icon;
  final String? subtitle;
  final Widget? trailing;
  final bool showChevron;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
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
                Icon(icon, size: 18, color: surface.body),
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
                          color: surface.mute,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacingTokens.md),
                trailing!,
              ] else if (showChevron) ...[
                const SizedBox(width: AppSpacingTokens.md),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: surface.mute,
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (!showDivider) {
      return row;
    }

    return Column(
      children: [
        row,
        Divider(height: 1, color: surface.hairline),
      ],
    );
  }
}
