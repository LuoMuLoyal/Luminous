import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/semantic_color.dart';

enum TodayCardTone { emphasis, urgent, warning, soft, neutral }

FCardStyleDelta todayCardStyle(
  BuildContext context, {
  TodayCardTone tone = TodayCardTone.neutral,
}) {
  final colors = context.theme.colors;

  final (border, background) = switch (tone) {
    TodayCardTone.urgent => (
      SemanticColor.destructive.border(context),
      SemanticColor.destructive.subtle(context),
    ),
    TodayCardTone.warning => (
      SemanticColor.warning.border(context),
      SemanticColor.warning.subtle(context),
    ),
    TodayCardTone.emphasis => (
      SemanticColor.primary.border(context),
      colors.card,
    ),
    TodayCardTone.soft => (
      SemanticColor.neutral.border(context).withValues(alpha: 0.86),
      colors.card,
    ),
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
