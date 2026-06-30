import 'package:luminous/core/design/app_design.dart';
import 'package:flutter/material.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/features/report/domain/entities/report_ai_summary.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';
import 'package:luminous/features/settings/presentation/providers/data_export_controller.dart';
import 'package:luminous/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Data export input helper
// ---------------------------------------------------------------------------

DataExportRequestInput? reportExportInputForKind(ReportExportKind kind) {
  return switch (kind) {
    ReportExportKind.monthly => reportMonthlyPdfExportRequest,
    ReportExportKind.print => reportPrintPdfExportRequest,
    ReportExportKind.hospital => reportHospitalPdfLast7DaysExportRequest,
    ReportExportKind.clinicShare => null,
  };
}

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

class ReportAiSummaryContent {
  const ReportAiSummaryContent({
    required this.subtitle,
    required this.bullets,
    this.summaryText,
    this.footer,
    this.showGenerateButton = false,
  });

  final String subtitle;
  final List<ReportAiSummaryItem> bullets;
  final String? summaryText;
  final String? footer;
  final bool showGenerateButton;
}

class ReportAiSummaryItem {
  const ReportAiSummaryItem({required this.color, required this.text});

  final Color color;
  final String text;
}

// ---------------------------------------------------------------------------
// Shared helper functions
// ---------------------------------------------------------------------------

String reportStatusLabel(AppLocalizations l10n, ReportStatus status) {
  return switch (status) {
    ReportStatus.good => l10n.reportStatusGood,
    ReportStatus.stable => l10n.reportStatusStable,
    ReportStatus.needsAttention => l10n.reportStatusNeedsImprove,
    ReportStatus.insufficientData => l10n.medicineReminderUnavailableStatus,
    ReportStatus.unknown => l10n.reportStatusStable,
  };
}

Color reportStatusColor(ReportStatus status) {
  return switch (status) {
    ReportStatus.good => AppColorTokens.cyanDeep,
    ReportStatus.stable => AppColorTokens.health,
    ReportStatus.needsAttention => AppColorTokens.warning,
    ReportStatus.insufficientData => AppColorTokens.link,
    ReportStatus.unknown => AppColorTokens.link,
  };
}

String reportMetricTitle(AppLocalizations l10n, ReportDataKind kind) {
  return switch (kind) {
    ReportDataKind.medication => l10n.reportMetricMedicationTitle,
    ReportDataKind.sleep => l10n.reportMetricSleepTitle,
    ReportDataKind.water => l10n.reportMetricWaterTitle,
    ReportDataKind.general => l10n.reportMetricOverallTitle,
  };
}

String reportExportTitle(AppLocalizations l10n, ReportExportKind kind) {
  return switch (kind) {
    ReportExportKind.hospital => l10n.reportExportHospitalTitle,
    ReportExportKind.monthly => l10n.reportExportMonthlyTitle,
    ReportExportKind.print => l10n.reportExportPrintTitle,
    ReportExportKind.clinicShare => l10n.reportExportClinicShareTitle,
  };
}

String reportExportSubtitle(AppLocalizations l10n, ReportExportKind kind) {
  return switch (kind) {
    ReportExportKind.hospital => l10n.reportExportHospitalSubtitle,
    ReportExportKind.monthly => l10n.reportExportMonthlySubtitle,
    ReportExportKind.print => l10n.reportExportPrintSubtitle,
    ReportExportKind.clinicShare => l10n.reportExportClinicShareSubtitle,
  };
}

String reportExportCardSubtitle(
  AppLocalizations l10n,
  ReportExportKind kind,
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

ReportAiSummaryContent buildReportAiSummaryContent({
  required AppLocalizations l10n,
  required ReportDashboard dashboard,
  required bool canAccessProtectedData,
  required bool? aiSummariesEnabled,
  required ReportAiSummaryCardState aiState,
  required ReportAiSummaryRange selectedRange,
}) {
  if (!canAccessProtectedData) {
    return ReportAiSummaryContent(
      subtitle: l10n.reportSnapshotHint,
      bullets: [
        ReportAiSummaryItem(
          color: AppColorTokens.warning,
          text: l10n.authLoginRequiredPrompt,
        ),
      ],
      footer: l10n.authNotSignedIn,
    );
  }

  if (aiSummariesEnabled == false || aiState.isDisabled) {
    return ReportAiSummaryContent(
      subtitle: l10n.reportSnapshotHint,
      bullets: [
        ReportAiSummaryItem(
          color: AppColorTokens.link,
          text: l10n.reportAiSummaryDisabledHint,
        ),
      ],
      footer: l10n.reportAiSummaryDisabledHint,
    );
  }

  final summary = aiState.summary;
  if (summary != null) {
    return ReportAiSummaryContent(
      subtitle: reportAiSummarySubtitle(l10n, selectedRange),
      summaryText: summary.summary,
      bullets: summary.bullets
          .map(
            (bullet) =>
                ReportAiSummaryItem(color: bullet.color, text: bullet.text),
          )
          .toList(growable: false),
      footer: summary.confidenceNote,
    );
  }

  if (aiState.status == ReportAiSummaryCardStatus.error) {
    return ReportAiSummaryContent(
      subtitle: reportAiSummarySubtitle(l10n, selectedRange),
      bullets: [
        ReportAiSummaryItem(
          color: AppColorTokens.warning,
          text: aiState.errorMessage ?? l10n.reportAiSummaryErrorHint,
        ),
        ...reportAiSummaryFallbackBullets(dashboard),
      ],
      footer: aiState.errorMessage ?? l10n.reportAiSummaryErrorHint,
      showGenerateButton: dashboard.aiSummaryEnabled,
    );
  }

  if (aiState.status == ReportAiSummaryCardStatus.loading) {
    return ReportAiSummaryContent(
      subtitle: reportAiSummarySubtitle(l10n, selectedRange),
      summaryText: aiState.streamingSummary,
      bullets: [
        ReportAiSummaryItem(
          color: AppColorTokens.cyanDeep,
          text: reportAiSummaryGeneratingLabel(l10n, selectedRange),
        ),
        ...reportAiSummaryFallbackBullets(dashboard),
      ],
      footer: reportAiSummaryGeneratingLabel(l10n, selectedRange),
    );
  }

  return ReportAiSummaryContent(
    subtitle: l10n.reportSnapshotHint,
    bullets: reportAiSummaryFallbackBullets(dashboard),
    footer: l10n.reportAiSummaryDefaultHint,
    showGenerateButton: dashboard.aiSummaryEnabled,
  );
}

List<ReportAiSummaryItem> reportAiSummaryFallbackBullets(
  ReportDashboard dashboard,
) {
  return [
    ReportAiSummaryItem(
      color: reportStatusColor(dashboard.score.status),
      text: dashboard.score.summary,
    ),
    ...dashboard.findings
        .take(3)
        .map(
          (finding) => ReportAiSummaryItem(
            color: finding.color,
            text: '${finding.title}: ${finding.body}',
          ),
        ),
  ];
}

String reportAiSummarySubtitle(
  AppLocalizations l10n,
  ReportAiSummaryRange range,
) {
  return switch (range) {
    ReportAiSummaryRange.last30Days => l10n.reportAiSummarySubtitleLast30Days,
    ReportAiSummaryRange.custom => l10n.reportAiSummarySubtitleCustom,
    ReportAiSummaryRange.last7Days => l10n.reportAiSummarySubtitle,
  };
}

String reportAiSummaryGeneratingLabel(
  AppLocalizations l10n,
  ReportAiSummaryRange range,
) {
  return switch (range) {
    ReportAiSummaryRange.last30Days =>
      l10n.reportAiSummaryGeneratingHintLast30Days,
    ReportAiSummaryRange.custom => l10n.reportAiSummaryGeneratingHintCustom,
    ReportAiSummaryRange.last7Days => l10n.reportAiSummaryGeneratingHint,
  };
}
