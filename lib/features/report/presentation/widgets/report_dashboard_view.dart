import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/report_sections.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReportDashboardView extends StatelessWidget {
  const ReportDashboardView({super.key, required this.dashboard});

  final ReportDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReportScoreHero(
          key: const Key('report-score-hero'),
          dashboard: dashboard,
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        ReportMetricsGrid(
          key: const Key('report-metrics-grid'),
          metrics: dashboard.metrics,
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        ReportTrendSection(
          key: const Key('report-trend-section'),
          trends: dashboard.trends,
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        ReportFindingsSection(
          key: const Key('report-findings-section'),
          findings: dashboard.findings,
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        ReportAiSummarySection(
          key: const Key('report-ai-summary-section'),
          bullets: dashboard.aiBullets,
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
        const SizedBox(height: AppSpacingTokens.lg),
        ReportExportSection(
          key: const Key('report-export-section'),
          actions: dashboard.exportActions,
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
        const SizedBox(height: AppSpacingTokens.lg),
        ReportPatternsSection(
          key: const Key('report-patterns-section'),
          patterns: dashboard.patterns,
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        ReportPrivacySection(
          key: const Key('report-privacy-section'),
          actions: dashboard.privacyActions,
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        ReportReferenceNotice(
          key: const Key('report-reference-notice'),
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
      ],
    ).animate().fadeIn(duration: 220.ms).slideY(begin: 0.02, end: 0);
  }
}
