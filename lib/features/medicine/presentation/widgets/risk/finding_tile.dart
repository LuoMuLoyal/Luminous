import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/control/divider.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// A single risk finding item — replaces the old [FCard]-wrapped tile.
///
/// Layout: left severity colour bar → icon circle → title/description/evidence
/// → severity pill. LLM findings with a `recommendation` show an extra line
/// below the description. Items are separated by [AppDivider] when [isLast]
/// is false.
class RiskFindingItem extends StatelessWidget {
  const RiskFindingItem({
    super.key,
    required this.finding,
    required this.isLast,
    required this.l10n,
  });

  final MedicineRiskFinding finding;
  final bool isLast;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final color = medicineRiskSeverityColor(finding.severity);
    final contextLabel = medicineRiskContextLabel(l10n, finding.context);
    final recommendation = finding.recommendation?.trim();
    final typography = context.theme.typography;

    final tile = Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.level3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left severity colour bar (4px wide).
          Container(
            width: 4,
            decoration: ShapeDecoration(
              color: color.solid(context),
              shape: RoundedSuperellipseBorder(
                borderRadius: context.theme.style.borderRadius.pill,
              ),
            ),
          ),
          const SizedBox(width: Spacing.level3),
          // Icon circle.
          DecoratedBox(
            decoration: BoxDecoration(
              color: color.muted(context),
              shape: BoxShape.circle,
            ),
            child: SizedBox.square(
              dimension: Spacing.level9,
              child: Icon(
                medicineRiskFindingIcon(finding),
                color: color.solid(context),
                size: IconSizeTokens.level3,
              ),
            ),
          ),
          const SizedBox(width: Spacing.level3),
          // Title + body + evidence + recommendation.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicineRiskFindingTitle(l10n, finding),
                  style: typography.body.md.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: Spacing.level1),
                Text(
                  medicineRiskFindingBody(l10n, finding),
                  style: typography.body.xs.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
                const SizedBox(height: Spacing.level1),
                Text(
                  medicineRiskFindingEvidence(l10n, finding),
                  style: typography.body.xs.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
                if (recommendation != null && recommendation.isNotEmpty) ...[
                  const SizedBox(height: Spacing.level2),
                  _RecommendationLine(text: recommendation, color: color),
                ],
              ],
            ),
          ),
          const SizedBox(width: Spacing.level3),
          // Severity + context pills.
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _SeverityPill(
                color: color,
                icon: medicineRiskSeverityIcon(finding.severity),
                label: medicineRiskSeverityLabel(l10n, finding.severity),
              ),
              if (contextLabel.isNotEmpty) ...[
                const SizedBox(height: Spacing.level1),
                _ContextPill(label: contextLabel),
              ],
            ],
          ),
        ],
      ),
    );

    if (isLast) return tile;
    return Column(children: [tile, const AppDivider()]);
  }
}

class _SeverityPill extends StatelessWidget {
  const _SeverityPill({
    required this.color,
    required this.icon,
    required this.label,
  });

  final SemanticColor color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color.solid(context);
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: color.muted(context),
        shape: RoundedSuperellipseBorder(
          borderRadius: context.theme.style.borderRadius.pill,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.level2,
          vertical: Spacing.level1,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: IconSizeTokens.level1, color: resolvedColor),
            const SizedBox(width: Spacing.level1),
            Text(
              label,
              style: context.theme.typography.body.xs.copyWith(
                color: resolvedColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ContextPill extends StatelessWidget {
  const _ContextPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = SemanticColor.neutral.solid(context);
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: SemanticColor.neutral.muted(context),
        shape: RoundedSuperellipseBorder(
          borderRadius: context.theme.style.borderRadius.pill,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.level2,
          vertical: Spacing.level1,
        ),
        child: Text(
          label,
          style: context.theme.typography.body.xs.copyWith(
            color: resolvedColor,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _RecommendationLine extends StatelessWidget {
  const _RecommendationLine({required this.text, required this.color});

  final String text;
  final SemanticColor color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          SemanticIcons.aiTip,
          size: IconSizeTokens.level2,
          color: color.solid(context),
        ),
        const SizedBox(width: Spacing.level2),
        Expanded(
          child: Text(
            text,
            style: context.theme.typography.body.xs.copyWith(
              color: color.solid(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
