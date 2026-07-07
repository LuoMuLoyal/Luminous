import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/colors.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/design/responsive_sizing.dart';
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
          style: AppTypographyToken.level5
              .body(context)
              .copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacingTokens.level3),
        const AppDivider(),
        const SizedBox(height: AppSpacingTokens.level4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var index = 0; index < findings.length; index += 1) ...[
                SizedBox(
                  width: AppResponsiveSizing.cardWidth(context),
                  child: _FindingCard(finding: findings[index]),
                ),
                if (index != findings.length - 1)
                  const SizedBox(width: AppSpacingTokens.level3),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FindingCard extends StatelessWidget {
  const _FindingCard({required this.finding});

  final ReportFinding finding;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    final resolvedColor = finding.color.resolve(colors);

    return FCard.raw(
      style: .delta(
        decoration: .shapeDelta(
          color: resolvedColor.withValues(alpha: 0.08),
          shape: RoundedSuperellipseBorder(
            side: BorderSide(color: resolvedColor.withValues(alpha: 0.18)),
            borderRadius: context.theme.style.borderRadius.lg,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FAvatar.raw(
                  size: AppResponsiveSizing.scaleByWidth(
                    context,
                    fraction: 0.1,
                    minValue: 36,
                    maxValue: 44,
                  ),
                  child: Icon(
                    finding.icon,
                    color: resolvedColor,
                    size: AppResponsiveSizing.scaleByWidth(
                      context,
                      fraction: 0.052,
                      minValue: 18,
                      maxValue: 24,
                    ),
                  ),
                ),
                const Spacer(),
                FAvatar.raw(
                  size: AppResponsiveSizing.scaleByWidth(
                    context,
                    fraction: 0.068,
                    minValue: 24,
                    maxValue: 30,
                  ),
                  child: Icon(
                    FLucideIcons.chevronRight,
                    color: AppColors.muted.resolve(colors),
                    size: AppResponsiveSizing.scaleByWidth(
                      context,
                      fraction: 0.042,
                      minValue: 16,
                      maxValue: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacingTokens.level4),
            AppSkeletonText(
              text: finding.title,
              style: AppTypographyToken.level5
                  .body(context)
                  .copyWith(fontWeight: FontWeight.w800),
              widthFactor: 0.7,
            ),
            const SizedBox(height: AppSpacingTokens.level3),
            AppSkeletonText(
              text: finding.body,
              style: AppTypographyToken.level3
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
