import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:luminous/constants/today_constants.dart';

/// 通用圆形进度环组件。
///
/// 用于喝水追踪等需要环形进度展示的场景。
/// 支持自定义颜色、尺寸、中心子组件。
class TodayProgressRing extends StatelessWidget {
  const TodayProgressRing({
    super.key,
    required this.progress,
    this.size = TodayConstants.waterRingSize,
    this.strokeWidth = TodayConstants.waterRingStrokeWidth,
    this.backgroundColor,
    this.progressColor,
    this.center,
  });

  /// 进度值，范围 0.0 ~ 1.0。
  final double progress;

  /// 环形外径。
  final double size;

  /// 环形描边宽度。
  final double strokeWidth;

  /// 背景环颜色（默认使用主题 surface 色 + 透明度）。
  final Color? backgroundColor;

  /// 进度环颜色。
  final Color? progressColor;

  /// 环中心子组件。
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final resolvedBg =
        backgroundColor ??
        theme.colorScheme.outline.withValues(
          alpha: isDark ? 0.2 : TodayConstants.waterRingBgAlpha,
        );
    final resolvedProgress = progressColor ?? TodayConstants.waterPrimaryColor;
    final clampedProgress = progress.clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: clampedProgress,
          backgroundColor: resolvedBg,
          progressColor: resolvedProgress,
          strokeWidth: strokeWidth,
        ),
        child: center != null ? Center(child: center) : null,
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 背景环。
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // 进度弧。
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // 从 12 点方向开始
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
