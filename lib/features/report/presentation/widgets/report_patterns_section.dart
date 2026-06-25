import 'package:flutter/material.dart';
import 'package:luminous/core/widgets/app_section_surface.dart';
import 'package:luminous/core/widgets/app_section_header.dart';
import 'package:luminous/core/widgets/app_icon_badge.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/report_components.dart';
import 'package:luminous/features/report/presentation/widgets/report_section_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReportPatternsSection extends StatelessWidget {
  const ReportPatternsSection({
    super.key,
    required this.patterns,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final List<ReportPatternCard> patterns;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(title: l10n.reportPatternSectionTitle),
        const SizedBox(height: AppSpacingTokens.sm),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: patterns.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacingTokens.sm,
            mainAxisSpacing: AppSpacingTokens.sm,
            mainAxisExtent: 180,
          ),
          itemBuilder: (context, index) {
            return _PatternCard(
              pattern: patterns[index],
              l10n: l10n,
              typography: typography,
              surface: surface,
            );
          },
        ),
      ],
    );
  }
}

class _PatternCard extends StatelessWidget {
  const _PatternCard({
    required this.pattern,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final ReportPatternCard pattern;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showReportToast(context, pattern.title),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: AppSectionSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppIconBadge(
                    icon: pattern.icon,
                    color: pattern.color,
                    size: 36,
                    iconSize: 20,
                    shape: BoxShape.circle,
                  ),
                  const SizedBox(width: AppSpacingTokens.xs),
                  Expanded(
                    child: Text(
                      pattern.title,
                      style: typography.bodySmStrong.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacingTokens.md),
              AppSkeletonText(
                text: reportStatusLabel(l10n, pattern.status),
                style: typography.bodyMdStrong.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                widthFactor: 0.74,
              ),
              const SizedBox(height: AppSpacingTokens.xxs),
              AppSkeletonText(
                text: pattern.body,
                style: typography.bodySm.copyWith(
                  color: surface.body,
                  letterSpacing: 0,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                widthFactor: 0.88,
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: AppSkeletonSlot(
                      skeleton: const AppInlineSkeletonBlock(
                        height: 28,
                        radius: AppRadiusTokens.sm,
                      ),
                      child: ReportMetricTrack(
                        values: pattern.sparkline,
                        color: pattern.color,
                        height: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacingTokens.sm),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: surface.body,
                    size: AppSpacingTokens.lg,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
