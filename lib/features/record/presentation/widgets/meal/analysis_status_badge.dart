import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MealAnalysisStatusBadge extends StatelessWidget {
  const MealAnalysisStatusBadge({
    super.key,
    required this.status,
    this.large = false,
  });

  final String? status;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final (label, color, icon) = _statusSpec(l10n, status);
    final palette = color.palette(context);
    final foreground = palette.solid;

    return FBadge.raw(
      builder: (context, style) => DecoratedBox(
        decoration: ShapeDecoration(
          color: palette.muted,
          shape: RoundedSuperellipseBorder(
            borderRadius: context.theme.style.borderRadius.xs,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.sm,
            vertical: Spacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: foreground, size: Spacing.md),
              const SizedBox(width: Spacing.xs),
              Text(
                label,
                style: large
                    ? context.theme.typography.body.sm.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w600,
                      )
                    : context.theme.typography.body.xs.copyWith(
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
      ),
    );
  }

  /// v2 只有三个状态:`analyzing` / `analyzed` / `analysis_failed`。
  (String, SemanticColor, IconData) _statusSpec(
    AppLocalizations l10n,
    String? currentStatus,
  ) {
    return switch (currentStatus) {
      'analyzing' => (
        l10n.recordMealAnalysisStatusAnalyzing,
        SemanticColor.primary,
        SemanticIcons.statusPending,
      ),
      'analysis_failed' => (
        l10n.recordMealAnalysisStatusFailed,
        SemanticColor.destructive,
        SemanticIcons.statusError,
      ),
      _ => (
        l10n.recordMealAnalysisStatusAnalyzed,
        SemanticColor.primary,
        SemanticIcons.reportAdherence,
      ),
    };
  }
}
