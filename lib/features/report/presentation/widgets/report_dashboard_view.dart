import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/report/domain/entities/report_ai_summary.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/report_sections.dart';
import 'package:luminous/features/settings/presentation/providers/data_export_controller.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings_controller.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReportDashboardView extends ConsumerWidget {
  const ReportDashboardView({
    super.key,
    required this.dashboard,
    required this.authSession,
    this.isLoading = false,
    this.dashboardQuery = const ReportDashboardQuery(
      range: ReportDashboardRange.last7Days,
    ),
    this.onDashboardQueryChanged,
    this.aiSummaryState = const ReportAiSummaryCardState.idle(),
    this.aiSummaryRange = ReportAiSummaryRange.last7Days,
    this.onAiSummaryRangeChanged,
    this.onGenerateAiSummary,
    this.onExportActionTap,
    this.onMetricSelected,
    this.latestExportRequest,
    this.exportRequestInFlight = const DataExportRequestInFlightState(
      inFlight: false,
    ),
  });

  final ReportDashboard dashboard;
  final AuthSessionState authSession;
  final bool isLoading;
  final ReportDashboardQuery dashboardQuery;
  final ValueChanged<ReportDashboardQuery>? onDashboardQueryChanged;
  final ReportAiSummaryCardState aiSummaryState;
  final ReportAiSummaryRange aiSummaryRange;
  final ValueChanged<ReportAiSummaryRange>? onAiSummaryRangeChanged;
  final Future<void> Function()? onGenerateAiSummary;
  final Future<void> Function(ReportExportKind kind)? onExportActionTap;
  final ValueChanged<ReportDataKind>? onMetricSelected;
  final DataExportRequestDataDto? latestExportRequest;
  final DataExportRequestInFlightState exportRequestInFlight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);
    final settingsAsync = ref.watch(userSettingsControllerProvider);

    final content = Column(
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
          dashboard: dashboard,
          metrics: dashboard.metrics,
          l10n: l10n,
          typography: typography,
          surface: surface,
          onMetricSelected: onMetricSelected,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        ReportTrendSection(
          key: const Key('report-trend-section'),
          trends: dashboard.trends,
          selectedQuery: dashboardQuery,
          onQueryChanged: onDashboardQueryChanged ?? (_) {},
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
          dashboard: dashboard,
          authSession: authSession,
          settingsAsync: settingsAsync,
          aiState: aiSummaryState,
          selectedRange: aiSummaryRange,
          onRangeChanged: onAiSummaryRangeChanged,
          onGenerate: onGenerateAiSummary,
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
        const SizedBox(height: AppSpacingTokens.lg),
        ReportExportSection(
          key: const Key('report-export-section'),
          actions: dashboard.exportActions,
          latestRequest: latestExportRequest,
          requestInFlight: exportRequestInFlight,
          onActionTap: onExportActionTap,
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
        ReportReferenceNotice(
          key: const Key('report-reference-notice'),
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
      ],
    );

    final scopedContent = AppSkeletonScope(
      isLoading: isLoading,
      child: content,
    );
    if (isLoading) {
      return scopedContent;
    }

    return scopedContent
        .animate()
        .fadeIn(duration: 220.ms)
        .slideY(begin: 0.02, end: 0);
  }
}
