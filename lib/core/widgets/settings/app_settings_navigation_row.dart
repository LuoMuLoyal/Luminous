import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';

/// A standard settings row that navigates to a sub-page.
///
/// Shows an optional [value] label and a chevron on the trailing side.
/// When [enabled] is false, the row is muted and taps are ignored.
class AppSettingsNavigationRow extends StatelessWidget {
  const AppSettingsNavigationRow({
    super.key,
    required this.title,
    this.subtitle,
    this.value,
    required this.onTap,
    this.enabled = true,
    this.showDivider = false,
  });

  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback onTap;
  final bool enabled;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = _typography(context);
    final foreground = enabled
        ? surface.body
        : surface.body.withValues(alpha: 0.45);
    final mutedForeground = enabled
        ? surface.mute
        : surface.mute.withValues(alpha: 0.45);

    final row = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadiusTokens.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacingTokens.sm,
            vertical: AppSpacingTokens.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: typography.bodyMd.copyWith(
                        fontWeight: FontWeight.w500,
                        color: foreground,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacingTokens.xxs),
                      Text(
                        subtitle!,
                        style: typography.bodySm.copyWith(
                          color: mutedForeground,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (value != null && value!.isNotEmpty) ...[
                const SizedBox(width: AppSpacingTokens.sm),
                Flexible(
                  child: Text(
                    value!,
                    style: typography.bodySm.copyWith(color: mutedForeground),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
              const SizedBox(width: AppSpacingTokens.xs),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );

    if (!showDivider) return row;
    return Column(
      children: [
        row,
        Divider(height: 1, color: surface.hairline),
      ],
    );
  }

  AppTypographyScale _typography(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    return width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);
  }
}
