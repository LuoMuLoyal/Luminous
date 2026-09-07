import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';

/// Responsive spacing metrics for the quick-entry panel.
class QuickEntryMetrics {
  const QuickEntryMetrics({
    required this.sectionGap,
    required this.tileVerticalPadding,
    required this.avatarSize,
    required this.notePadding,
    required this.dividerHeight,
  });

  factory QuickEntryMetrics.resolve(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final shortEdge = math.min(size.width, size.height);
    final scale = ((shortEdge - 600) / 280).clamp(0.0, 1.0);
    return QuickEntryMetrics(
      sectionGap: _lerpDouble(Spacing.level2, Spacing.level3, scale),
      tileVerticalPadding: _lerpDouble(Spacing.level2, Spacing.level4, scale),
      avatarSize: _lerpDouble(Spacing.level6, Spacing.level7, scale),
      notePadding: _lerpDouble(Spacing.level2, Spacing.level4, scale),
      dividerHeight: _lerpDouble(Spacing.level6, Spacing.level8, scale),
    );
  }

  final double sectionGap;
  final double tileVerticalPadding;
  final double avatarSize;
  final double notePadding;
  final double dividerHeight;
}

double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
