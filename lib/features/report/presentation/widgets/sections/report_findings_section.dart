import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/design/app_responsive_sizing.dart';
import 'package:luminous/core/widgets/common/app_icon_badge.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';
import 'package:luminous/l10n/app_localizations.dart';

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
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reportFindingsSectionTitle,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacingTokens.level3),
        Divider(height: 1, thickness: 1, color: colors.border),
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
    final textTheme = Theme.of(context).textTheme;

    return FCard.raw(
      child: Container(
        decoration: BoxDecoration(
          color: finding.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadiusTokens.level4),
          border: Border.all(color: finding.color.withValues(alpha: 0.18)),
        ),
        padding: const EdgeInsets.all(AppSpacingTokens.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppIconBadge(
                  icon: finding.icon,
                  color: finding.color,
                  size: AppResponsiveSizing.scaleByWidth(
                    context,
                    fraction: 0.1,
                    minValue: 36,
                    maxValue: 44,
                  ),
                  iconSize: AppResponsiveSizing.scaleByWidth(
                    context,
                    fraction: 0.052,
                    minValue: 18,
                    maxValue: 24,
                  ),
                  shape: BoxShape.circle,
                ),
                const Spacer(),
                AppIconBadge(
                  icon: FLucideIcons.chevronRight,
                  color: colors.mutedForeground,
                  size: AppResponsiveSizing.scaleByWidth(
                    context,
                    fraction: 0.068,
                    minValue: 24,
                    maxValue: 30,
                  ),
                  iconSize: AppResponsiveSizing.scaleByWidth(
                    context,
                    fraction: 0.042,
                    minValue: 16,
                    maxValue: 20,
                  ),
                  shape: BoxShape.circle,
                ),
              ],
            ),
            const SizedBox(height: AppSpacingTokens.level4),
            AppSkeletonText(
              text: finding.title,
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
              widthFactor: 0.7,
            ),
            const SizedBox(height: AppSpacingTokens.level3),
            AppSkeletonText(
              text: finding.body,
              style: textTheme.bodySmall?.copyWith(
                color: colors.mutedForeground,
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
