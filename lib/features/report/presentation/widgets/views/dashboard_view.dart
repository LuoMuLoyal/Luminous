import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:forui/forui.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/report/domain/entities/ai_summary.dart';
import 'package:luminous/features/report/domain/entities/dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/sections/ai_summary.dart';
import 'package:luminous/features/report/presentation/widgets/sections/export.dart';
import 'package:luminous/features/report/presentation/widgets/sections/findings.dart';
import 'package:luminous/features/report/presentation/widgets/sections/patterns.dart';
import 'package:luminous/features/report/presentation/widgets/sections/preview_empty.dart';
import 'package:luminous/features/report/presentation/widgets/sections/readiness.dart';
import 'package:luminous/features/report/presentation/widgets/sections/suggestion_history.dart';
import 'package:luminous/features/report/presentation/widgets/sections/trend.dart';
import 'package:luminous/features/report/presentation/widgets/shared/reference_notice.dart';
import 'package:luminous/features/settings/presentation/providers/data_export.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReportDashboardView extends StatelessWidget {
  const ReportDashboardView({
    super.key,
    required this.dashboard,
    required this.canAccessProtectedData,
    this.aiSummariesEnabled,
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
    this.latestExportRequest,
    this.exportRequestInFlight = const DataExportRequestInFlightState(
      inFlight: false,
    ),
    this.clinicShareInFlight = false,
    this.isPreview = false,
    this.generatedAtLabel = '',
    this.onSignIn,
    this.onContinueRecord,
    this.onSync,
    this.suggestionHistory = const [],
    this.isSuggestionHistoryLoading = false,
    this.onSuggestionTap,
  });

  final ReportDashboard dashboard;
  final bool canAccessProtectedData;
  final bool? aiSummariesEnabled;
  final bool isLoading;
  final ReportDashboardQuery dashboardQuery;
  final ValueChanged<ReportDashboardQuery>? onDashboardQueryChanged;
  final ReportAiSummaryCardState aiSummaryState;
  final ReportAiSummaryRange aiSummaryRange;
  final ValueChanged<ReportAiSummaryRange>? onAiSummaryRangeChanged;
  final Future<void> Function()? onGenerateAiSummary;
  final Future<void> Function(ReportExportKind kind)? onExportActionTap;
  final DataExportRequestDataDto? latestExportRequest;
  final DataExportRequestInFlightState exportRequestInFlight;
  final bool clinicShareInFlight;
  final bool isPreview;
  final String generatedAtLabel;
  final VoidCallback? onSignIn;
  final VoidCallback? onContinueRecord;
  final VoidCallback? onSync;
  final List<TodaySuggestionHistoryItem> suggestionHistory;
  final bool isSuggestionHistoryLoading;
  final ValueChanged<TodaySuggestionHistoryItem>? onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= Breakpoints.desktop;

    final content = isDesktop
        ? _buildDesktopLayout(l10n: l10n)
        : _buildMobileLayout(l10n: l10n);

    final scopedContent = SkeletonScope(isLoading: isLoading, child: content);
    if (isLoading) {
      return scopedContent;
    }

    return Animate(
      effects: const [
        FadeEffect(duration: DurationTokens.widgetFadeIn),
        SlideEffect(
          begin: Offset(0, 0.02),
          end: Offset.zero,
          duration: DurationTokens.widgetFadeIn,
        ),
      ],
      child: scopedContent,
    );
  }

  Widget _buildMobileLayout({required AppLocalizations l10n}) {
    final readinessStatus = _readinessStatus();
    final canShowFullReport = readinessStatus == ReportReadinessStatus.ready;

    if (isPreview || !canAccessProtectedData) {
      return _buildMobilePreviewLayout(l10n: l10n);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReportReadinessSection(
          status: readinessStatus,
          generatedAtLabel: generatedAtLabel,
          insufficientMetricCount: _insufficientMetricCount(),
          needsAttentionMetricCount: _needsAttentionMetricCount(),
          l10n: l10n,
          rangeLabel: _rangeLabel(l10n),
          scoreSummary: readinessStatus == ReportReadinessStatus.ready
              ? dashboard.score.summary
              : '',
          onSignIn: onSignIn,
          onContinueRecord: onContinueRecord,
          onGenerate: onGenerateAiSummary == null
              ? null
              : () {
                  onGenerateAiSummary!();
                },
          onSync: onSync,
          isGenerating:
              aiSummaryState.status == ReportAiSummaryCardStatus.loading,
        ),
        const SizedBox(height: Spacing.level5),
        ReportTrendSection(
          key: const Key('report-trend-section'),
          trends: dashboard.trends,
          selectedQuery: dashboardQuery,
          onQueryChanged: onDashboardQueryChanged ?? (_) {},
          l10n: l10n,
          startDate: dashboard.startDate,
          showRangePill: false,
        ),
        const SizedBox(height: Spacing.level5),
        ReportFindingsSection(
          key: const Key('report-findings-section'),
          findings: dashboard.findings,
          l10n: l10n,
        ),
        if (canAccessProtectedData) ...[
          const SizedBox(height: Spacing.level5),
          ReportSuggestionHistorySection(
            suggestions: suggestionHistory,
            isLoading: isSuggestionHistoryLoading,
            onSuggestionTap: onSuggestionTap,
            l10n: l10n,
          ),
        ],
        if (!canShowFullReport) ...[
          const SizedBox(height: Spacing.level5),
          _ReportLockedFeaturesHint(
            message: readinessStatus == ReportReadinessStatus.signedOut
                ? l10n.reportLockedFeaturesSignedOutHint
                : l10n.reportLockedFeaturesInsufficientHint,
          ),
        ],
        if (canShowFullReport) ...[
          const SizedBox(height: Spacing.level5),
          ReportAiSummarySection(
            key: const Key('report-ai-summary-section'),
            dashboard: dashboard,
            canAccessProtectedData: canAccessProtectedData,
            aiSummariesEnabled: aiSummariesEnabled,
            aiState: aiSummaryState,
            selectedRange: aiSummaryRange,
            onRangeChanged: onAiSummaryRangeChanged,
            onGenerate: onGenerateAiSummary,
            l10n: l10n,
          ),
          const SizedBox(height: Spacing.level5),
          ReportPatternsSection(
            key: const Key('report-patterns-section'),
            patterns: dashboard.patterns,
            l10n: l10n,
          ),
          const SizedBox(height: Spacing.level5),
          ReportExportSection(
            key: const Key('report-export-section'),
            actions: dashboard.exportActions,
            latestRequest: latestExportRequest,
            requestInFlight: exportRequestInFlight,
            clinicShareInFlight: clinicShareInFlight,
            onActionTap: onExportActionTap,
            l10n: l10n,
          ),
          const SizedBox(height: Spacing.level5),
          ReportReferenceNotice(
            key: const Key('report-reference-notice-mobile'),
            l10n: l10n,
          ),
        ],
      ],
    );
  }

  Widget _buildMobilePreviewLayout({required AppLocalizations l10n}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SignInHintBanner(
          onSignIn: onSignIn,
          message: l10n.reportPreviewBannerMessage,
        ),
        const SizedBox(height: Spacing.level4),
        ReportTrendSection(
          key: const Key('report-trend-section'),
          trends: _previewTrends,
          selectedQuery: dashboardQuery,
          onQueryChanged: onDashboardQueryChanged ?? (_) {},
          l10n: l10n,
          startDate: dashboard.startDate,
          showRangePill: false,
        ),
        const SizedBox(height: Spacing.level4),
        ReportPreviewLockedSection(
          key: const Key('report-findings-preview-locked'),
          icon: SemanticIcons.aiTip,
          title: l10n.reportFindingsPreviewTitle,
          body: l10n.reportFindingsPreviewBody,
        ),
        const SizedBox(height: Spacing.level4),
        ReportPreviewLockedSection(
          key: const Key('report-suggestion-history-preview-locked'),
          icon: SemanticIcons.reportHistory,
          title: l10n.reportSuggestionHistoryPreviewTitle,
          body: l10n.reportSuggestionHistoryPreviewBody,
        ),
        const SizedBox(height: Spacing.level4),
        ReportExportSection(
          key: const Key('report-export-section'),
          actions: _previewExportActions,
          latestRequest: null,
          requestInFlight: const DataExportRequestInFlightState(
            inFlight: false,
          ),
          l10n: l10n,
          onActionTap: null,
        ),
      ],
    );
  }

  Widget _buildDesktopLayout({required AppLocalizations l10n}) {
    final readinessStatus = _readinessStatus();

    if (isPreview || !canAccessProtectedData) {
      return _buildDesktopPreviewLayout(l10n: l10n);
    }

    final canShowFullReport = readinessStatus == ReportReadinessStatus.ready;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top full-width: readiness + metrics + export actions.
        ReportReadinessSection(
          status: readinessStatus,
          generatedAtLabel: generatedAtLabel,
          insufficientMetricCount: _insufficientMetricCount(),
          needsAttentionMetricCount: _needsAttentionMetricCount(),
          l10n: l10n,
          rangeLabel: _rangeLabel(l10n),
          scoreSummary: readinessStatus == ReportReadinessStatus.ready
              ? dashboard.score.summary
              : '',
          onSignIn: onSignIn,
          onContinueRecord: onContinueRecord,
          onGenerate: onGenerateAiSummary == null
              ? null
              : () {
                  onGenerateAiSummary!();
                },
          onSync: onSync,
          isGenerating:
              aiSummaryState.status == ReportAiSummaryCardStatus.loading,
        ),
        const SizedBox(height: Spacing.level5),
        // Dual-column body: left (trend + findings + history) | right (AI + patterns)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReportTrendSection(
                    key: const Key('report-trend-section'),
                    trends: dashboard.trends,
                    selectedQuery: dashboardQuery,
                    onQueryChanged: onDashboardQueryChanged ?? (_) {},
                    l10n: l10n,
                    startDate: dashboard.startDate,
                    showRangePill: false,
                  ),
                  const SizedBox(height: Spacing.level5),
                  ReportFindingsSection(
                    key: const Key('report-findings-section'),
                    findings: dashboard.findings,
                    l10n: l10n,
                  ),
                  if (canAccessProtectedData) ...[
                    const SizedBox(height: Spacing.level5),
                    ReportSuggestionHistorySection(
                      suggestions: suggestionHistory,
                      isLoading: isSuggestionHistoryLoading,
                      onSuggestionTap: onSuggestionTap,
                      l10n: l10n,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: Spacing.level5),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (canShowFullReport) ...[
                    ReportAiSummarySection(
                      key: const Key('report-ai-summary-section'),
                      dashboard: dashboard,
                      canAccessProtectedData: canAccessProtectedData,
                      aiSummariesEnabled: aiSummariesEnabled,
                      aiState: aiSummaryState,
                      selectedRange: aiSummaryRange,
                      onRangeChanged: onAiSummaryRangeChanged,
                      onGenerate: onGenerateAiSummary,
                      l10n: l10n,
                    ),
                    const SizedBox(height: Spacing.level5),
                    ReportPatternsSection(
                      key: const Key('report-patterns-section'),
                      patterns: dashboard.patterns,
                      l10n: l10n,
                    ),
                    const SizedBox(height: Spacing.level5),
                    ReportReferenceNotice(
                      key: const Key('report-reference-notice'),
                      l10n: l10n,
                    ),
                  ],
                  if (!canShowFullReport) ...[
                    const SizedBox(height: Spacing.level4),
                    _ReportLockedFeaturesHint(
                      message:
                          readinessStatus == ReportReadinessStatus.signedOut
                          ? l10n.reportLockedFeaturesSignedOutHint
                          : l10n.reportLockedFeaturesInsufficientHint,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (canShowFullReport) ...[
          const SizedBox(height: Spacing.level5),
          ReportExportSection(
            key: const Key('report-export-section'),
            actions: dashboard.exportActions,
            latestRequest: latestExportRequest,
            requestInFlight: exportRequestInFlight,
            clinicShareInFlight: clinicShareInFlight,
            onActionTap: onExportActionTap,
            l10n: l10n,
            isDataInsufficient:
                readinessStatus == ReportReadinessStatus.insufficient,
          ),
        ],
      ],
    );
  }

  Widget _buildDesktopPreviewLayout({required AppLocalizations l10n}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SignInHintBanner(
          onSignIn: onSignIn,
          message: l10n.reportPreviewBannerMessage,
        ),
        const SizedBox(height: Spacing.level4),
        ReportTrendSection(
          key: const Key('report-trend-section'),
          trends: _previewTrends,
          selectedQuery: dashboardQuery,
          onQueryChanged: onDashboardQueryChanged ?? (_) {},
          l10n: l10n,
          startDate: dashboard.startDate,
          showRangePill: false,
        ),
        const SizedBox(height: Spacing.level4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ReportPreviewLockedSection(
                key: const Key('report-findings-preview-locked'),
                icon: SemanticIcons.aiTip,
                title: l10n.reportFindingsPreviewTitle,
                body: l10n.reportFindingsPreviewBody,
              ),
            ),
            const SizedBox(width: Spacing.level4),
            Expanded(
              child: ReportPreviewLockedSection(
                key: const Key('report-suggestion-history-preview-locked'),
                icon: SemanticIcons.reportHistory,
                title: l10n.reportSuggestionHistoryPreviewTitle,
                body: l10n.reportSuggestionHistoryPreviewBody,
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.level4),
        ReportExportSection(
          key: const Key('report-export-section'),
          actions: _previewExportActions,
          latestRequest: null,
          requestInFlight: const DataExportRequestInFlightState(
            inFlight: false,
          ),
          l10n: l10n,
          onActionTap: null,
        ),
      ],
    );
  }

  int _insufficientMetricCount() {
    return dashboard.metrics
        .where((metric) => metric.status == ReportStatus.insufficientData)
        .length;
  }

  int _needsAttentionMetricCount() {
    return dashboard.metrics
        .where((metric) => metric.status == ReportStatus.needsAttention)
        .length;
  }

  ReportReadinessStatus _readinessStatus() {
    if (isPreview || !canAccessProtectedData) {
      return ReportReadinessStatus.signedOut;
    }
    if (dashboard.metrics.isEmpty ||
        dashboard.score.status == ReportStatus.insufficientData ||
        _insufficientMetricCount() > 0) {
      return ReportReadinessStatus.insufficient;
    }
    return ReportReadinessStatus.ready;
  }

  String _rangeLabel(AppLocalizations l10n) => switch (dashboardQuery.range) {
    ReportDashboardRange.last7Days => l10n.reportRangeLast7Days,
    ReportDashboardRange.last30Days => l10n.reportRangeLast30Days,
    ReportDashboardRange.custom => l10n.reportRangeCustom,
  };

  List<ReportExportAction> get _previewExportActions => const [
    ReportExportAction(
      kind: ReportExportKind.hospital,
      icon: SemanticIcons.medicineKit,
      color: SemanticColor.primary,
    ),
    ReportExportAction(
      kind: ReportExportKind.monthly,
      icon: SemanticIcons.tabReport,
      color: SemanticColor.primary,
    ),
    ReportExportAction(
      kind: ReportExportKind.print,
      icon: SemanticIcons.actionExport,
      color: SemanticColor.primary,
    ),
    ReportExportAction(
      kind: ReportExportKind.clinicShare,
      icon: SemanticIcons.actionShare,
      color: SemanticColor.primary,
    ),
  ];

  List<ReportTrendSeries> get _previewTrends => const [
    ReportTrendSeries(
      kind: ReportDataKind.medication,
      color: SemanticColor.primary,
      unit: '%',
      values: [],
      currentValue: '--',
    ),
    ReportTrendSeries(
      kind: ReportDataKind.water,
      color: SemanticColor.info,
      unit: 'L',
      values: [],
      currentValue: '--',
    ),
    ReportTrendSeries(
      kind: ReportDataKind.sleep,
      color: SemanticColor.warning,
      unit: 'h',
      values: [],
      currentValue: '--',
    ),
  ];
}

class _ReportLockedFeaturesHint extends StatelessWidget {
  const _ReportLockedFeaturesHint({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return FCard(
      child: FTile(
        prefix: FAvatar.raw(
          child: Icon(
            SemanticIcons.statusBlocked,
            color: colors.primary,
            size: Spacing.level4,
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.reportLockedFeaturesTitle,
          style: TypographyToken.level4
              .body(context)
              .copyWith(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(message),
      ),
    );
  }
}
