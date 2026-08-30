// ═══════════════════════════════════════════════════════════════════════════
// LEGACY — 兼容期保留，已不再装配到主路径。
//
// Task 6 起 `/review` 主内容切换为事件优先的 `ReviewView`（review_view.dart），
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
import 'package:luminous/features/review/domain/entities/ai_summary.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/presentation/widgets/sections/ai_summary.dart';
import 'package:luminous/features/review/presentation/widgets/sections/export.dart';
import 'package:luminous/features/review/presentation/widgets/sections/findings.dart';
import 'package:luminous/features/review/presentation/widgets/sections/patterns.dart';
import 'package:luminous/features/review/presentation/widgets/sections/readiness.dart';
import 'package:luminous/features/review/presentation/widgets/sections/suggestion_history.dart';
import 'package:luminous/features/review/presentation/widgets/sections/trend.dart';
import 'package:luminous/features/review/presentation/widgets/shared/reference_notice.dart';
import 'package:luminous/features/review/presentation/widgets/views/dashboard_preview.dart';
import 'package:luminous/features/settings/presentation/providers/data_export.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReviewDashboardView extends StatelessWidget {
  const ReviewDashboardView({
    super.key,
    required this.dashboard,
    required this.canAccessProtectedData,
    this.aiSummariesEnabled,
    this.isLoading = false,
    this.dashboardQuery = const ReviewDashboardQuery(
      range: ReviewDashboardRange.last7Days,
    ),
    this.onDashboardQueryChanged,
    this.aiSummaryState = const ReviewAiSummaryCardState.idle(),
    this.aiSummaryRange = ReviewAiSummaryRange.last7Days,
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

  final ReviewDashboard dashboard;
  final bool canAccessProtectedData;
  final bool? aiSummariesEnabled;
  final bool isLoading;
  final ReviewDashboardQuery dashboardQuery;
  final ValueChanged<ReviewDashboardQuery>? onDashboardQueryChanged;
  final ReviewAiSummaryCardState aiSummaryState;
  final ReviewAiSummaryRange aiSummaryRange;
  final ValueChanged<ReviewAiSummaryRange>? onAiSummaryRangeChanged;
  final Future<void> Function()? onGenerateAiSummary;
  final Future<void> Function(ReviewExportKind kind)? onExportActionTap;
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
    final canShowFullReview = readinessStatus == ReviewReadinessStatus.ready;

    if (isPreview || !canAccessProtectedData) {
      return ReviewDashboardPreview(
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
        ReviewReadinessSection(
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
              aiSummaryState.status == ReviewAiSummaryCardStatus.loading,
        ),
        const SizedBox(height: Spacing.level5),
        ReviewTrendSection(
          key: const Key('report-trend-section'),
          trends: dashboard.trends,
          selectedQuery: dashboardQuery,
          onQueryChanged: onDashboardQueryChanged ?? (_) {},
          l10n: l10n,
          startDate: dashboard.startDate,
          showRangePill: false,
        ),
        const SizedBox(height: Spacing.level5),
        ReviewFindingsSection(
          key: const Key('report-findings-section'),
          findings: dashboard.findings,
          l10n: l10n,
        ),
        if (canAccessProtectedData) ...[
          const SizedBox(height: Spacing.level5),
          ReviewSuggestionHistorySection(
            suggestions: suggestionHistory,
            isLoading: isSuggestionHistoryLoading,
            onSuggestionTap: onSuggestionTap,
            l10n: l10n,
          ),
        ],
        if (!canShowFullReview) ...[
          const SizedBox(height: Spacing.level5),
          _ReportLockedFeaturesHint(
            message: readinessStatus == ReviewReadinessStatus.signedOut
                ? l10n.reviewLockedFeaturesSignedOutHint
                : l10n.reviewLockedFeaturesInsufficientHint,
          ),
        ],
        if (canShowFullReview) ...[
          const SizedBox(height: Spacing.level5),
          ReviewAiSummarySection(
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
          ReviewPatternsSection(
            key: const Key('report-patterns-section'),
            patterns: dashboard.patterns,
            l10n: l10n,
          ),
          const SizedBox(height: Spacing.level5),
          ReviewExportSection(
            key: const Key('report-export-section'),
            actions: dashboard.exportActions,
            latestRequest: latestExportRequest,
            requestInFlight: exportRequestInFlight,
            clinicShareInFlight: clinicShareInFlight,
            onActionTap: onExportActionTap,
            l10n: l10n,
          ),
          const SizedBox(height: Spacing.level5),
          ReviewReferenceNotice(
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
      return ReviewDashboardPreview(
        l10n: l10n,
        dashboardQuery: dashboardQuery,
        onDashboardQueryChanged: onDashboardQueryChanged,
        startDate: dashboard.startDate,
        onSignIn: onSignIn,
        isDesktop: true,
      );
    }

    final canShowFullReview = readinessStatus == ReviewReadinessStatus.ready;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top full-width: readiness + metrics + export actions.
        ReviewReadinessSection(
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
              aiSummaryState.status == ReviewAiSummaryCardStatus.loading,
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
                  ReviewTrendSection(
                    key: const Key('report-trend-section'),
                    trends: dashboard.trends,
                    selectedQuery: dashboardQuery,
                    onQueryChanged: onDashboardQueryChanged ?? (_) {},
                    l10n: l10n,
                    startDate: dashboard.startDate,
                    showRangePill: false,
                  ),
                  const SizedBox(height: Spacing.level5),
                  ReviewFindingsSection(
                    key: const Key('report-findings-section'),
                    findings: dashboard.findings,
                    l10n: l10n,
                  ),
                  if (canAccessProtectedData) ...[
                    const SizedBox(height: Spacing.level5),
                    ReviewSuggestionHistorySection(
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
                  if (canShowFullReview) ...[
                    ReviewAiSummarySection(
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
                    ReviewPatternsSection(
                      key: const Key('report-patterns-section'),
                      patterns: dashboard.patterns,
                      l10n: l10n,
                    ),
                    const SizedBox(height: Spacing.level5),
                    ReviewReferenceNotice(
                      key: const Key('report-reference-notice'),
                      l10n: l10n,
                    ),
                  ],
                  if (!canShowFullReview) ...[
                    const SizedBox(height: Spacing.level4),
                    _ReportLockedFeaturesHint(
                      message:
                          readinessStatus == ReviewReadinessStatus.signedOut
                          ? l10n.reviewLockedFeaturesSignedOutHint
                          : l10n.reviewLockedFeaturesInsufficientHint,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (canShowFullReview) ...[
          const SizedBox(height: Spacing.level5),
          ReviewExportSection(
            key: const Key('report-export-section'),
            actions: dashboard.exportActions,
            latestRequest: latestExportRequest,
            requestInFlight: exportRequestInFlight,
            clinicShareInFlight: clinicShareInFlight,
            onActionTap: onExportActionTap,
            l10n: l10n,
            isDataInsufficient:
                readinessStatus == ReviewReadinessStatus.insufficient,
          ),
        ],
      ],
    );
  }

  int _insufficientMetricCount() {
    return dashboard.metrics
        .where((metric) => metric.status == ReviewStatus.insufficientData)
        .length;
  }

  int _needsAttentionMetricCount() {
    return dashboard.metrics
        .where((metric) => metric.status == ReviewStatus.needsAttention)
        .length;
  }

  ReviewReadinessStatus _readinessStatus() {
    if (isPreview || !canAccessProtectedData) {
      return ReviewReadinessStatus.signedOut;
    }
    if (dashboard.metrics.isEmpty || _insufficientMetricCount() > 0) {
      return ReviewReadinessStatus.insufficient;
    }
    return ReviewReadinessStatus.ready;
  }

  String _rangeLabel(AppLocalizations l10n) => switch (dashboardQuery.range) {
    ReviewDashboardRange.last7Days => l10n.reviewRangeLast7Days,
    ReviewDashboardRange.last30Days => l10n.reviewRangeLast30Days,
    ReviewDashboardRange.custom => l10n.reviewRangeCustom,
  };
}

class _ReportLockedFeaturesHint extends StatelessWidget {
  const _ReportLockedFeaturesHint({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return FCard(
      child: FTile(
        prefix: FAvatar.raw(
          child: Icon(
            SemanticIcons.statusBlocked,
            color: SemanticColor.primary.solid(context),
            size: Spacing.level4,
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.reviewLockedFeaturesTitle,
          style: context.theme.typography.body.sm.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(message),
      ),
    );
  }
}
