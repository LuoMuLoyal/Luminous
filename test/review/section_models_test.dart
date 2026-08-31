import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/color/semantic_color.dart';
import 'package:luminous/features/review/domain/entities/ai_summary.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/presentation/widgets/shared/section_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

void main() {
  group('reviewStatusColor', () {
    test('statuses map to correct semantic colors', () {
      expect(reviewStatusColor(ReviewStatus.good), SemanticColor.success);
      expect(reviewStatusColor(ReviewStatus.stable), SemanticColor.info);
      expect(
        reviewStatusColor(ReviewStatus.needsAttention),
        SemanticColor.warning,
      );
      expect(
        reviewStatusColor(ReviewStatus.insufficientData),
        SemanticColor.warning,
      );
      expect(reviewStatusColor(ReviewStatus.unknown), SemanticColor.neutral);
    });
  });

  group('reviewStatusLabel', () {
    test('good returns localized status', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(reviewStatusLabel(l10n, ReviewStatus.good), l10n.reviewStatusGood);
    });
    test('stable returns localized stable', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(
        reviewStatusLabel(l10n, ReviewStatus.stable),
        l10n.reviewStatusStable,
      );
    });
  });

  group('reviewMetricTitle', () {
    test('medication returns title', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(
        reviewMetricTitle(l10n, ReviewDataKind.medication),
        l10n.reviewMetricMedicationTitle,
      );
    });
  });

  group('reviewExportTitle', () {
    test('hospital returns title', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(
        reviewExportTitle(l10n, ReviewExportKind.hospital),
        l10n.reviewExportHospitalTitle,
      );
    });
  });

  group('reviewAiSummarySubtitle', () {
    test('last7Days returns subtitle', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(
        reviewAiSummarySubtitle(l10n, ReviewAiSummaryRange.last7Days),
        l10n.reviewAiSummarySubtitle,
      );
    });
    test('last30Days returns subtitle', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(
        reviewAiSummarySubtitle(l10n, ReviewAiSummaryRange.last30Days),
        l10n.reviewAiSummarySubtitleLast30Days,
      );
    });
  });

  group('reviewAiSummaryGeneratingLabel', () {
    test('last7Days returns generating hint', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(
        reviewAiSummaryGeneratingLabel(l10n, ReviewAiSummaryRange.last7Days),
        l10n.reviewAiSummaryGeneratingHint,
      );
    });
    test('last30Days returns hint', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(
        reviewAiSummaryGeneratingLabel(l10n, ReviewAiSummaryRange.last30Days),
        l10n.reviewAiSummaryGeneratingHintLast30Days,
      );
    });
  });
}
