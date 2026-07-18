import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/report/domain/entities/dashboard.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/core/widgets/common/divider.dart';

class ReportFindingsSection extends StatelessWidget {
  const ReportFindingsSection({
    super.key,
    required this.findings,
    required this.l10n,
  });

  final List<ReportFinding> findings;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reportFindingsSectionTitle,
          style: TypographyToken.level5
              .body(context)
              .copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: Spacing.level3),
        const AppDivider(),
        const SizedBox(height: Spacing.level4),
        if (findings.isEmpty)
          _EmptyFindingsView(l10n: l10n)
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var index = 0; index < findings.length; index += 1) ...[
                  SizedBox(
                    width: ResponsiveSizing.cardWidth(context),
                    child: _FindingCard(finding: findings[index]),
                  ),
                  if (index != findings.length - 1)
                    const SizedBox(width: Spacing.level3),
                ],
              ],
            ),
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
        borderRadius: BorderRadius.circular(RadiusTokens.level3),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            FLucideIcons.lightbulb,
            color: colors.secondary,
            size: Spacing.level5,
          ),
          const SizedBox(width: Spacing.level3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.reportFindingsEmptyTitle,
                  style: TypographyToken.level5
                      .body(context)
                      .copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: Spacing.level1),
                Text(
                  l10n.reportFindingsEmptyBody,
                  style: TypographyToken.level3
                      .body(context)
                      .copyWith(color: colors.mutedForeground),
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

  final ReportFinding finding;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    final palette = finding.color.palette(context);

    return FCard.raw(
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
            AppSkeletonText(
              text: finding.title,
              style: TypographyToken.level5
                  .body(context)
                  .copyWith(fontWeight: FontWeight.w800),
              widthFactor: 0.7,
            ),
            const SizedBox(height: Spacing.level3),
            AppSkeletonText(
              text: finding.body,
              style: TypographyToken.level3
                  .body(context)
                  .copyWith(color: colors.mutedForeground),
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
