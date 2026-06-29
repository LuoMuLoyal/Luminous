import 'package:luminous/core/design/app_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/report/domain/entities/report_ai_summary.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/shared/report_section_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

void main() {
  group('reportStatusColor', () {
    test('good maps to green', () {
      expect(reportStatusColor(ReportStatus.good), AppColorTokens.cyanDeep);
    });
    test('stable maps to previewScore', () {
      expect(reportStatusColor(ReportStatus.stable), AppColorTokens.health);
    });
    test('needsAttention maps to orange', () {
      expect(
        reportStatusColor(ReportStatus.needsAttention),
        AppColorTokens.warning,
      );
    });
    test('insufficientData maps to blue', () {
      expect(
        reportStatusColor(ReportStatus.insufficientData),
        AppColorTokens.link,
      );
    });
    test('unknown maps to blue', () {
      expect(reportStatusColor(ReportStatus.unknown), AppColorTokens.link);
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
