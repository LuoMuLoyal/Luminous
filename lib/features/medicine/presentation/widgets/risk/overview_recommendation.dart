import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Overall recommendation card (LLM only).
class OverallRecommendationCard extends StatelessWidget {
  const OverallRecommendationCard({
    super.key,
    required this.l10n,
    required this.text,
  });

  final AppLocalizations l10n;
  final String text;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: SemanticColor.primary.subtle(context),
        shape: RoundedSuperellipseBorder(
          borderRadius: context.theme.style.borderRadius.md,
          side: BorderSide(color: SemanticColor.primary.border(context)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  SemanticIcons.aiTip,
                  color: SemanticColor.primary.solid(context),
                  size: IconSizeTokens.md,
                ),
                const SizedBox(width: Spacing.sm),
                Text(
                  l10n.medicineRiskOverallRecommendation,
                  style: typography.body.md.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Text(
              text,
              style: typography.body.xs.copyWith(
                color: context.theme.colors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
