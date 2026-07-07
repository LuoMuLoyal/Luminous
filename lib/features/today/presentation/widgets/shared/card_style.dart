import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

enum TodayCardTone { emphasis, soft, neutral }

FCardStyleDelta todayCardStyle(
  BuildContext context, {
  TodayCardTone tone = TodayCardTone.neutral,
}) {
  final colors = context.theme.colors;

  final border = switch (tone) {
    TodayCardTone.emphasis => colors.primary.withValues(alpha: 0.18),
    TodayCardTone.soft => colors.border.withValues(alpha: 0.86),
    TodayCardTone.neutral => colors.border,
  };

  return .delta(
    decoration: .shapeDelta(
      color: colors.card,
      shape: RoundedSuperellipseBorder(
        side: BorderSide(color: border),
        borderRadius: context.theme.style.borderRadius.lg,
      ),
    ),
  );
}
