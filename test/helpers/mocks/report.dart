// ignore_for_file: prefer_const_constructors
import 'package:clock/clock.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/domain/repositories/dashboard.dart';

/// Test-only mock implementation of [ReviewDashboardRepository].
class MockReviewDashboardRepository implements ReviewDashboardRepository {
  const MockReviewDashboardRepository();

  @override
  Future<ReviewDashboard> get signedOutDashboard =>
      Future.value(_signedOutDashboard);

  @override
  TaskEither<LucentFailure, ReviewDashboard> fetchDashboard(
    ReviewDashboardQuery query,
  ) => TaskEither.right(_dashboardForQuery(query));

  static ReviewDashboard _dashboardForQuery(ReviewDashboardQuery query) {
    final startDate =
        query.startDate ?? clock.now().subtract(const Duration(days: 7));
    final endDate = query.endDate ?? clock.now();
    final startIso = _dateOnly(startDate);
    final endIso = _dateOnly(endDate);
    return previewDashboard.copyWith(
      range: query.range,
      startDate: startIso,
      endDate: endIso,
    );
  }

  static String _dateOnly(DateTime date) {
    final local = date.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }

  static final previewDashboard = ReviewDashboard(
    range: ReviewDashboardRange.last7Days,
    startDate: _dateOnly(clock.now().subtract(const Duration(days: 7))),
    endDate: _dateOnly(clock.now()),
    generatedAt: clock.now().toIso8601String(),
    metrics: <ReviewMetric>[
      ReviewMetric(
        kind: ReviewDataKind.medication,
        iconName: 'tablets',
        color: SemanticColor.primary,
        value: '--',
        unit: '%',
        status: ReviewStatus.stable,
        delta: '--',
        direction: ReviewMetricDirection.flat,
        sparkline: <double>[0, 0, 0, 0, 0, 0, 0],
      ),
      ReviewMetric(
        kind: ReviewDataKind.sleep,
        iconName: 'moon-star',
        color: SemanticColor.primary,
        value: '--',
        unit: 'h',
        status: ReviewStatus.insufficientData,
        delta: '--',
        direction: ReviewMetricDirection.flat,
        sparkline: <double>[0, 0, 0, 0, 0, 0, 0],
      ),
      ReviewMetric(
        kind: ReviewDataKind.water,
        iconName: 'droplets',
        color: SemanticColor.primary,
        value: '--',
        unit: 'L',
        status: ReviewStatus.stable,
        delta: '--',
        direction: ReviewMetricDirection.flat,
        sparkline: <double>[0, 0, 0, 0, 0, 0, 0],
      ),
    ],
    trends: <ReviewTrendSeries>[
      ReviewTrendSeries(
        kind: ReviewDataKind.sleep,
        color: SemanticColor.primary,
        unit: 'h',
        values: <double>[0, 0, 0, 0, 0, 0, 0],
        currentValue: '--',
      ),
      ReviewTrendSeries(
        kind: ReviewDataKind.water,
        color: SemanticColor.primary,
        unit: 'L',
        values: <double>[0, 0, 0, 0, 0, 0, 0],
        currentValue: '--',
      ),
      ReviewTrendSeries(
        kind: ReviewDataKind.medication,
        color: SemanticColor.primary,
        unit: '%',
        values: <double>[0, 0, 0, 0, 0, 0, 0],
        currentValue: '--',
      ),
    ],
    findings: <ReviewFinding>[
      ReviewFinding(
        kind: ReviewInsightKind.general,
        iconName: 'chart-line',
        color: SemanticColor.primary,
        title: 'Preparing report',
        body: 'The latest contract-backed report is loading.',
      ),
    ],
    exportActions: <ReviewExportAction>[
      ReviewExportAction(
        kind: ReviewExportKind.hospital,
        iconName: 'briefcase-medical',
        color: SemanticColor.primary,
      ),
      ReviewExportAction(
        kind: ReviewExportKind.monthly,
        iconName: 'bar-chart',
        color: SemanticColor.primary,
      ),
      ReviewExportAction(
        kind: ReviewExportKind.print,
        iconName: 'arrow-down-to-line',
        color: SemanticColor.primary,
      ),
    ],
    patterns: <ReviewPatternCard>[
      ReviewPatternCard(
        kind: ReviewInsightKind.general,
        iconName: 'chart-line',
        color: SemanticColor.primary,
        title: 'Preparing report',
        status: ReviewStatus.stable,
        body: 'Pattern cards will appear after the latest report loads.',
        sparkline: <double>[0, 0, 0, 0, 0, 0, 0],
      ),
    ],
    aiSummaryEnabled: false,
  );

  static final _signedOutDashboard = ReviewDashboard(
    range: ReviewDashboardRange.last7Days,
    startDate: _dateOnly(clock.now().subtract(const Duration(days: 7))),
    endDate: _dateOnly(clock.now()),
    generatedAt: clock.now().toIso8601String(),
    metrics: <ReviewMetric>[
      ReviewMetric(
        kind: ReviewDataKind.medication,
        iconName: 'tablets',
        color: SemanticColor.primary,
        value: '--',
        unit: '%',
        status: ReviewStatus.insufficientData,
        delta: '--',
        direction: ReviewMetricDirection.flat,
        sparkline: <double>[0, 0, 0, 0, 0, 0, 0],
      ),
      ReviewMetric(
        kind: ReviewDataKind.sleep,
        iconName: 'moon-star',
        color: SemanticColor.primary,
        value: '--',
        unit: 'h',
        status: ReviewStatus.insufficientData,
        delta: '--',
        direction: ReviewMetricDirection.flat,
        sparkline: <double>[0, 0, 0, 0, 0, 0, 0],
      ),
      ReviewMetric(
        kind: ReviewDataKind.water,
        iconName: 'droplets',
        color: SemanticColor.primary,
        value: '--',
        unit: 'L',
        status: ReviewStatus.insufficientData,
        delta: '--',
        direction: ReviewMetricDirection.flat,
        sparkline: <double>[0, 0, 0, 0, 0, 0, 0],
      ),
    ],
    trends: <ReviewTrendSeries>[
      ReviewTrendSeries(
        kind: ReviewDataKind.sleep,
        color: SemanticColor.primary,
        unit: 'h',
        values: <double>[0, 0, 0, 0, 0, 0, 0],
        currentValue: '--',
      ),
      ReviewTrendSeries(
        kind: ReviewDataKind.water,
        color: SemanticColor.primary,
        unit: 'L',
        values: <double>[0, 0, 0, 0, 0, 0, 0],
        currentValue: '--',
      ),
      ReviewTrendSeries(
        kind: ReviewDataKind.medication,
        color: SemanticColor.primary,
        unit: '%',
        values: <double>[0, 0, 0, 0, 0, 0, 0],
        currentValue: '--',
      ),
    ],
    findings: <ReviewFinding>[
      ReviewFinding(
        kind: ReviewInsightKind.general,
        iconName: 'lock',
        color: SemanticColor.primary,
        title: '登录后解锁报告',
        body: '报告会基于你的真实记录生成最近 7 天的聚合结果。',
      ),
    ],
    exportActions: <ReviewExportAction>[
      ReviewExportAction(
        kind: ReviewExportKind.hospital,
        iconName: 'briefcase-medical',
        color: SemanticColor.primary,
      ),
      ReviewExportAction(
        kind: ReviewExportKind.monthly,
        iconName: 'bar-chart',
        color: SemanticColor.primary,
      ),
      ReviewExportAction(
        kind: ReviewExportKind.print,
        iconName: 'arrow-down-to-line',
        color: SemanticColor.primary,
      ),
    ],
    patterns: <ReviewPatternCard>[
      ReviewPatternCard(
        kind: ReviewInsightKind.general,
        iconName: 'lock',
        color: SemanticColor.primary,
        title: '等待登录',
        status: ReviewStatus.insufficientData,
        body: '登录后显示真实模式卡片。',
        sparkline: <double>[0, 0, 0, 0, 0, 0, 0],
      ),
    ],
    aiSummaryEnabled: false,
  );
}
