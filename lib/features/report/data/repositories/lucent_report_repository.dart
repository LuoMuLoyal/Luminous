import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_colors.dart';
import 'package:lucent_openapi/lucent_openapi.dart' as lucent;
import 'package:luminous/features/report/data/datasources/report_remote_data_source.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';
import 'package:luminous/features/report/domain/repositories/report_repository.dart';

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
      ReportDataKind.medication => FLucideIcons.pill,
      ReportDataKind.water => FLucideIcons.droplets,
      ReportDataKind.sleep => FLucideIcons.moon,
      ReportDataKind.general => FLucideIcons.heartPulse,
    };
  }

  AppColors _metricColor(ReportDataKind kind) {
    return switch (kind) {
      ReportDataKind.medication => AppColors.primary,
      ReportDataKind.water => AppColors.primary,
      ReportDataKind.sleep => AppColors.primary,
      ReportDataKind.general => AppColors.primary,
    };
  }

  IconData _insightIcon(ReportInsightKind kind) {
    return switch (kind) {
      ReportInsightKind.medication => FLucideIcons.badgeCheck,
      ReportInsightKind.hydration => FLucideIcons.droplets,
      ReportInsightKind.sleep => FLucideIcons.moon,
      ReportInsightKind.general => FLucideIcons.chartLine,
    };
  }

  AppColors _insightColor(ReportInsightKind kind) {
    return switch (kind) {
      ReportInsightKind.medication => AppColors.primary,
      ReportInsightKind.hydration => AppColors.primary,
      ReportInsightKind.sleep => AppColors.primary,
      ReportInsightKind.general => AppColors.primary,
    };
  }
}

final _exportActions = <ReportExportAction>[
  const ReportExportAction(
    kind: ReportExportKind.hospital,
    icon: FLucideIcons.hospital,
    color: AppColors.primary,
  ),
  const ReportExportAction(
    kind: ReportExportKind.monthly,
    icon: FLucideIcons.barChart,
    color: AppColors.primary,
  ),
  const ReportExportAction(
    kind: ReportExportKind.print,
    icon: FLucideIcons.printer,
    color: AppColors.primary,
  ),
  const ReportExportAction(
    kind: ReportExportKind.clinicShare,
    icon: FLucideIcons.share2,
    color: AppColors.primary,
  ),
];
