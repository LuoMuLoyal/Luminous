import 'package:forui/forui.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/design/semantic_color.dart';
import 'package:luminous/features/review/domain/entities/ai_summary.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/settings/presentation/providers/data_export.dart';
import 'package:luminous/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Data export input helper
// ---------------------------------------------------------------------------

DataExportRequestInput? reportExportInputForKind(ReviewExportKind kind) {
  return switch (kind) {
    ReviewExportKind.monthly => reportMonthlyPdfExportRequest,
    ReviewExportKind.print => reportPrintPdfExportRequest,
    ReviewExportKind.hospital => reportHospitalPdfLast7DaysExportRequest,
    ReviewExportKind.clinicShare => null,
  };
}

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

class ReviewAiSummaryContent {
  const ReviewAiSummaryContent({
    required this.subtitle,
    this.summaryText,
    this.observedPattern,
    this.lowRiskAction,
    this.disclaimer,
    this.coverage,
    this.showGenerateButton = false,
  });

  final String subtitle;
  final String? summaryText;
  final String? observedPattern;
  final String? lowRiskAction;
  final String? disclaimer;
  final ReviewAiSummaryCoverage? coverage;
  final bool showGenerateButton;
}

// ---------------------------------------------------------------------------
// Shared helper functions
// ---------------------------------------------------------------------------

String reportStatusLabel(AppLocalizations l10n, ReviewStatus status) {
  return switch (status) {
    ReviewStatus.good => l10n.reviewStatusGood,
    ReviewStatus.stable => l10n.reviewStatusStable,
    ReviewStatus.needsAttention => l10n.reviewStatusNeedsImprove,
    ReviewStatus.insufficientData => l10n.reviewStatusInsufficientData,
    ReviewStatus.unknown => l10n.reviewStatusUnknown,
  };
}

SemanticColor reportStatusColor(ReviewStatus status) {
  return switch (status) {
    ReviewStatus.good => SemanticColor.success,
    ReviewStatus.stable => SemanticColor.info,
    ReviewStatus.needsAttention => SemanticColor.warning,
    ReviewStatus.insufficientData => SemanticColor.warning,
    ReviewStatus.unknown => SemanticColor.neutral,
  };
}

String reportMetricTitle(AppLocalizations l10n, ReviewDataKind kind) {
  return switch (kind) {
    ReviewDataKind.medication => l10n.reviewMetricMedicationTitle,
    ReviewDataKind.sleep => l10n.reviewMetricSleepTitle,
    ReviewDataKind.water => l10n.reviewMetricWaterTitle,
    ReviewDataKind.general => l10n.reviewMetricOverallTitle,
  };
}

String reportExportTitle(AppLocalizations l10n, ReviewExportKind kind) {
  return switch (kind) {
    ReviewExportKind.hospital => l10n.reviewExportHospitalTitle,
    ReviewExportKind.monthly => l10n.reviewExportMonthlyTitle,
    ReviewExportKind.print => l10n.reviewExportPrintTitle,
    ReviewExportKind.clinicShare => l10n.reviewExportClinicShareTitle,
  };
}

String reportExportSubtitle(AppLocalizations l10n, ReviewExportKind kind) {
  return switch (kind) {
    ReviewExportKind.hospital => l10n.reviewExportHospitalSubtitle,
    ReviewExportKind.monthly => l10n.reviewExportMonthlySubtitle,
    ReviewExportKind.print => l10n.reviewExportPrintSubtitle,
    ReviewExportKind.clinicShare => l10n.reviewExportClinicShareSubtitle,
  };
}

String reportExportCardSubtitle(
  AppLocalizations l10n,
  ReviewExportKind kind,
  DataExportRequestDataDto? latestRequest,
) {
  final input = reportExportInputForKind(kind);
  if (input == null) {
    return reportExportSubtitle(l10n, kind);
  }
  if (input.matches(latestRequest)) {
    return switch (dataExportUiStatusForRequest(latestRequest)) {
      DataExportUiStatus.idle => reportExportSubtitle(l10n, kind),
      DataExportUiStatus.requested => l10n.mineExportStatusRequested,
      DataExportUiStatus.processing => l10n.mineExportStatusPending,
      DataExportUiStatus.completed => l10n.mineExportStatusCompleted,
      DataExportUiStatus.completedLinkMissing =>
        l10n.mineExportStatusLinkMissing,
      DataExportUiStatus.failed => l10n.mineExportStatusFailed,
      DataExportUiStatus.unavailable => l10n.mineExportStatusUnavailable,
    };
  }
  return reportExportSubtitle(l10n, kind);
}

// ---------------------------------------------------------------------------
// AI summary helpers
// ---------------------------------------------------------------------------

ReviewAiSummaryContent buildReviewAiSummaryContentFromDashboard({
  required AppLocalizations l10n,
  required ReviewDashboard dashboard,
  required bool canAccessProtectedData,
  required bool? aiSummariesEnabled,
  required ReviewAiSummaryCardState aiState,
  required ReviewAiSummaryRange selectedRange,
  required FColors colors,
}) {
  return buildReviewAiSummaryContent(
    l10n: l10n,
    aiSummaryEnabled: dashboard.aiSummaryEnabled,
    canAccessProtectedData: canAccessProtectedData,
    aiState: aiState,
    selectedRange: selectedRange,
    colors: colors,
  );
}

/// Review 主路径用的 AI 总结内容构建函数。
///
/// 与 [buildReviewAiSummaryContentFromDashboard] 的区别：不依赖 [ReviewDashboard] 实体，
/// 只接收 `aiSummaryEnabled` 布尔值，适配 Review 页面不一定有 dashboard
/// 数据的场景。
ReviewAiSummaryContent buildReviewAiSummaryContent({
  required AppLocalizations l10n,
  required bool aiSummaryEnabled,
  required bool canAccessProtectedData,
  required ReviewAiSummaryCardState aiState,
  required ReviewAiSummaryRange selectedRange,
  required FColors colors,
}) {
  if (!canAccessProtectedData) {
    return ReviewAiSummaryContent(
      subtitle: l10n.reviewSnapshotHint,
      disclaimer: l10n.authNotSignedIn,
    );
  }

  if (!aiSummaryEnabled || aiState.isDisabled) {
    return ReviewAiSummaryContent(
      subtitle: l10n.reviewSnapshotHint,
      disclaimer: l10n.reviewAiSummaryDisabledHint,
    );
  }

  final summary = aiState.summary;
  if (summary != null) {
    return ReviewAiSummaryContent(
      subtitle: reportAiSummarySubtitle(l10n, selectedRange),
      summaryText: summary.summary,
      observedPattern: summary.observedPattern?.text,
      lowRiskAction: summary.lowRiskAction?.text,
      disclaimer: summary.disclaimer,
      coverage: summary.coverage,
    );
  }

  if (aiState.status == ReviewAiSummaryCardStatus.error) {
    return ReviewAiSummaryContent(
      subtitle: reportAiSummarySubtitle(l10n, selectedRange),
      disclaimer: aiState.errorMessage ?? l10n.reviewAiSummaryErrorHint,
      showGenerateButton: aiSummaryEnabled,
    );
  }

  if (aiState.status == ReviewAiSummaryCardStatus.loading) {
    return ReviewAiSummaryContent(
      subtitle: reportAiSummarySubtitle(l10n, selectedRange),
      summaryText: aiState.streamingSummary,
      disclaimer: reportAiSummaryGeneratingLabel(l10n, selectedRange),
    );
  }

  return ReviewAiSummaryContent(
    subtitle: l10n.reviewSnapshotHint,
    disclaimer: l10n.reviewAiSummaryDefaultHint,
    showGenerateButton: aiSummaryEnabled,
  );
}

String reportAiSummarySubtitle(
  AppLocalizations l10n,
  ReviewAiSummaryRange range,
) {
  return switch (range) {
    ReviewAiSummaryRange.last30Days => l10n.reviewAiSummarySubtitleLast30Days,
    ReviewAiSummaryRange.custom => l10n.reviewAiSummarySubtitleCustom,
    ReviewAiSummaryRange.last7Days => l10n.reviewAiSummarySubtitle,
  };
}

String reportAiSummaryGeneratingLabel(
  AppLocalizations l10n,
  ReviewAiSummaryRange range,
) {
  return switch (range) {
    ReviewAiSummaryRange.last30Days =>
      l10n.reviewAiSummaryGeneratingHintLast30Days,
    ReviewAiSummaryRange.custom => l10n.reviewAiSummaryGeneratingHintCustom,
    ReviewAiSummaryRange.last7Days => l10n.reviewAiSummaryGeneratingHint,
  };
}
