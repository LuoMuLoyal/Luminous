import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/design/color/semantic_color.dart';

part 'dashboard.freezed.dart';

enum ReviewDashboardRange {
  last7Days('last_7_days'),
  last30Days('last_30_days'),
  custom('custom');

  const ReviewDashboardRange(this.apiValue);

  final String apiValue;
}

enum ReviewObservedMetricState { observed, unknown }

enum ReviewObservedMetricCoverage { sufficient, partial, none }

enum ReviewObservedMetricSource {
  manual,
  healthPlatform,
  reminderPlan,
  derived,
}

class ReviewObservedMetric {
  const ReviewObservedMetric({
    required this.value,
    required this.state,
    required this.coverage,
    required this.sources,
    required this.observedCount,
    required this.expectedCount,
    required this.windowStart,
    required this.windowEnd,
  });

  final double? value;
  final ReviewObservedMetricState state;
  final ReviewObservedMetricCoverage coverage;
  final List<ReviewObservedMetricSource> sources;
  final int observedCount;
  final int? expectedCount;
  final String windowStart;
  final String windowEnd;
}

@freezed
abstract class ReviewDashboardQuery with _$ReviewDashboardQuery {
  const factory ReviewDashboardQuery({
    required ReviewDashboardRange range,
    DateTime? startDate,
    DateTime? endDate,
  }) = _ReviewDashboardQuery;

  const ReviewDashboardQuery._();

  bool get isCustom => range == ReviewDashboardRange.custom;
}

@freezed
abstract class ReviewDashboard with _$ReviewDashboard {
  const factory ReviewDashboard({
    required ReviewDashboardRange range,
    required String startDate,
    required String endDate,
    required String generatedAt,
    required List<ReviewMetric> metrics,
    required List<ReviewTrendSeries> trends,
    required List<ReviewFinding> findings,
    required List<ReviewExportAction> exportActions,
    required List<ReviewPatternCard> patterns,
    required bool aiSummaryEnabled,
  }) = _ReviewDashboard;

  /// A minimal dashboard for signed-out users with no real or mock data.
  static ReviewDashboard signedOut() => const ReviewDashboard(
    range: ReviewDashboardRange.last7Days,
    startDate: '----.--.--',
    endDate: '----.--.--',
    generatedAt: '',
    metrics: <ReviewMetric>[],
    trends: <ReviewTrendSeries>[],
    findings: <ReviewFinding>[],
    exportActions: <ReviewExportAction>[],
    patterns: <ReviewPatternCard>[],
    aiSummaryEnabled: false,
  );
}

@freezed
abstract class ReviewMetric with _$ReviewMetric {
  const factory ReviewMetric({
    required ReviewDataKind kind,
    required IconData icon,
    required SemanticColor color,
    required String value,
    required String unit,
    required ReviewStatus status,
    required String delta,
    required ReviewMetricDirection direction,
    required List<double> sparkline,
    ReviewObservedMetric? observedMetric,
  }) = _ReviewMetric;
}

enum ReviewMetricDirection { up, down, flat }

@freezed
abstract class ReviewTrendSeries with _$ReviewTrendSeries {
  const factory ReviewTrendSeries({
    required ReviewDataKind kind,
    required SemanticColor color,
    required String unit,
    required List<double> values,
    required String currentValue,
    ReviewObservedMetric? observedMetric,
  }) = _ReviewTrendSeries;
}

@freezed
abstract class ReviewFinding with _$ReviewFinding {
  const factory ReviewFinding({
    required ReviewInsightKind kind,
    required IconData icon,
    required SemanticColor color,
    required String title,
    required String body,
  }) = _ReviewFinding;
}

@freezed
abstract class ReviewExportAction with _$ReviewExportAction {
  const factory ReviewExportAction({
    required ReviewExportKind kind,
    required IconData icon,
    required SemanticColor color,
  }) = _ReviewExportAction;
}

@freezed
abstract class ReviewPatternCard with _$ReviewPatternCard {
  const factory ReviewPatternCard({
    required ReviewInsightKind kind,
    required IconData icon,
    required SemanticColor color,
    required String title,
    required ReviewStatus status,
    required String body,
    required List<double> sparkline,
  }) = _ReviewPatternCard;
}

enum ReviewStatus { good, stable, needsAttention, insufficientData, unknown }

enum ReviewDataKind { medication, water, sleep, general }

enum ReviewInsightKind { medication, hydration, sleep, general }

enum ReviewExportKind { hospital, monthly, print, clinicShare }
