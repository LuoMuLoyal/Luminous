import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/l10n/app_localizations.dart';

abstract final class ReportPalette {
  static const Color ink = AppColorTokens.ink;
  static const Color body = AppColorTokens.body;
  static const Color mute = AppColorTokens.mute;
  static const Color panel = AppColorTokens.canvas;
  static const Color panelSoft = AppColorTokens.canvasSoft;
  static const Color line = AppColorTokens.hairline;
  static const Color blue = AppColorTokens.link;
  static const Color blueSoft = AppColorTokens.linkSoft;
  static const Color green = AppColorTokens.cyanDeep;
  static const Color greenSoft = AppColorTokens.cyanSoft;
  static const Color previewScore = AppColorTokens.health;
  static const Color previewScoreSoft = AppColorTokens.healthSoft;
  static const Color violet = AppColorTokens.violet;
  static const Color violetSoft = AppColorTokens.violetSoft;
  static const Color pink = AppColorTokens.highlightMagenta;
  static const Color orange = AppColorTokens.warning;
  static const Color orangeSoft = AppColorTokens.warningSoft;
}

class ReportPanel extends StatelessWidget {
  const ReportPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacingTokens.md),
    this.color,
    this.borderColor,
    this.radius = AppRadiusTokens.lg,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? surface.canvas,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? surface.hairline),
        boxShadow: AppShadowTokens.level1,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class ReportSectionHeader extends StatelessWidget {
  const ReportSectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: typography.displaySm.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacingTokens.sm),
          trailing!,
        ],
      ],
    );
  }
}

class ReportIconBadge extends StatelessWidget {
  const ReportIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = AppSpacingTokens.x3l,
    this.iconSize = AppSpacingTokens.lg,
    this.shape = BoxShape.rectangle,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(AppRadiusTokens.lg)
            : null,
      ),
      child: SizedBox.square(
        dimension: size,
        child: Icon(icon, color: color, size: iconSize),
      ),
    );
  }
}

class ReportPill extends StatelessWidget {
  const ReportPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.backgroundAlpha = 0.12,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final double backgroundAlpha;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypographyTokens.mobile(
      Theme.of(context).colorScheme.onSurface,
    );
    final foreground = backgroundAlpha > 0.5 ? Colors.white : color;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: backgroundAlpha),
        borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.xs,
          vertical: AppSpacingTokens.xxs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: color, size: AppSpacingTokens.sm),
              const SizedBox(width: AppSpacingTokens.xxs),
            ],
            Text(
              label,
              style: typography.caption.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class ReportTextAction extends StatelessWidget {
  const ReportTextAction({
    super.key,
    required this.label,
    required this.onTap,
    this.icon = Icons.chevron_right_rounded,
    this.color,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);
    final foreground = color ?? surface.body;

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
              Text(
                label,
                style: typography.bodySmStrong.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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

class ReportMetricTrack extends StatelessWidget {
  const ReportMetricTrack({
    super.key,
    required this.values,
    required this.color,
    this.height = AppSpacingTokens.x2l,
  });

  final List<double> values;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final visibleValues = values.isEmpty ? const <double>[0, 0] : values;
    final minValue = visibleValues.reduce((a, b) => a < b ? a : b);
    final maxValue = visibleValues.reduce((a, b) => a > b ? a : b);
    final span = (maxValue - minValue).abs() < 1 ? 1 : maxValue - minValue;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var index = 0; index < visibleValues.length; index += 1) ...[
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor:
                      0.28 + ((visibleValues[index] - minValue) / span * 0.62),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
                      border: Border.all(color: surface.hairline),
                    ),
                    child: const SizedBox(width: AppSpacingTokens.xxs),
                  ),
                ),
              ),
            ),
            if (index != visibleValues.length - 1)
              const SizedBox(width: AppSpacingTokens.xxs),
          ],
        ],
      ),
    );
  }
}

void showReportToast(BuildContext context, String action) {
  final l10n = AppLocalizations.of(context)!;
  AppToast.show(context, l10n.reportActionToast(action));
}
