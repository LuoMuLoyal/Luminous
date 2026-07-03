import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/features/report/domain/entities/report_ai_summary.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/shared/report_section_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

void main() {
  group('reportStatusColor', () {
    final colors = FThemes.neutral.light.touch.colors;
    test('all statuses map to primary', () {
      expect(reportStatusColor(ReportStatus.good), colors.primary);
      expect(reportStatusColor(ReportStatus.stable), colors.primary);
      expect(reportStatusColor(ReportStatus.needsAttention), colors.primary);
      expect(reportStatusColor(ReportStatus.insufficientData), colors.primary);
      expect(reportStatusColor(ReportStatus.unknown), colors.primary);
    });
  });

  group('reportStatusLabel', () {
    test('good returns localized status', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(reportStatusLabel(l10n, ReportStatus.good), l10n.reportStatusGood);
    });
    test('stable returns localized stable', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(
        reportStatusLabel(l10n, ReportStatus.stable),
        l10n.reportStatusStable,
      );
    });
  });

  group('reportMetricTitle', () {
    test('medication returns title', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(
        reportMetricTitle(l10n, ReportDataKind.medication),
        l10n.reportMetricMedicationTitle,
      );
    });
  });

  group('reportExportTitle', () {
    test('hospital returns title', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(
        reportExportTitle(l10n, ReportExportKind.hospital),
        l10n.reportExportHospitalTitle,
      );
    });
  });

  group('reportAiSummarySubtitle', () {
    test('last7Days returns subtitle', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(
        reportAiSummarySubtitle(l10n, ReportAiSummaryRange.last7Days),
        l10n.reportAiSummarySubtitle,
      );
    });
    test('last30Days returns subtitle', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(
        reportAiSummarySubtitle(l10n, ReportAiSummaryRange.last30Days),
        l10n.reportAiSummarySubtitleLast30Days,
      );
    });
  });

  group('reportAiSummaryGeneratingLabel', () {
    test('last7Days returns generating hint', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(
        reportAiSummaryGeneratingLabel(l10n, ReportAiSummaryRange.last7Days),
        l10n.reportAiSummaryGeneratingHint,
      );
    });
    test('last30Days returns hint', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(
        reportAiSummaryGeneratingLabel(l10n, ReportAiSummaryRange.last30Days),
        l10n.reportAiSummaryGeneratingHintLast30Days,
      );
    });
  });
}
