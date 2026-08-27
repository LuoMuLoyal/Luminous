import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/semantic_color.dart';
import 'package:luminous/features/review/domain/entities/ai_summary.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/presentation/widgets/shared/section_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

void main() {
  group('reportStatusColor', () {
    test('statuses map to correct semantic colors', () {
      expect(reportStatusColor(ReviewStatus.good), SemanticColor.success);
      expect(reportStatusColor(ReviewStatus.stable), SemanticColor.info);
      expect(
        reportStatusColor(ReviewStatus.needsAttention),
        SemanticColor.warning,
      );
      expect(
        reportStatusColor(ReviewStatus.insufficientData),
        SemanticColor.warning,
      );
      expect(reportStatusColor(ReviewStatus.unknown), SemanticColor.neutral);
    });
  });

  group('reportStatusLabel', () {
    test('good returns localized status', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(reportStatusLabel(l10n, ReviewStatus.good), l10n.reviewStatusGood);
    });
    test('stable returns localized stable', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(
        reportStatusLabel(l10n, ReviewStatus.stable),
        l10n.reviewStatusStable,
      );
    });
  });

  group('reportMetricTitle', () {
    test('medication returns title', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(
        reportMetricTitle(l10n, ReviewDataKind.medication),
        l10n.reviewMetricMedicationTitle,
      );
    });
  });

  group('reportExportTitle', () {
    test('hospital returns title', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(
        reportExportTitle(l10n, ReviewExportKind.hospital),
        l10n.reviewExportHospitalTitle,
      );
    });
  });

  group('reportAiSummarySubtitle', () {
    test('last7Days returns subtitle', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(
        reportAiSummarySubtitle(l10n, ReviewAiSummaryRange.last7Days),
        l10n.reviewAiSummarySubtitle,
      );
    });
    test('last30Days returns subtitle', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(
        reportAiSummarySubtitle(l10n, ReviewAiSummaryRange.last30Days),
        l10n.reviewAiSummarySubtitleLast30Days,
      );
    });
  });

  group('reportAiSummaryGeneratingLabel', () {
    test('last7Days returns generating hint', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(
        reportAiSummaryGeneratingLabel(l10n, ReviewAiSummaryRange.last7Days),
        l10n.reviewAiSummaryGeneratingHint,
      );
    });
    test('last30Days returns hint', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(
        reportAiSummaryGeneratingLabel(l10n, ReviewAiSummaryRange.last30Days),
        l10n.reviewAiSummaryGeneratingHintLast30Days,
      );
    });
  });
}
