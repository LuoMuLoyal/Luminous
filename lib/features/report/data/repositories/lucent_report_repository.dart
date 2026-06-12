import 'package:flutter/material.dart';
import 'package:lucent_openapi/lucent_openapi.dart' as lucent;
import 'package:luminous/core/design/app_color_tokens.dart';
import 'package:luminous/features/report/data/datasources/report_remote_data_source.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';
import 'package:luminous/features/report/domain/repositories/report_repository.dart';

class LucentReportRepository implements ReportRepository {
  LucentReportRepository({required this.dataSource});

  final ReportRemoteDataSource dataSource;

  @override
  Future<ReportDashboard> fetchDashboard() async {
    final dto = await dataSource.fetchDashboard();
    final findings = dto.findings.map(_mapFinding).toList(growable: false);
    final score = _mapScore(dto.score);

    return ReportDashboard(
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
      ReportDataKind.medication => Icons.medication_rounded,
      ReportDataKind.water => Icons.water_drop_rounded,
      ReportDataKind.sleep => Icons.nightlight_round,
      ReportDataKind.general => Icons.monitor_heart_rounded,
    };
  }

  Color _metricColor(ReportDataKind kind) {
    return switch (kind) {
      ReportDataKind.medication => AppColorTokens.cyanDeep,
      ReportDataKind.water => AppColorTokens.link,
      ReportDataKind.sleep => AppColorTokens.violet,
      ReportDataKind.general => AppColorTokens.health,
    };
  }
  IconData _insightIcon(ReportInsightKind kind) {
    return switch (kind) {
      ReportInsightKind.medication => Icons.verified_rounded,
      ReportInsightKind.hydration => Icons.water_drop_rounded,
      ReportInsightKind.sleep => Icons.nightlight_round,
      ReportInsightKind.general => Icons.insights_rounded,
    };
  }

  Color _insightColor(ReportInsightKind kind) {
    return switch (kind) {
      ReportInsightKind.medication => AppColorTokens.cyanDeep,
      ReportInsightKind.hydration => AppColorTokens.link,
      ReportInsightKind.sleep => AppColorTokens.violet,
      ReportInsightKind.general => AppColorTokens.warning,
    };
  }
}

const _exportActions = <ReportExportAction>[
  ReportExportAction(
    kind: ReportExportKind.hospital,
    icon: Icons.local_hospital_rounded,
    color: AppColorTokens.link,
  ),
  ReportExportAction(
    kind: ReportExportKind.monthly,
    icon: Icons.bar_chart_rounded,
    color: AppColorTokens.link,
  ),
  ReportExportAction(
    kind: ReportExportKind.print,
    icon: Icons.print_rounded,
    color: AppColorTokens.warning,
  ),
];
