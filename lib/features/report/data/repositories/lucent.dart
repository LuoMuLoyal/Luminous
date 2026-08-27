// The generated contract marks the legacy scalar projection as deprecated.
// Keep this mapper's fallback until the observed metric domain migration lands.
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lucent_api/lucent_api.dart' as lucent;
import 'package:luminous/core/database/cache_constants.dart';
import 'package:luminous/core/database/daos/report_dashboard_dao.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/network/error_mapper.dart';
import 'package:luminous/features/report/data/datasources/report.dart';
import 'package:luminous/features/report/domain/entities/dashboard.dart';
import 'package:luminous/features/report/domain/repositories/report.dart';

class LucentReportRepository implements ReportRepository {
  LucentReportRepository({required this.dataSource, required this.dao});

  final ReportRemoteDataSource dataSource;
  final ReportDashboardDao dao;

  DateTime? _lastRefresh;

  @override
  TaskEither<LucentFailure, ReportDashboard> fetchDashboard(
    ReportDashboardQuery query,
  ) {
    return TaskEither.tryCatch(() async {
      final cacheKey = ReportDashboardDao.cacheKey(
        range: query.range.name,
        startDate: query.startDate,
        endDate: query.endDate,
      );

      // 1. Check cache
      final cachedJson = await dao.fetch(cacheKey);
      if (cachedJson != null) {
        final dto = lucent.ReportDashboardResponseDto.fromJson(
          jsonDecode(cachedJson) as Map<String, dynamic>,
        );
        final dashboard = _mapDto(dto);
        // Background refresh (throttled) — best-effort.
        _refreshInBackground(query, cacheKey);
        return dashboard;
      }

      // 2. Cache empty → fetch from network.
      final dto = await dataSource.fetchDashboard(query);
      await dao.replace(cacheKey, jsonEncode(dto.toJson()));
      return _mapDto(dto);
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  ReportDashboard _mapDto(lucent.ReportDashboardResponseDto dto) {
    final findings = dto.findings.map(_mapFinding).toList(growable: false);

    return ReportDashboard(
      range: _mapRange(dto.range.value),
      startDate: dto.startDate,
      endDate: dto.endDate,
      generatedAt: dto.generatedAt,
      metrics: dto.metrics.map(_mapMetric).toList(growable: false),
      trends: dto.trends.map(_mapTrend).toList(growable: false),
      findings: findings,
      exportActions: _exportActions,
      patterns: dto.patterns.map(_mapPattern).toList(growable: false),
      aiSummaryEnabled: dto.aiSummaryEnabled,
    );
  }

  void _refreshInBackground(ReportDashboardQuery query, String cacheKey) {
    final now = DateTime.now();
    if (_lastRefresh != null &&
        now.difference(_lastRefresh!) < backgroundRefreshThrottle) {
      return;
    }
    _lastRefresh = now;

    unawaited(
      Future(() async {
        try {
          final dto = await dataSource.fetchDashboard(query);
          await dao.replace(cacheKey, jsonEncode(dto.toJson()));
        } catch (e) {
          appTalker.warning('Report dashboard background refresh failed: $e');
        }
      }),
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
      observedMetric: dto.observedMetric == null
          ? null
          : _mapObservedMetric(dto.observedMetric!),
    );
  }

  ReportObservedMetric _mapObservedMetric(lucent.ReportObservedMetricDto dto) {
    return ReportObservedMetric(
      value: dto.value?.toDouble(),
      state: switch (dto.state.value) {
        'observed' => ReportObservedMetricState.observed,
        _ => ReportObservedMetricState.unknown,
      },
      coverage: switch (dto.coverage.value) {
        'sufficient' => ReportObservedMetricCoverage.sufficient,
        'partial' => ReportObservedMetricCoverage.partial,
        _ => ReportObservedMetricCoverage.none,
      },
      sources: dto.sources.map(_mapObservedSource).toList(growable: false),
      observedCount: dto.observedCount.toInt(),
      expectedCount: dto.expectedCount?.toInt(),
      windowStart: dto.windowStart,
      windowEnd: dto.windowEnd,
    );
  }

  ReportObservedMetricSource _mapObservedSource(
    lucent.ReportObservedMetricDtoSourcesEnum source,
  ) {
    return switch (source.value) {
      'manual' => ReportObservedMetricSource.manual,
      'health_platform' => ReportObservedMetricSource.healthPlatform,
      'reminder_plan' => ReportObservedMetricSource.reminderPlan,
      'derived' => ReportObservedMetricSource.derived,
      _ => ReportObservedMetricSource.derived,
    };
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
