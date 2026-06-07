import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordSectionSurface extends StatelessWidget {
  const RecordSectionSurface({
    super.key,
    required this.child,
    required this.typography,
    required this.surface,
    this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.all(AppSpacingTokens.lg),
    this.backgroundColor,
  });

  final Widget child;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final hasHeader = (title != null && title!.isNotEmpty) || trailing != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? surface.canvas,
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (title != null && title!.isNotEmpty)
                          Text(title!, style: typography.displaySm),
                        if (subtitle != null && subtitle!.isNotEmpty) ...[
                          const SizedBox(height: AppSpacingTokens.xs),
                          Text(
                            subtitle!,
                            style: typography.bodySm.copyWith(
                              color: surface.body,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
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

class RecordHeaderActionChip extends StatelessWidget {
  const RecordHeaderActionChip({
    super.key,
    required this.label,
    required this.icon,
    required this.typography,
    required this.surface,
    required this.onTap,
    this.emphasized = false,
    this.iconOnly = false,
  });

  final String label;
  final IconData icon;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final VoidCallback onTap;
  final bool emphasized;
  final bool iconOnly;

  @override
  Widget build(BuildContext context) {
    const accent = AppColorTokens.cyanDeep;
    final foreground = emphasized
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;

    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: emphasized ? accent : surface.canvas,
              borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
              border: Border.all(color: emphasized ? accent : surface.hairline),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: iconOnly
                    ? AppSpacingTokens.sm
                    : AppSpacingTokens.md,
                vertical: AppSpacingTokens.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18, color: foreground),
                  if (!iconOnly) ...[
                    const SizedBox(width: AppSpacingTokens.xs),
                    Text(
                      label,
                      style: typography.buttonMd.copyWith(color: foreground),
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

class RecordIconBadge extends StatelessWidget {
  const RecordIconBadge({
    super.key,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.size = 42,
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
        child: Icon(icon, color: color, size: iconSize),
      ),
    );
  }
}

class RecordPill extends StatelessWidget {
  const RecordPill({
    super.key,
    required this.label,
    required this.color,
    required this.typography,
  });

  final String label;
  final Color color;
  final AppTypographyScale typography;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.sm,
          vertical: AppSpacingTokens.xs,
        ),
        child: Text(
          label,
          style: typography.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class RecordTextAction extends StatelessWidget {
  const RecordTextAction({
    super.key,
    required this.label,
    required this.typography,
    required this.surface,
    required this.onTap,
    this.icon,
  });

  final String label;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final VoidCallback onTap;
  final IconData? icon;

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
              if (icon != null) ...[
                const SizedBox(width: AppSpacingTokens.xxs),
                Icon(icon, size: 16, color: surface.body),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class RecordLineChart extends StatelessWidget {
  const RecordLineChart({
    super.key,
    required this.points,
    required this.color,
    required this.surface,
    this.secondaryPoints = const <double>[],
    this.secondaryColor,
    this.height = 104,
  });

  final List<double> points;
  final Color color;
  final AppThemeSurface surface;
  final List<double> secondaryPoints;
  final Color? secondaryColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _LineChartPainter(
          points: points,
          color: color,
          surface: surface,
          secondaryPoints: secondaryPoints,
          secondaryColor: secondaryColor,
        ),
      ),
    );
  }
}

class RecordBarChart extends StatelessWidget {
  const RecordBarChart({
    super.key,
    required this.values,
    required this.color,
    required this.surface,
    this.height = 104,
  });

  final List<double> values;
  final Color color;
  final AppThemeSurface surface;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _BarChartPainter(
          values: values,
          color: color,
          gridColor: surface.hairline,
        ),
      ),
    );
  }
}

void showRecordToast(BuildContext context, String action) {
  final l10n = AppLocalizations.of(context)!;
  AppToast.show(context, l10n.recordActionToast(action));
}

class _LineChartPainter extends CustomPainter {
  const _LineChartPainter({
    required this.points,
    required this.color,
    required this.surface,
    required this.secondaryPoints,
    required this.secondaryColor,
  });

  final List<double> points;
  final Color color;
  final AppThemeSurface surface;
  final List<double> secondaryPoints;
  final Color? secondaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawSeries(canvas, size, points, color);
    if (secondaryPoints.isNotEmpty && secondaryColor != null) {
      _drawSeries(canvas, size, secondaryPoints, secondaryColor!);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = surface.hairline
      ..strokeWidth = 1;
    for (var index = 1; index <= 3; index += 1) {
      final y = size.height * index / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawSeries(Canvas canvas, Size size, List<double> data, Color color) {
    if (data.length < 2) return;
    final minValue = data.reduce(math.min);
    final maxValue = data.reduce(math.max);
    final span = math.max(maxValue - minValue, 1);
    final path = Path();
    final dotPaint = Paint()..color = color;
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (var index = 0; index < data.length; index += 1) {
      final x = size.width * index / (data.length - 1);
      final normalized = (data[index] - minValue) / span;
      final y = size.height - (normalized * (size.height - 18)) - 9;
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.secondaryPoints != secondaryPoints ||
        oldDelegate.color != color ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.surface != surface;
  }
}

class _BarChartPainter extends CustomPainter {
  const _BarChartPainter({
    required this.values,
    required this.color,
    required this.gridColor,
  });

  final List<double> values;
  final Color color;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var index = 1; index <= 2; index += 1) {
      final y = size.height * index / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (values.isEmpty) return;
    final gap = size.width / (values.length * 2 + 1);
    final barWidth = gap;
    final paint = Paint()..color = color.withValues(alpha: 0.7);
    for (var index = 0; index < values.length; index += 1) {
      final left = gap + index * gap * 2;
      final heightFactor = values[index].clamp(0.0, 1.0);
      final height = heightFactor * (size.height - 8);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, size.height - height, barWidth, height),
        const Radius.circular(AppRadiusTokens.xs),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.color != color ||
        oldDelegate.gridColor != gridColor;
  }
}
