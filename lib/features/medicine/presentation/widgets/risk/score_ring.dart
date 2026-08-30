import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/copy.dart';

/// A circular progress ring that visualises the overall risk score (0–100).
///
/// The ring colour adapts to the [MedicineRiskLevel] via [SemanticColor]. An
/// optional [AnimationController] drives a one-shot entrance animation that
/// sweeps the arc from 0 to the target [score].
class RiskScoreRing extends StatefulWidget {
  const RiskScoreRing({
    super.key,
    required this.score,
    required this.riskLevel,
    this.animate = true,
  });

  /// Risk score 0–100. Clamped to [0, 100] internally.
  final int score;

  final MedicineRiskLevel riskLevel;

  /// Whether to play the entrance animation on first build.
  final bool animate;

  @override
  State<RiskScoreRing> createState() => _RiskScoreRingState();
}

class _RiskScoreRingState extends State<RiskScoreRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DurationTokens.widgetStandard,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: MotionTokens.entrance,
    );
    if (widget.animate) unawaited(_controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = medicineRiskLevelColor(widget.riskLevel).palette(context);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final progress = widget.animate ? _animation.value : 1.0;
        return CustomPaint(
          size: const Size.square(120),
          painter: _RingPainter(
            progress: (widget.score.clamp(0, 100) / 100) * progress,
            backgroundColor: palette.subtle,
            foregroundColor: palette.solid,
            trackColor: palette.border,
          ),
          child: SizedBox.square(
            dimension: 120,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.score}',
                    style: context.theme.typography.display.xl2.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                      color: palette.solid,
                    ),
                  ),
                  Text(
                    '/100',
                    style: context.theme.typography.body.xs2.copyWith(
                      color: SemanticColor.neutral.solid(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.trackColor,
  });

  final double progress;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color trackColor;

  static const _strokeWidth = 10.0;
  static const _startAngle = -math.pi / 2; // top centre

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - _strokeWidth) / 2;

    // Background ring (full circle).
    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Foreground arc.
    if (progress > 0) {
      final sweep = progress * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: centre, radius: radius),
        _startAngle,
        sweep,
        false,
        Paint()
          ..color = foregroundColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = _strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      backgroundColor != oldDelegate.backgroundColor ||
      foregroundColor != oldDelegate.foregroundColor;
}
