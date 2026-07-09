import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

enum TodayCardTone { emphasis, urgent, warning, soft, neutral }

FCardStyleDelta todayCardStyle(
  BuildContext context, {
  TodayCardTone tone = TodayCardTone.neutral,
}) {
  final colors = context.theme.colors;

  final (border, background) = switch (tone) {
    TodayCardTone.urgent => (
      colors.destructive.withValues(alpha: 0.3),
      colors.destructive.withValues(alpha: 0.04),
    ),
    TodayCardTone.warning => (
      const Color(0xFFF59E0B).withValues(alpha: 0.3),
      const Color(0xFFF59E0B).withValues(alpha: 0.04),
    ),
    TodayCardTone.emphasis => (
      colors.primary.withValues(alpha: 0.18),
      colors.card,
    ),
    TodayCardTone.soft => (colors.border.withValues(alpha: 0.86), colors.card),
    TodayCardTone.neutral => (colors.border, colors.card),
  };

  return .delta(
    decoration: .shapeDelta(
      color: background,
      shape: RoundedSuperellipseBorder(
        side: BorderSide(color: border),
        borderRadius: context.theme.style.borderRadius.lg,
      ),
    ),
  );
}
