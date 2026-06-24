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
