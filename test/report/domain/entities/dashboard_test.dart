import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/semantic_color.dart';
import 'package:luminous/features/report/domain/entities/dashboard.dart';

void main() {
  group('ReportDashboardRange', () {
    test('last7Days has correct apiValue', () {
      expect(ReportDashboardRange.last7Days.apiValue, 'last_7_days');
    });

    test('last30Days has correct apiValue', () {
      expect(ReportDashboardRange.last30Days.apiValue, 'last_30_days');
    });

    test('custom has correct apiValue', () {
      expect(ReportDashboardRange.custom.apiValue, 'custom');
    });
  });

  group('ReportDashboardQuery.isCustom', () {
    test('returns true for custom range', () {
      const query = ReportDashboardQuery(range: ReportDashboardRange.custom);
      expect(query.isCustom, isTrue);
    });

    test('returns false for last7Days range', () {
      const query = ReportDashboardQuery(range: ReportDashboardRange.last7Days);
      expect(query.isCustom, isFalse);
    });

    test('returns false for last30Days range', () {
      const query = ReportDashboardQuery(
        range: ReportDashboardRange.last30Days,
      );
      expect(query.isCustom, isFalse);
    });

    test('supports custom start and end dates', () {
      final query = ReportDashboardQuery(
        range: ReportDashboardRange.custom,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 31),
      );
      expect(query.startDate, DateTime(2026, 1, 1));
      expect(query.endDate, DateTime(2026, 1, 31));
    });
  });

  group('ReportDashboard.signedOut', () {
    test('has last7Days range', () {
      expect(ReportDashboard.signedOut().range, ReportDashboardRange.last7Days);
    });

    test('has zero health score', () {
      final dashboard = ReportDashboard.signedOut();
      expect(dashboard.score.value, 0);
      expect(dashboard.score.maxValue, 100);
      expect(dashboard.score.status, ReportStatus.insufficientData);
    });

    test('has empty metrics', () {
      expect(ReportDashboard.signedOut().metrics, isEmpty);
    });

    test('has empty trends', () {
      expect(ReportDashboard.signedOut().trends, isEmpty);
    });

    test('has empty findings', () {
      expect(ReportDashboard.signedOut().findings, isEmpty);
    });

    test('has empty export actions', () {
      expect(ReportDashboard.signedOut().exportActions, isEmpty);
    });

    test('has empty patterns', () {
      expect(ReportDashboard.signedOut().patterns, isEmpty);
    });

    test('has aiSummaryEnabled false', () {
      expect(ReportDashboard.signedOut().aiSummaryEnabled, isFalse);
    });
  });

  group('ReportStatus', () {
    test('has all expected values', () {
      expect(ReportStatus.values, contains(ReportStatus.good));
      expect(ReportStatus.values, contains(ReportStatus.stable));
      expect(ReportStatus.values, contains(ReportStatus.needsAttention));
      expect(ReportStatus.values, contains(ReportStatus.insufficientData));
      expect(ReportStatus.values, contains(ReportStatus.unknown));
    });
  });

  group('ReportDataKind', () {
    test('has all expected values', () {
      expect(ReportDataKind.values, contains(ReportDataKind.medication));
      expect(ReportDataKind.values, contains(ReportDataKind.water));
      expect(ReportDataKind.values, contains(ReportDataKind.sleep));
      expect(ReportDataKind.values, contains(ReportDataKind.general));
    });
  });

  group('ReportExportKind', () {
    test('has all expected values', () {
      expect(ReportExportKind.values, contains(ReportExportKind.hospital));
      expect(ReportExportKind.values, contains(ReportExportKind.monthly));
      expect(ReportExportKind.values, contains(ReportExportKind.print));
      expect(ReportExportKind.values, contains(ReportExportKind.clinicShare));
    });
  });

  test('ReportMetric can carry an observed metric without scalar loss', () {
    const metric = ReportMetric(
      kind: ReportDataKind.sleep,
      icon: Icons.nightlight,
      color: SemanticColor.warning,
      value: '--',
      unit: 'h',
      status: ReportStatus.insufficientData,
      delta: '--',
      direction: ReportMetricDirection.flat,
      sparkline: [],
      observedMetric: ReportObservedMetric(
        value: null,
        state: ReportObservedMetricState.unknown,
        coverage: ReportObservedMetricCoverage.none,
        sources: [ReportObservedMetricSource.manual],
        observedCount: 0,
        expectedCount: null,
        windowStart: '2026-08-05',
        windowEnd: '2026-08-11',
      ),
    );

    expect(metric.value, '--');
    expect(metric.observedMetric?.state, ReportObservedMetricState.unknown);
    expect(metric.observedMetric?.expectedCount, isNull);
  });
}
