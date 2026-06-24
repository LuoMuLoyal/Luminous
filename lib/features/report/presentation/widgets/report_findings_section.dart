import 'package:flutter/material.dart';
import 'package:luminous/core/widgets/app_section_header.dart';
import 'package:luminous/core/widgets/app_icon_badge.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/report_components.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReportFindingsSection extends StatelessWidget {
  const ReportFindingsSection({
    super.key,
    required this.findings,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final List<ReportFinding> findings;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(title: l10n.reportFindingsSectionTitle),
        const SizedBox(height: AppSpacingTokens.sm),
        Divider(height: 1, thickness: 1, color: surface.hairline),
        const SizedBox(height: AppSpacingTokens.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var index = 0; index < findings.length; index += 1) ...[
                SizedBox(
                  width: 238,
                  child: _FindingCard(
                    finding: findings[index],
                    typography: typography,
                    surface: surface,
                  ),
                ),
                if (index != findings.length - 1)
                  const SizedBox(width: AppSpacingTokens.sm),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FindingCard extends StatelessWidget {
  const _FindingCard({
    required this.finding,
    required this.typography,
    required this.surface,
  });

  final ReportFinding finding;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showReportToast(context, finding.title),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: finding.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
            border: Border.all(color: finding.color.withValues(alpha: 0.18)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppIconBadge(
                      icon: finding.icon,
                      color: finding.color,
                      size: 42,
                      iconSize: 22,
                      shape: BoxShape.circle,
                    ),
                    const Spacer(),
                    AppIconBadge(
                      icon: Icons.chevron_right_rounded,
                      color: surface.body,
                      size: 28,
                      iconSize: 18,
                      shape: BoxShape.circle,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacingTokens.md),
                AppSkeletonText(
                  text: finding.title,
                  style: typography.bodyMdStrong.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                  widthFactor: 0.7,
                ),
                const SizedBox(height: AppSpacingTokens.sm),
                AppSkeletonText(
                  text: finding.body,
                  style: typography.bodySm.copyWith(
                    color: surface.body,
                    letterSpacing: 0,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  widthFactor: 0.9,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
