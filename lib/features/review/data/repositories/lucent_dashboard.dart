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
import 'package:luminous/features/review/data/datasources/dashboard_remote.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/domain/repositories/dashboard.dart';

class LucentReviewDashboardRepository implements ReviewDashboardRepository {
  LucentReviewDashboardRepository({
    required this.dataSource,
    required this.dao,
  });

  final ReviewDashboardRemoteDataSource dataSource;
  final ReviewDashboardDao dao;

  DateTime? _lastRefresh;

  @override
  TaskEither<LucentFailure, ReviewDashboard> fetchDashboard(
    ReviewDashboardQuery query,
  ) {
    return TaskEither.tryCatch(() async {
      final cacheKey = ReviewDashboardDao.cacheKey(
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

  ReviewDashboard _mapDto(lucent.ReportDashboardResponseDto dto) {
    final findings = dto.findings.map(_mapFinding).toList(growable: false);

    return ReviewDashboard(
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

  void _refreshInBackground(ReviewDashboardQuery query, String cacheKey) {
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
          appTalker.warning('Review dashboard background refresh failed: $e');
        }
      }),
    );
  }

  ReviewMetric _mapMetric(lucent.ReportMetricDto dto) {
    final kind = _mapDataKind(dto.kind.value);
    return ReviewMetric(
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

  ReviewObservedMetric _mapObservedMetric(lucent.ReportObservedMetricDto dto) {
    return ReviewObservedMetric(
      value: dto.value?.toDouble(),
      state: switch (dto.state.value) {
        'observed' => ReviewObservedMetricState.observed,
        _ => ReviewObservedMetricState.unknown,
      },
      coverage: switch (dto.coverage.value) {
        'sufficient' => ReviewObservedMetricCoverage.sufficient,
        'partial' => ReviewObservedMetricCoverage.partial,
        _ => ReviewObservedMetricCoverage.none,
      },
      sources: dto.sources.map(_mapObservedSource).toList(growable: false),
      observedCount: dto.observedCount.toInt(),
      expectedCount: dto.expectedCount?.toInt(),
      windowStart: dto.windowStart,
      windowEnd: dto.windowEnd,
    );
  }

  ReviewObservedMetricSource _mapObservedSource(
    lucent.ReportObservedMetricDtoSourcesEnum source,
  ) {
    return switch (source.value) {
      'manual' => ReviewObservedMetricSource.manual,
      'health_platform' => ReviewObservedMetricSource.healthPlatform,
      'reminder_plan' => ReviewObservedMetricSource.reminderPlan,
      'derived' => ReviewObservedMetricSource.derived,
      _ => ReviewObservedMetricSource.derived,
    };
  }

  ReviewTrendSeries _mapTrend(lucent.ReportTrendDto dto) {
    final kind = _mapDataKind(dto.kind.value);
    return ReviewTrendSeries(
      kind: kind,
      color: _metricColor(kind),
      unit: dto.unit,
      values: dto.values.map((value) => value.toDouble()).toList(),
      currentValue: dto.currentValue,
    );
  }

  ReviewFinding _mapFinding(lucent.ReportFindingDto dto) {
    final kind = _mapInsightKind(dto.kind.value);
    return ReviewFinding(
      kind: kind,
      icon: _insightIcon(kind),
      color: _insightColor(kind),
      title: dto.title,
      body: dto.body,
    );
  }

  ReviewPatternCard _mapPattern(lucent.ReportPatternDto dto) {
    final kind = _mapInsightKind(dto.kind.value);
    return ReviewPatternCard(
      kind: kind,
      icon: _insightIcon(kind),
      color: _insightColor(kind),
      title: dto.title,
      status: _mapStatus(dto.status.value),
      body: dto.body,
      sparkline: dto.sparkline.map((value) => value.toDouble()).toList(),
    );
  }

  ReviewDashboardRange _mapRange(String value) {
    return switch (value) {
      'last_7_days' => ReviewDashboardRange.last7Days,
      'last_30_days' => ReviewDashboardRange.last30Days,
      'custom' => ReviewDashboardRange.custom,
      _ => ReviewDashboardRange.last7Days,
    };
  }

  ReviewStatus _mapStatus(String value) {
    return switch (value) {
      'good' => ReviewStatus.good,
      'stable' => ReviewStatus.stable,
      'needs_attention' => ReviewStatus.needsAttention,
      'insufficient_data' => ReviewStatus.insufficientData,
      _ => ReviewStatus.unknown,
    };
  }

  ReviewMetricDirection _mapDirection(String value) {
    return switch (value) {
      'up' => ReviewMetricDirection.up,
      'down' => ReviewMetricDirection.down,
      'flat' => ReviewMetricDirection.flat,
      _ => ReviewMetricDirection.flat,
    };
  }

  ReviewDataKind _mapDataKind(String value) {
    return switch (value) {
      'medication' => ReviewDataKind.medication,
      'water' => ReviewDataKind.water,
      'sleep' => ReviewDataKind.sleep,
      _ => ReviewDataKind.general,
    };
  }

  ReviewInsightKind _mapInsightKind(String value) {
    return switch (value) {
      'medication' => ReviewInsightKind.medication,
      'hydration' => ReviewInsightKind.hydration,
      'sleep' => ReviewInsightKind.sleep,
      _ => ReviewInsightKind.general,
    };
  }

  IconData _metricIcon(ReviewDataKind kind) {
    return switch (kind) {
      ReviewDataKind.medication => SemanticIcons.recordMedicine,
      ReviewDataKind.water => SemanticIcons.recordWater,
      ReviewDataKind.sleep => SemanticIcons.recordMoon,
      ReviewDataKind.general => SemanticIcons.profileCondition,
    };
  }

  SemanticColor _metricColor(ReviewDataKind kind) {
    return switch (kind) {
      ReviewDataKind.medication => SemanticColor.primary,
      ReviewDataKind.water => SemanticColor.info,
      ReviewDataKind.sleep => SemanticColor.warning,
      ReviewDataKind.general => SemanticColor.success,
    };
  }

  IconData _insightIcon(ReviewInsightKind kind) {
    return switch (kind) {
      ReviewInsightKind.medication => SemanticIcons.reportAdherence,
      ReviewInsightKind.hydration => SemanticIcons.recordWater,
      ReviewInsightKind.sleep => SemanticIcons.recordMoon,
      ReviewInsightKind.general => SemanticIcons.reportChart,
    };
  }

  SemanticColor _insightColor(ReviewInsightKind kind) {
    return switch (kind) {
      ReviewInsightKind.medication => SemanticColor.primary,
      ReviewInsightKind.hydration => SemanticColor.info,
      ReviewInsightKind.sleep => SemanticColor.warning,
      ReviewInsightKind.general => SemanticColor.success,
    };
  }

  @override
  Future<ReviewDashboard> get signedOutDashboard =>
      Future.value(ReviewDashboard.signedOut());
}

final _exportActions = <ReviewExportAction>[
  const ReviewExportAction(
    kind: ReviewExportKind.hospital,
    icon: SemanticIcons.medicineKit,
    color: SemanticColor.primary,
  ),
  const ReviewExportAction(
    kind: ReviewExportKind.monthly,
    icon: SemanticIcons.tabReview,
    color: SemanticColor.primary,
  ),
  const ReviewExportAction(
    kind: ReviewExportKind.print,
    icon: SemanticIcons.actionExport,
    color: SemanticColor.primary,
  ),
  const ReviewExportAction(
    kind: ReviewExportKind.clinicShare,
    icon: SemanticIcons.actionShare,
    color: SemanticColor.primary,
  ),
];
