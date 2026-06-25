import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_dashboard.freezed.dart';

enum ReportDashboardRange {
  last7Days('last_7_days'),
  last30Days('last_30_days'),
  custom('custom');

  const ReportDashboardRange(this.apiValue);

  final String apiValue;
}

@freezed
abstract class ReportDashboard with _$ReportDashboard {
  const factory ReportDashboard({
    required ReportDashboardRange range,
    required String startDate,
    required String endDate,
    required ReportHealthScore score,
    required List<ReportMetric> metrics,
    required List<ReportTrendSeries> trends,
    required List<ReportFinding> findings,
    required List<ReportExportAction> exportActions,
    required List<ReportPatternCard> patterns,
    required bool aiSummaryEnabled,
  }) = _ReportDashboard;
}

@freezed
abstract class ReportHealthScore with _$ReportHealthScore {
  const factory ReportHealthScore({
    required int value,
    required int maxValue,
    required ReportStatus status,
    required String summary,
  }) = _ReportHealthScore;
}

@freezed
abstract class ReportMetric with _$ReportMetric {
  const factory ReportMetric({
    required ReportDataKind kind,
    required IconData icon,
    required Color color,
    required String value,
    required String unit,
    required ReportStatus status,
    required String delta,
    required ReportMetricDirection direction,
    required List<double> sparkline,
  }) = _ReportMetric;
}

enum ReportMetricDirection { up, down, flat }

@freezed
abstract class ReportTrendSeries with _$ReportTrendSeries {
  const factory ReportTrendSeries({
    required ReportDataKind kind,
    required Color color,
    required String unit,
    required List<double> values,
    required String currentValue,
  }) = _ReportTrendSeries;
}

@freezed
abstract class ReportFinding with _$ReportFinding {
  const factory ReportFinding({
    required ReportInsightKind kind,
    required IconData icon,
    required Color color,
    required String title,
    required String body,
  }) = _ReportFinding;
}

@freezed
abstract class ReportExportAction with _$ReportExportAction {
  const factory ReportExportAction({
    required ReportExportKind kind,
    required IconData icon,
    required Color color,
  }) = _ReportExportAction;
}

@freezed
abstract class ReportPatternCard with _$ReportPatternCard {
  const factory ReportPatternCard({
    required ReportInsightKind kind,
    required IconData icon,
    required Color color,
    required String title,
    required ReportStatus status,
    required String body,
    required List<double> sparkline,
  }) = _ReportPatternCard;
}

enum ReportStatus { good, stable, needsAttention, insufficientData, unknown }

enum ReportDataKind { medication, water, sleep, general }

enum ReportInsightKind { medication, hydration, sleep, general }

enum ReportExportKind { hospital, monthly, print }
