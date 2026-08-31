import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/color/semantic_color.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';

void main() {
  group('ReviewDashboardRange', () {
    test('last7Days has correct apiValue', () {
      expect(ReviewDashboardRange.last7Days.apiValue, 'last_7_days');
    });

    test('last30Days has correct apiValue', () {
      expect(ReviewDashboardRange.last30Days.apiValue, 'last_30_days');
    });

    test('custom has correct apiValue', () {
      expect(ReviewDashboardRange.custom.apiValue, 'custom');
    });
  });

  group('ReviewDashboardQuery.isCustom', () {
    test('returns true for custom range', () {
      const query = ReviewDashboardQuery(range: ReviewDashboardRange.custom);
      expect(query.isCustom, isTrue);
    });

    test('returns false for last7Days range', () {
      const query = ReviewDashboardQuery(range: ReviewDashboardRange.last7Days);
      expect(query.isCustom, isFalse);
    });

    test('returns false for last30Days range', () {
      const query = ReviewDashboardQuery(
        range: ReviewDashboardRange.last30Days,
      );
      expect(query.isCustom, isFalse);
    });

    test('supports custom start and end dates', () {
      final query = ReviewDashboardQuery(
        range: ReviewDashboardRange.custom,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 31),
      );
      expect(query.startDate, DateTime(2026, 1, 1));
      expect(query.endDate, DateTime(2026, 1, 31));
    });
  });

  group('ReviewDashboard.signedOut', () {
    test('has last7Days range', () {
      expect(ReviewDashboard.signedOut().range, ReviewDashboardRange.last7Days);
    });

    test('has empty metrics', () {
      expect(ReviewDashboard.signedOut().metrics, isEmpty);
    });

    test('has empty trends', () {
      expect(ReviewDashboard.signedOut().trends, isEmpty);
    });

    test('has empty findings', () {
      expect(ReviewDashboard.signedOut().findings, isEmpty);
    });

    test('has empty export actions', () {
      expect(ReviewDashboard.signedOut().exportActions, isEmpty);
    });

    test('has empty patterns', () {
      expect(ReviewDashboard.signedOut().patterns, isEmpty);
    });

    test('has aiSummaryEnabled false', () {
      expect(ReviewDashboard.signedOut().aiSummaryEnabled, isFalse);
    });
  });

  group('ReviewStatus', () {
    test('has all expected values', () {
      expect(ReviewStatus.values, contains(ReviewStatus.good));
      expect(ReviewStatus.values, contains(ReviewStatus.stable));
      expect(ReviewStatus.values, contains(ReviewStatus.needsAttention));
      expect(ReviewStatus.values, contains(ReviewStatus.insufficientData));
      expect(ReviewStatus.values, contains(ReviewStatus.unknown));
    });
  });

  group('ReviewDataKind', () {
    test('has all expected values', () {
      expect(ReviewDataKind.values, contains(ReviewDataKind.medication));
      expect(ReviewDataKind.values, contains(ReviewDataKind.water));
      expect(ReviewDataKind.values, contains(ReviewDataKind.sleep));
      expect(ReviewDataKind.values, contains(ReviewDataKind.general));
    });
  });

  group('ReviewExportKind', () {
    test('has all expected values', () {
      expect(ReviewExportKind.values, contains(ReviewExportKind.hospital));
      expect(ReviewExportKind.values, contains(ReviewExportKind.monthly));
      expect(ReviewExportKind.values, contains(ReviewExportKind.print));
      expect(ReviewExportKind.values, contains(ReviewExportKind.clinicShare));
    });
  });

  test('ReviewMetric can carry an observed metric without scalar loss', () {
    const metric = ReviewMetric(
      kind: ReviewDataKind.sleep,
      icon: Icons.nightlight,
      color: SemanticColor.warning,
      value: '--',
      unit: 'h',
      status: ReviewStatus.insufficientData,
      delta: '--',
      direction: ReviewMetricDirection.flat,
      sparkline: [],
      observedMetric: ReviewObservedMetric(
        value: null,
        state: ReviewObservedMetricState.unknown,
        coverage: ReviewObservedMetricCoverage.none,
        sources: [ReviewObservedMetricSource.manual],
        observedCount: 0,
        expectedCount: null,
        windowStart: '2026-08-05',
        windowEnd: '2026-08-11',
      ),
    );

    expect(metric.value, '--');
    expect(metric.observedMetric?.state, ReviewObservedMetricState.unknown);
    expect(metric.observedMetric?.expectedCount, isNull);
  });
}
