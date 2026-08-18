// ═══════════════════════════════════════════════════════════════════════════
// LEGACY — 兼容期保留，已不再装配到主路径。
//
// Task 6 起 `/report` 主内容切换为事件优先的 `ReviewView`（review_view.dart），
// 本文件及配套 section/dialog（export、findings、readiness、
// patterns、trend、ai_summary、suggestion_history、preview_empty、
// range_picker_dialog、clinic_summary_preview_dialog）与
// `widgets/shared/top_bar.dart`（7/30 天范围切换）均保留代码但不再被
// `page.dart` 引用。Task 8 会把导出/就诊摘要迁入 More 后评估删除。
//
// 未完成兼容期评估前不要在此新增功能；需要改动 legacy 行为时先与
// Review 主路径的回归测试核对。
// ═══════════════════════════════════════════════════════════════════════════
import 'dart:async';
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
import 'package:luminous/features/report/presentation/widgets/sections/readiness.dart';
import 'package:luminous/features/report/presentation/widgets/sections/suggestion_history.dart';
import 'package:luminous/features/report/presentation/widgets/sections/trend.dart';
import 'package:luminous/features/report/presentation/widgets/shared/reference_notice.dart';
import 'package:luminous/features/report/presentation/widgets/views/dashboard_preview.dart';
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
      return ReportDashboardPreview(
        l10n: l10n,
        dashboardQuery: dashboardQuery,
        onDashboardQueryChanged: onDashboardQueryChanged,
        startDate: dashboard.startDate,
        onSignIn: onSignIn,
        isDesktop: false,
      );
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
          onSignIn: onSignIn,
          onContinueRecord: onContinueRecord,
          onGenerate: onGenerateAiSummary == null
              ? null
              : () {
                  unawaited(onGenerateAiSummary!());
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

  Widget _buildDesktopLayout({required AppLocalizations l10n}) {
    final readinessStatus = _readinessStatus();

    if (isPreview || !canAccessProtectedData) {
      return ReportDashboardPreview(
        l10n: l10n,
        dashboardQuery: dashboardQuery,
        onDashboardQueryChanged: onDashboardQueryChanged,
        startDate: dashboard.startDate,
        onSignIn: onSignIn,
        isDesktop: true,
      );
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
          onSignIn: onSignIn,
          onContinueRecord: onContinueRecord,
          onGenerate: onGenerateAiSummary == null
              ? null
              : () {
                  unawaited(onGenerateAiSummary!());
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
    if (dashboard.metrics.isEmpty || _insufficientMetricCount() > 0) {
      return ReportReadinessStatus.insufficient;
    }
    return ReportReadinessStatus.ready;
  }

  String _rangeLabel(AppLocalizations l10n) => switch (dashboardQuery.range) {
    ReportDashboardRange.last7Days => l10n.reportRangeLast7Days,
    ReportDashboardRange.last30Days => l10n.reportRangeLast30Days,
    ReportDashboardRange.custom => l10n.reportRangeCustom,
  };
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
