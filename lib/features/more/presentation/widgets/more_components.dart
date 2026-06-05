import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MoreSectionSurface extends StatelessWidget {
  const MoreSectionSurface({
    super.key,
    required this.child,
    required this.typography,
    required this.surface,
    this.title,
    this.trailing,
    this.padding = const EdgeInsets.all(AppSpacingTokens.lg),
  });

  final Widget child;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final String? title;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final hasHeader = (title != null && title!.isNotEmpty) || trailing != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface.canvas,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        border: Border.all(color: surface.hairline),
        boxShadow: AppShadowTokens.level1,
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasHeader) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null && title!.isNotEmpty)
                    Expanded(child: Text(title!, style: typography.displaySm)),
                  if (trailing != null) ...[
                    const SizedBox(width: AppSpacingTokens.md),
                    trailing!,
                  ],
                ],
              ),
              const SizedBox(height: AppSpacingTokens.lg),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

class MoreHeaderActionChip extends StatelessWidget {
  const MoreHeaderActionChip({
    super.key,
    required this.label,
    required this.icon,
    required this.typography,
    required this.surface,
    required this.onTap,
    this.showLabel = false,
  });

  final String label;
  final IconData icon;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final VoidCallback onTap;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: surface.canvas,
              borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
              border: Border.all(color: surface.hairline),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: showLabel
                    ? AppSpacingTokens.md
                    : AppSpacingTokens.sm,
                vertical: AppSpacingTokens.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18, color: surface.body),
                  if (showLabel) ...[
                    const SizedBox(width: AppSpacingTokens.xs),
                    Text(
                      label,
                      style: typography.bodySm.copyWith(color: surface.body),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MoreIconBadge extends StatelessWidget {
  const MoreIconBadge({
    super.key,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.size = 44,
    this.iconSize = 22,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
      ),
      child: SizedBox.square(
        dimension: size,
        child: Icon(icon, size: iconSize, color: color),
      ),
    );
  }
}

class MoreTextAction extends StatelessWidget {
  const MoreTextAction({
    super.key,
    required this.label,
    required this.typography,
    required this.surface,
    required this.onTap,
  });

  final String label;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacingTokens.xs,
            vertical: AppSpacingTokens.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: typography.bodySm.copyWith(color: surface.body),
              ),
              const SizedBox(width: AppSpacingTokens.xxs),
              Icon(Icons.chevron_right_rounded, size: 16, color: surface.body),
            ],
          ),
        ),
      ),
    );
  }
}

class MoreListActionTile extends StatelessWidget {
  const MoreListActionTile({
    super.key,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.title,
    required this.subtitle,
    required this.typography,
    required this.surface,
    required this.onTap,
    this.showDivider = false,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final String title;
  final String subtitle;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final row = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadiusTokens.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.sm),
          child: Row(
            children: [
              MoreIconBadge(
                icon: icon,
                color: color,
                backgroundColor: backgroundColor,
                size: 44,
                iconSize: 22,
              ),
              const SizedBox(width: AppSpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: typography.bodyMdStrong),
                    const SizedBox(height: AppSpacingTokens.xxs),
                    Text(
                      subtitle,
                      style: typography.bodySm.copyWith(color: surface.body),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacingTokens.sm),
              Icon(Icons.chevron_right_rounded, size: 18, color: surface.mute),
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

class MoreFeatureCard extends StatelessWidget {
  const MoreFeatureCard({
    super.key,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.title,
    required this.subtitle,
    required this.typography,
    required this.surface,
    required this.onTap,
    this.minHeight = 110,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final String title;
  final String subtitle;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final VoidCallback onTap;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: surface.canvasSoft,
            borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
            border: Border.all(color: surface.hairline),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacingTokens.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MoreIconBadge(
                    icon: icon,
                    color: color,
                    backgroundColor: backgroundColor,
                    size: 48,
                    iconSize: 24,
                  ),
                  const SizedBox(width: AppSpacingTokens.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: typography.bodyMdStrong,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacingTokens.xs),
                        Text(
                          subtitle,
                          style: typography.bodySm.copyWith(
                            color: surface.body,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacingTokens.sm),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: surface.mute,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MoreCompactToolTile extends StatelessWidget {
  const MoreCompactToolTile({
    super.key,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.title,
    required this.subtitle,
    required this.typography,
    required this.surface,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final String title;
  final String subtitle;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: surface.canvasSoft,
            borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
            border: Border.all(color: surface.hairline),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MoreIconBadge(
                  icon: icon,
                  color: color,
                  backgroundColor: backgroundColor,
                  size: 40,
                  iconSize: 20,
                ),
                const SizedBox(height: AppSpacingTokens.sm),
                Text(
                  title,
                  style: typography.bodySmStrong,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                Expanded(
                  child: Text(
                    subtitle,
                    style: typography.caption.copyWith(color: surface.body),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MoreEnvironmentMetricTile extends StatelessWidget {
  const MoreEnvironmentMetricTile({
    super.key,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.title,
    required this.value,
    required this.valueColor,
    required this.typography,
    required this.surface,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final String title;
  final String value;
  final Color valueColor;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface.canvasSoft,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        border: Border.all(color: surface.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.sm,
          vertical: AppSpacingTokens.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MoreIconBadge(
              icon: icon,
              color: color,
              backgroundColor: backgroundColor,
              size: 34,
              iconSize: 18,
            ),
            const Spacer(),
            Text(
              title,
              style: typography.caption.copyWith(color: surface.body),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacingTokens.xxs),
            Text(
              value,
              style: typography.bodySmStrong.copyWith(color: valueColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class MoreRecentRow extends StatelessWidget {
  const MoreRecentRow({
    super.key,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.title,
    required this.timeLabel,
    required this.typography,
    required this.surface,
    required this.onTap,
    this.showDivider = false,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final String title;
  final String timeLabel;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final row = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadiusTokens.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.sm),
          child: Row(
            children: [
              MoreIconBadge(
                icon: icon,
                color: color,
                backgroundColor: backgroundColor,
                size: 36,
                iconSize: 18,
              ),
              const SizedBox(width: AppSpacingTokens.md),
              Expanded(
                child: Text(
                  title,
                  style: typography.bodyMd.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacingTokens.sm),
              Text(
                timeLabel,
                style: typography.bodySm.copyWith(color: surface.body),
              ),
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

void showMoreToast(BuildContext context, String action) {
  final l10n = AppLocalizations.of(context)!;
  AppToast.show(context, l10n.moreActionToast(action));
}
