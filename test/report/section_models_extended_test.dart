import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/api/export.dart';
import 'package:luminous/core/design/semantic_color.dart';
import 'package:luminous/features/report/domain/entities/dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/shared/section_models.dart';

void main() {
  // ── reportExportInputForKind ──────────────────────────────────
  group('reportExportInputForKind', () {
    test('returns hospital request for hospital kind', () {
      final input = reportExportInputForKind(ReportExportKind.hospital);
      expect(input, isNotNull);
      expect(input!.kind, CreateDataExportRequestDtoKindKind.hospital);
      expect(input.format, CreateDataExportRequestDtoFormatFormat.pdf);
      expect(input.range, CreateDataExportRequestDtoRangeRange.last7Days);
    });

    test('returns monthly request for monthly kind', () {
      final input = reportExportInputForKind(ReportExportKind.monthly);
      expect(input, isNotNull);
      expect(input!.kind, CreateDataExportRequestDtoKindKind.monthly);
      expect(input.format, CreateDataExportRequestDtoFormatFormat.pdf);
      expect(input.range, CreateDataExportRequestDtoRangeRange.last30Days);
    });

    test('returns print request for print kind', () {
      final input = reportExportInputForKind(ReportExportKind.print);
      expect(input, isNotNull);
      expect(input!.kind, CreateDataExportRequestDtoKindKind.print);
      expect(input.format, CreateDataExportRequestDtoFormatFormat.pdf);
      expect(input.range, CreateDataExportRequestDtoRangeRange.last7Days);
    });

    test('returns null for clinicShare kind', () {
      final input = reportExportInputForKind(ReportExportKind.clinicShare);
      expect(input, isNull);
    });

    test('returns correct request for all enum values', () {
      for (final kind in ReportExportKind.values) {
        final input = reportExportInputForKind(kind);
        if (kind == ReportExportKind.clinicShare) {
          expect(input, isNull, reason: 'clinicShare should return null');
        } else {
          expect(
            input,
            isNotNull,
            reason: '$kind should return non-null input',
          );
        }
      }
    });
  });

  // ── reportAiSummaryFallbackBullets ────────────────────────────
  group('reportAiSummaryFallbackBullets', () {
    test('returns score bullet plus findings when dashboard has findings', () {
      final dashboard = const ReportDashboard(
        range: ReportDashboardRange.last7Days,
        startDate: '2026-07-08',
        endDate: '2026-07-14',
        generatedAt: '2026-07-14T10:00:00Z',
        score: ReportHealthScore(
          value: 85,
          maxValue: 100,
          status: ReportStatus.good,
          summary: 'Overall good health',
        ),
        metrics: <ReportMetric>[],
        trends: <ReportTrendSeries>[],
        findings: [
          ReportFinding(
            kind: ReportInsightKind.medication,
            icon: Icons.medication,
            color: SemanticColor.success,
            title: 'Medication',
            body: 'Consistent adherence',
          ),
          ReportFinding(
            kind: ReportInsightKind.hydration,
            icon: Icons.water_drop,
            color: SemanticColor.info,
            title: 'Hydration',
            body: 'Slightly below target',
          ),
        ],
        exportActions: <ReportExportAction>[],
        patterns: <ReportPatternCard>[],
        aiSummaryEnabled: false,
      );

      final bullets = reportAiSummaryFallbackBullets(dashboard);

      // First bullet is the score summary
      expect(bullets, hasLength(3));
      expect(bullets[0].color, SemanticColor.success);
      expect(bullets[0].text, 'Overall good health');

      // Second and third bullets are findings (take(3) but only 2 findings)
      expect(bullets[1].color, SemanticColor.success);
      expect(bullets[1].text, 'Medication: Consistent adherence');

      expect(bullets[2].color, SemanticColor.info);
      expect(bullets[2].text, 'Hydration: Slightly below target');
    });

    test('takes at most 3 findings', () {
      final dashboard = const ReportDashboard(
        range: ReportDashboardRange.last7Days,
        startDate: '2026-07-08',
        endDate: '2026-07-14',
        generatedAt: '2026-07-14T10:00:00Z',
        score: ReportHealthScore(
          value: 70,
          maxValue: 100,
          status: ReportStatus.needsAttention,
          summary: 'Needs improvement',
        ),
        metrics: <ReportMetric>[],
        trends: <ReportTrendSeries>[],
        findings: [
          ReportFinding(
            kind: ReportInsightKind.medication,
            icon: Icons.medication,
            color: SemanticColor.warning,
            title: 'Finding 1',
            body: 'Body 1',
          ),
          ReportFinding(
            kind: ReportInsightKind.hydration,
            icon: Icons.water_drop,
            color: SemanticColor.warning,
            title: 'Finding 2',
            body: 'Body 2',
          ),
          ReportFinding(
            kind: ReportInsightKind.sleep,
            icon: Icons.bedtime,
            color: SemanticColor.warning,
            title: 'Finding 3',
            body: 'Body 3',
          ),
          ReportFinding(
            kind: ReportInsightKind.general,
            icon: Icons.lightbulb,
            color: SemanticColor.warning,
            title: 'Finding 4',
            body: 'Body 4 (should be excluded)',
          ),
        ],
        exportActions: <ReportExportAction>[],
        patterns: <ReportPatternCard>[],
        aiSummaryEnabled: false,
      );

      final bullets = reportAiSummaryFallbackBullets(dashboard);

      // Score bullet + at most 3 findings = 4 total
      expect(bullets, hasLength(4));
      expect(bullets[0].text, 'Needs improvement');
      expect(bullets[1].text, 'Finding 1: Body 1');
      expect(bullets[2].text, 'Finding 2: Body 2');
      expect(bullets[3].text, 'Finding 3: Body 3');
    });

    test('returns only score bullet when findings is empty', () {
      final dashboard = const ReportDashboard(
        range: ReportDashboardRange.last7Days,
        startDate: '2026-07-08',
        endDate: '2026-07-14',
        generatedAt: '2026-07-14T10:00:00Z',
        score: ReportHealthScore(
          value: 90,
          maxValue: 100,
          status: ReportStatus.good,
          summary: 'Excellent health',
        ),
        metrics: <ReportMetric>[],
        trends: <ReportTrendSeries>[],
        findings: <ReportFinding>[],
        exportActions: <ReportExportAction>[],
        patterns: <ReportPatternCard>[],
        aiSummaryEnabled: false,
      );

      final bullets = reportAiSummaryFallbackBullets(dashboard);

      expect(bullets, hasLength(1));
      expect(bullets[0].color, SemanticColor.success);
      expect(bullets[0].text, 'Excellent health');
    });

    test('uses score status color for first bullet', () {
      final statuses = [
        (ReportStatus.good, SemanticColor.success),
        (ReportStatus.stable, SemanticColor.info),
        (ReportStatus.needsAttention, SemanticColor.warning),
        (ReportStatus.insufficientData, SemanticColor.warning),
        (ReportStatus.unknown, SemanticColor.neutral),
      ];

      for (final (status, expectedColor) in statuses) {
        final dashboard = ReportDashboard(
          range: ReportDashboardRange.last7Days,
          startDate: '2026-07-08',
          endDate: '2026-07-14',
          generatedAt: '2026-07-14T10:00:00Z',
          score: ReportHealthScore(
            value: 50,
            maxValue: 100,
            status: status,
            summary: 'Summary for $status',
          ),
          metrics: const <ReportMetric>[],
          trends: const <ReportTrendSeries>[],
          findings: const <ReportFinding>[],
          exportActions: const <ReportExportAction>[],
          patterns: const <ReportPatternCard>[],
          aiSummaryEnabled: false,
        );

        final bullets = reportAiSummaryFallbackBullets(dashboard);
        expect(bullets[0].color, expectedColor, reason: 'Status $status');
      }
    });

    test('works with signedOut dashboard', () {
      final dashboard = ReportDashboard.signedOut();

      final bullets = reportAiSummaryFallbackBullets(dashboard);

      expect(bullets, hasLength(1));
      expect(bullets[0].text, isEmpty);
      expect(bullets[0].color, SemanticColor.warning);
    });
  });
}
