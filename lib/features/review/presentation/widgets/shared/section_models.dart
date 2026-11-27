import 'package:forui/forui.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/design/color/semantic_color.dart';
import 'package:luminous/core/errors/user_message.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/domain/entities/digest.dart';
import 'package:luminous/features/settings/presentation/providers/data_export.dart';
import 'package:luminous/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Data export input helper
// ---------------------------------------------------------------------------

DataExportRequestInput? reviewExportInputForKind(ReviewExportKind kind) {
  return switch (kind) {
    ReviewExportKind.monthly => reviewMonthlyPdfExportRequest,
    ReviewExportKind.print => reviewPrintPdfExportRequest,
    ReviewExportKind.hospital => reviewHospitalPdfLast7DaysExportRequest,
    ReviewExportKind.clinicShare => null,
  };
}

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

class ReviewDigestContent {
  const ReviewDigestContent({
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
  final ReviewDigestCoverage? coverage;
  final bool showGenerateButton;
}

// ---------------------------------------------------------------------------
// Shared helper functions
// ---------------------------------------------------------------------------

String reviewStatusLabel(AppLocalizations l10n, ReviewStatus status) {
  return switch (status) {
    ReviewStatus.good => l10n.reviewStatusGood,
    ReviewStatus.stable => l10n.reviewStatusStable,
    ReviewStatus.needsAttention => l10n.reviewStatusNeedsImprove,
    ReviewStatus.insufficientData => l10n.reviewStatusInsufficientData,
    ReviewStatus.unknown => l10n.reviewStatusUnknown,
  };
}

SemanticColor reviewStatusColor(ReviewStatus status) {
  return switch (status) {
    ReviewStatus.good => SemanticColor.success,
    ReviewStatus.stable => SemanticColor.info,
    ReviewStatus.needsAttention => SemanticColor.warning,
    ReviewStatus.insufficientData => SemanticColor.warning,
    ReviewStatus.unknown => SemanticColor.neutral,
  };
}

String reviewMetricTitle(AppLocalizations l10n, ReviewDataKind kind) {
  return switch (kind) {
    ReviewDataKind.medication => l10n.reviewMetricMedicationTitle,
    ReviewDataKind.sleep => l10n.reviewMetricSleepTitle,
    ReviewDataKind.water => l10n.reviewMetricWaterTitle,
    ReviewDataKind.general => l10n.reviewMetricOverallTitle,
  };
}

String reviewExportTitle(AppLocalizations l10n, ReviewExportKind kind) {
  return switch (kind) {
    ReviewExportKind.hospital => l10n.reviewExportHospitalTitle,
    ReviewExportKind.monthly => l10n.reviewExportMonthlyTitle,
    ReviewExportKind.print => l10n.reviewExportPrintTitle,
    ReviewExportKind.clinicShare => l10n.reviewExportClinicShareTitle,
  };
}

String reviewExportSubtitle(AppLocalizations l10n, ReviewExportKind kind) {
  return switch (kind) {
    ReviewExportKind.hospital => l10n.reviewExportHospitalSubtitle,
    ReviewExportKind.monthly => l10n.reviewExportMonthlySubtitle,
    ReviewExportKind.print => l10n.reviewExportPrintSubtitle,
    ReviewExportKind.clinicShare => l10n.reviewExportClinicShareSubtitle,
  };
}

String reviewExportCardSubtitle(
  AppLocalizations l10n,
  ReviewExportKind kind,
  ExportRequestData? latestRequest,
) {
  final input = reviewExportInputForKind(kind);
  if (input == null) {
    return reviewExportSubtitle(l10n, kind);
  }
  if (input.matches(latestRequest)) {
    return switch (dataExportUiStatusForRequest(latestRequest)) {
      DataExportUiStatus.idle => reviewExportSubtitle(l10n, kind),
      DataExportUiStatus.requested => l10n.mineExportStatusRequested,
      DataExportUiStatus.processing => l10n.mineExportStatusPending,
      DataExportUiStatus.completed => l10n.mineExportStatusCompleted,
      DataExportUiStatus.completedLinkMissing =>
        l10n.mineExportStatusLinkMissing,
      DataExportUiStatus.failed => l10n.mineExportStatusFailed,
      DataExportUiStatus.unavailable => l10n.mineExportStatusUnavailable,
    };
  }
  return reviewExportSubtitle(l10n, kind);
}

// ---------------------------------------------------------------------------
// AI summary helpers
// ---------------------------------------------------------------------------

ReviewDigestContent buildReviewDigestContentFromDashboard({
  required AppLocalizations l10n,
  required ReviewDashboard dashboard,
  required bool canAccessProtectedData,
  required bool? digestEnabled,
  required ReviewDigestCardState briefingState,
  required ReviewDigestRange selectedRange,
  required FColors colors,
}) {
  return buildReviewDigestContent(
    l10n: l10n,
    digestEnabled: dashboard.digestEnabled,
    canAccessProtectedData: canAccessProtectedData,
    briefingState: briefingState,
    selectedRange: selectedRange,
    colors: colors,
  );
}

/// Review 主路径用的 AI 总结内容构建函数。
///
/// 与 [buildReviewDigestContentFromDashboard] 的区别：不依赖 [ReviewDashboard] 实体，
/// 只接收 `digestEnabled` 布尔值，适配 Review 页面不一定有 dashboard
/// 数据的场景。
ReviewDigestContent buildReviewDigestContent({
  required AppLocalizations l10n,
  required bool digestEnabled,
  required bool canAccessProtectedData,
  required ReviewDigestCardState briefingState,
  required ReviewDigestRange selectedRange,
  required FColors colors,
}) {
  if (!canAccessProtectedData) {
    return ReviewDigestContent(
      subtitle: l10n.reviewSnapshotHint,
      disclaimer: l10n.authNotSignedIn,
    );
  }

  if (!digestEnabled || briefingState.isDisabled) {
    return ReviewDigestContent(
      subtitle: l10n.reviewSnapshotHint,
      disclaimer: l10n.reviewDigestSummaryDisabledHint,
    );
  }

  final summary = briefingState.summary;
  if (summary != null) {
    return ReviewDigestContent(
      subtitle: reviewDigestSummarySubtitle(l10n, selectedRange),
      summaryText: summary.summary,
      observedPattern: summary.observedPattern?.text,
      lowRiskAction: summary.lowRiskAction?.text,
      disclaimer: summary.disclaimer,
      coverage: summary.coverage,
    );
  }

  if (briefingState.status == ReviewDigestCardStatus.error) {
    return ReviewDigestContent(
      subtitle: reviewDigestSummarySubtitle(l10n, selectedRange),
      // 失败对象在渲染点过一遍错误归一 seam：能取到错误码就用本地化文案，
      // 否则退回服务端下发的 message。
      disclaimer: userMessageFromError(
        briefingState.error,
        l10n: l10n,
        fallback: l10n.reviewDigestSummaryErrorHint,
      ),
      showGenerateButton: digestEnabled,
    );
  }

  if (briefingState.status == ReviewDigestCardStatus.loading) {
    return ReviewDigestContent(
      subtitle: reviewDigestSummarySubtitle(l10n, selectedRange),
      summaryText: briefingState.streamingSummary,
      disclaimer: reviewDigestSummaryGeneratingLabel(l10n, selectedRange),
    );
  }

  return ReviewDigestContent(
    subtitle: l10n.reviewSnapshotHint,
    disclaimer: l10n.reviewDigestSummaryDefaultHint,
    showGenerateButton: digestEnabled,
  );
}

String reviewDigestSummarySubtitle(
  AppLocalizations l10n,
  ReviewDigestRange range,
) {
  return switch (range) {
    ReviewDigestRange.last30Days => l10n.reviewDigestSummarySubtitleLast30Days,
    ReviewDigestRange.custom => l10n.reviewDigestSummarySubtitleCustom,
    ReviewDigestRange.last7Days => l10n.reviewDigestSummarySubtitle,
  };
}

String reviewDigestSummaryGeneratingLabel(
  AppLocalizations l10n,
  ReviewDigestRange range,
) {
  return switch (range) {
    ReviewDigestRange.last30Days =>
      l10n.reviewDigestSummaryGeneratingHintLast30Days,
    ReviewDigestRange.custom => l10n.reviewDigestSummaryGeneratingHintCustom,
    ReviewDigestRange.last7Days => l10n.reviewDigestSummaryGeneratingHint,
  };
}
