import 'package:flutter/material.dart';

class ReportDashboard {
  const ReportDashboard({
    required this.score,
    required this.metrics,
    required this.trends,
    required this.findings,
    required this.summary,
    required this.exportActions,
    required this.patterns,
    required this.aiSummaryEnabled,
  });

  final ReportHealthScore score;
  final List<ReportMetric> metrics;
  final List<ReportTrendSeries> trends;
  final List<ReportFinding> findings;
  final ReportSummary summary;
  final List<ReportExportAction> exportActions;
  final List<ReportPatternCard> patterns;
  final bool aiSummaryEnabled;
}

class ReportHealthScore {
  const ReportHealthScore({
    required this.value,
    required this.maxValue,
    required this.status,
    required this.summary,
  });

  final int value;
  final int maxValue;
  final ReportStatus status;
  final String summary;
}

class ReportMetric {
  const ReportMetric({
    required this.kind,
    required this.icon,
    required this.color,
    required this.value,
    required this.unit,
    required this.status,
    required this.delta,
    required this.direction,
    required this.sparkline,
  });

  final ReportDataKind kind;
  final IconData icon;
  final Color color;
  final String value;
  final String unit;
  final ReportStatus status;
  final String delta;
  final ReportMetricDirection direction;
  final List<double> sparkline;
}

enum ReportMetricDirection { up, down, flat }

class ReportTrendSeries {
  const ReportTrendSeries({
    required this.kind,
    required this.color,
    required this.unit,
    required this.values,
    required this.currentValue,
  });

  final ReportDataKind kind;
  final Color color;
  final String unit;
  final List<double> values;
  final String currentValue;
}

class ReportFinding {
  const ReportFinding({
    required this.kind,
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final ReportInsightKind kind;
  final IconData icon;
  final Color color;
  final String title;
  final String body;
}

class ReportSummary {
  const ReportSummary({
    required this.mode,
    required this.bullets,
  });

  final ReportSummaryMode mode;
  final List<ReportSummaryBullet> bullets;
}

class ReportSummaryBullet {
  const ReportSummaryBullet({required this.color, required this.body});

  final Color color;
  final String body;
}

class ReportExportAction {
  const ReportExportAction({
    required this.kind,
    required this.icon,
    required this.color,
  });

  final ReportExportKind kind;
  final IconData icon;
  final Color color;
}

class ReportPatternCard {
  const ReportPatternCard({
    required this.kind,
    required this.icon,
    required this.color,
    required this.title,
    required this.status,
    required this.body,
    required this.sparkline,
  });

  final ReportInsightKind kind;
  final IconData icon;
  final Color color;
  final String title;
  final ReportStatus status;
  final String body;
  final List<double> sparkline;
}

enum ReportStatus { good, stable, needsAttention, insufficientData, unknown }

enum ReportDataKind { medication, water, sleep, general }

enum ReportInsightKind { medication, hydration, sleep, general }

enum ReportSummaryMode { ai, current, loading }

enum ReportExportKind { hospital, monthly, print }
