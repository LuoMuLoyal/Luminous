import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/semantic_color.dart';

enum TodayCardTone { emphasis, urgent, warning, soft, neutral }

/// Returns an [FCardStyleDelta] for Today section cards.
///
/// Most tones only override the background color, inheriting the global
/// subtle border (#F0F0F0) from [appThemeData]. Only urgent and warning
/// tones override the border with a semantic color for visual emphasis
/// (alert, not separation).
FCardStyleDelta todayCardStyle(
  BuildContext context, {
  TodayCardTone tone = TodayCardTone.neutral,
}) {
  final colors = context.theme.colors;

  return switch (tone) {
    TodayCardTone.urgent => .delta(
      decoration: .shapeDelta(
        color: SemanticColor.destructive.subtle(context),
        shape: RoundedSuperellipseBorder(
          side: BorderSide(color: SemanticColor.destructive.border(context)),
          borderRadius: context.theme.style.borderRadius.lg,
        ),
      ),
    ),
    TodayCardTone.warning => .delta(
      decoration: .shapeDelta(
        color: SemanticColor.warning.subtle(context),
        shape: RoundedSuperellipseBorder(
          side: BorderSide(color: SemanticColor.warning.border(context)),
          borderRadius: context.theme.style.borderRadius.lg,
        ),
      ),
    ),
    TodayCardTone.emphasis || TodayCardTone.soft || TodayCardTone.neutral =>
      .delta(decoration: .shapeDelta(color: colors.card)),
  };
}
