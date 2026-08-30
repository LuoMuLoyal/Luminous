import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReviewFindingsSection extends StatelessWidget {
  const ReviewFindingsSection({
    super.key,
    required this.findings,
    required this.l10n,
  });

  final List<ReviewFinding> findings;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reviewFindingsSectionTitle,
          style: context.theme.typography.body.md.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: Spacing.level4),
        if (findings.isEmpty)
          _EmptyFindingsView(l10n: l10n)
        else
          Wrap(
            spacing: Spacing.level3,
            runSpacing: Spacing.level3,
            children: [
              for (final finding in findings)
                SizedBox(
                  width: ResponsiveSizing.cardWidth(context),
                  child: _FindingCard(finding: finding),
                ),
            ],
          ),
      ],
    );
  }
}

class _EmptyFindingsView extends StatelessWidget {
  const _EmptyFindingsView({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Container(
      padding: const EdgeInsets.all(Spacing.level5),
      decoration: BoxDecoration(
        color: SemanticColor.neutral.subtle(context),
        borderRadius: context.theme.style.borderRadius.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            SemanticIcons.aiTip,
            color: colors.secondary,
            size: Spacing.level5,
          ),
          const SizedBox(width: Spacing.level3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.reviewFindingsEmptyTitle,
                  style: context.theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: Spacing.level1),
                Text(
                  l10n.reviewFindingsEmptyBody,
                  style: context.theme.typography.body.xs.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FindingCard extends StatelessWidget {
  const _FindingCard({required this.finding});

  final ReviewFinding finding;

  @override
  Widget build(BuildContext context) {
    final palette = finding.color.palette(context);

    return FCard(
      style: .delta(
        decoration: .shapeDelta(
          color: palette.muted,
          shape: RoundedSuperellipseBorder(
            side: BorderSide(color: palette.border),
            borderRadius: context.theme.style.borderRadius.lg,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FAvatar.raw(
                  size: ResponsiveSizing.scaleByWidth(
                    context,
                    fraction: 0.1,
                    minValue: 36,
                    maxValue: 44,
                  ),
                  child: Icon(
                    finding.icon,
                    color: palette.solid,
                    size: ResponsiveSizing.scaleByWidth(
                      context,
                      fraction: 0.052,
                      minValue: 18,
                      maxValue: 24,
                    ),
                  ),
                ),
                // No decorative chevron — the card is informational, not
                // navigational. A chevron would mislead users into expecting
                // a tap action that doesn't exist.
              ],
            ),
            const SizedBox(height: Spacing.level4),
            SkeletonText(
              text: finding.title,
              style: context.theme.typography.body.md.copyWith(
                fontWeight: FontWeight.w800,
              ),
              widthFactor: 0.7,
            ),
            const SizedBox(height: Spacing.level3),
            SkeletonText(
              text: finding.body,
              style: context.theme.typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              widthFactor: 0.9,
            ),
          ],
        ),
      ),
    );
  }
}
