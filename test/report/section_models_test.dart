import 'package:luminous/core/design/semantic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/report/domain/entities/ai_summary.dart';
import 'package:luminous/features/report/domain/entities/dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/shared/section_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

void main() {
  group('reportStatusColor', () {
    test('statuses map to correct semantic colors', () {
      expect(reportStatusColor(ReportStatus.good), SemanticColor.success);
      expect(reportStatusColor(ReportStatus.stable), SemanticColor.info);
      expect(
        reportStatusColor(ReportStatus.needsAttention),
        SemanticColor.warning,
      );
      expect(
        reportStatusColor(ReportStatus.insufficientData),
        SemanticColor.warning,
      );
      expect(reportStatusColor(ReportStatus.unknown), SemanticColor.neutral);
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
