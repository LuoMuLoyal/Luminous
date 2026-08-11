// The generated contract marks the legacy scalar projection as deprecated.
// Keep this mapper's fallback until the observed metric domain migration lands.
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:lucent_api/lucent_api.dart' as lucent;
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/report/data/datasources/report.dart';
import 'package:luminous/features/report/domain/entities/dashboard.dart';
import 'package:luminous/features/report/domain/repositories/report.dart';

class LucentReportRepository implements ReportRepository {
  LucentReportRepository({required this.dataSource});

  final ReportRemoteDataSource dataSource;

  @override
  Future<ReportDashboard> fetchDashboard(ReportDashboardQuery query) async {
    final dto = await dataSource.fetchDashboard(query);
    final findings = dto.findings.map(_mapFinding).toList(growable: false);
    final score = _mapScore(dto.score);

    return ReportDashboard(
      range: _mapRange(dto.range.value),
      startDate: dto.startDate,
      endDate: dto.endDate,
      generatedAt: dto.generatedAt,
      score: score,
      metrics: dto.metrics.map(_mapMetric).toList(growable: false),
      trends: dto.trends.map(_mapTrend).toList(growable: false),
      findings: findings,
      exportActions: _exportActions,
      patterns: dto.patterns.map(_mapPattern).toList(growable: false),
      aiSummaryEnabled: dto.aiSummaryEnabled,
    );
  }

  ReportHealthScore _mapScore(lucent.ReportDashboardScoreDto dto) {
    return ReportHealthScore(
      value: dto.value.round(),
      maxValue: dto.maxValue.round(),
      status: _mapStatus(dto.status.value),
      summary: dto.summary,
    );
  }

  ReportMetric _mapMetric(lucent.ReportMetricDto dto) {
    final kind = _mapDataKind(dto.kind.value);
    return ReportMetric(
      kind: kind,
      icon: _metricIcon(kind),
      color: _metricColor(kind),
      value: dto.value,
      unit: dto.unit,
      status: _mapStatus(dto.status.value),
      delta: dto.delta,
      direction: _mapDirection(dto.direction.value),
      sparkline: dto.sparkline.map((value) => value.toDouble()).toList(),
    );
  }

  ReportTrendSeries _mapTrend(lucent.ReportTrendDto dto) {
    final kind = _mapDataKind(dto.kind.value);
    return ReportTrendSeries(
      kind: kind,
      color: _metricColor(kind),
      unit: dto.unit,
      values: dto.values.map((value) => value.toDouble()).toList(),
      currentValue: dto.currentValue,
    );
  }

  ReportFinding _mapFinding(lucent.ReportFindingDto dto) {
    final kind = _mapInsightKind(dto.kind.value);
    return ReportFinding(
      kind: kind,
      icon: _insightIcon(kind),
      color: _insightColor(kind),
      title: dto.title,
      body: dto.body,
    );
  }

  ReportPatternCard _mapPattern(lucent.ReportPatternDto dto) {
    final kind = _mapInsightKind(dto.kind.value);
    return ReportPatternCard(
      kind: kind,
      icon: _insightIcon(kind),
      color: _insightColor(kind),
      title: dto.title,
      status: _mapStatus(dto.status.value),
      body: dto.body,
      sparkline: dto.sparkline.map((value) => value.toDouble()).toList(),
    );
  }

  ReportDashboardRange _mapRange(String value) {
    return switch (value) {
      'last_7_days' => ReportDashboardRange.last7Days,
      'last_30_days' => ReportDashboardRange.last30Days,
      'custom' => ReportDashboardRange.custom,
      _ => ReportDashboardRange.last7Days,
    };
  }

  ReportStatus _mapStatus(String value) {
    return switch (value) {
      'good' => ReportStatus.good,
      'stable' => ReportStatus.stable,
      'needs_attention' => ReportStatus.needsAttention,
      'insufficient_data' => ReportStatus.insufficientData,
      _ => ReportStatus.unknown,
    };
  }

  ReportMetricDirection _mapDirection(String value) {
    return switch (value) {
      'up' => ReportMetricDirection.up,
      'down' => ReportMetricDirection.down,
      'flat' => ReportMetricDirection.flat,
      _ => ReportMetricDirection.flat,
    };
  }

  ReportDataKind _mapDataKind(String value) {
    return switch (value) {
      'medication' => ReportDataKind.medication,
      'water' => ReportDataKind.water,
      'sleep' => ReportDataKind.sleep,
      _ => ReportDataKind.general,
    };
  }

  ReportInsightKind _mapInsightKind(String value) {
    return switch (value) {
      'medication' => ReportInsightKind.medication,
      'hydration' => ReportInsightKind.hydration,
      'sleep' => ReportInsightKind.sleep,
      _ => ReportInsightKind.general,
    };
  }

  IconData _metricIcon(ReportDataKind kind) {
    return switch (kind) {
      ReportDataKind.medication => SemanticIcons.recordMedicine,
      ReportDataKind.water => SemanticIcons.recordWater,
      ReportDataKind.sleep => SemanticIcons.recordMoon,
      ReportDataKind.general => SemanticIcons.profileCondition,
    };
  }

  SemanticColor _metricColor(ReportDataKind kind) {
    return switch (kind) {
      ReportDataKind.medication => SemanticColor.primary,
      ReportDataKind.water => SemanticColor.info,
      ReportDataKind.sleep => SemanticColor.warning,
      ReportDataKind.general => SemanticColor.success,
    };
  }

  IconData _insightIcon(ReportInsightKind kind) {
    return switch (kind) {
      ReportInsightKind.medication => SemanticIcons.reportAdherence,
      ReportInsightKind.hydration => SemanticIcons.recordWater,
      ReportInsightKind.sleep => SemanticIcons.recordMoon,
      ReportInsightKind.general => SemanticIcons.reportChart,
    };
  }

  SemanticColor _insightColor(ReportInsightKind kind) {
    return switch (kind) {
      ReportInsightKind.medication => SemanticColor.primary,
      ReportInsightKind.hydration => SemanticColor.info,
      ReportInsightKind.sleep => SemanticColor.warning,
      ReportInsightKind.general => SemanticColor.success,
    };
  }

  @override
  Future<ReportDashboard> get signedOutDashboard =>
      Future.value(ReportDashboard.signedOut());
}

final _exportActions = <ReportExportAction>[
  const ReportExportAction(
    kind: ReportExportKind.hospital,
    icon: SemanticIcons.medicineKit,
    color: SemanticColor.primary,
  ),
  const ReportExportAction(
    kind: ReportExportKind.monthly,
    icon: SemanticIcons.tabReport,
    color: SemanticColor.primary,
  ),
  const ReportExportAction(
    kind: ReportExportKind.print,
    icon: SemanticIcons.actionExport,
    color: SemanticColor.primary,
  ),
  const ReportExportAction(
    kind: ReportExportKind.clinicShare,
    icon: SemanticIcons.actionShare,
    color: SemanticColor.primary,
  ),
];
