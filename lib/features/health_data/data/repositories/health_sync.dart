import 'dart:io' show Platform;

import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/features/health_data/data/datasources/health_platform.dart';
import 'package:luminous/features/health_data/data/mappers/health_record_mapper.dart';
import 'package:luminous/features/health_data/domain/entities/health_metric.dart';
import 'package:luminous/features/health_data/domain/entities/health_permission.dart';
import 'package:luminous/features/health_data/domain/entities/health_sync_result.dart';
import 'package:luminous/features/health_data/domain/repositories/health_sync.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/repositories/daily.dart';

class HealthSyncRepositoryImpl implements HealthSyncRepository {
  HealthSyncRepositoryImpl({
    required this.dataSource,
    required this.mapper,
    required this.dailyRecordRepo,
  });

  final HealthPlatformDataSource dataSource;
  final HealthRecordMapper mapper;
  final DailyRecordRepository dailyRecordRepo;

  @override
  bool get isPlatformAvailable => dataSource.isPlatformAvailable;

  /// The source string for synced records.
  /// iOS → "apple_health", Android → "health_connect".
  String get _sourceTag => Platform.isIOS ? 'apple_health' : 'health_connect';

  @override
  Future<HealthPermissionStatus> requestPermissions(
    Set<HealthMetricType> types,
  ) {
    return dataSource.requestPermissions(types);
  }

  @override
  Future<Set<HealthMetricType>> getAuthorizedTypes() async {
    if (!isPlatformAvailable) return {};
    // We need to pass the full set of supported types to check permissions.
    return dataSource.getAuthorizedTypes(_allSupportedTypes);
  }

  @override
  Future<List<HealthMetric>> fetchMetrics({
    required Set<HealthMetricType> types,
    required DateTime start,
    required DateTime end,
  }) async {
    final points = await dataSource.fetchDataPoints(
      types: types,
      start: start,
      end: end,
    );
    final metrics = mapper.mapToMetrics(points);
    return _pairBloodPressure(metrics);
  }

  @override
  Future<HealthSyncResult> syncToRecords(List<HealthMetric> metrics) async {
    if (metrics.isEmpty) {
      return const HealthSyncResult(
        successCount: 0,
        skippedCount: 0,
        failedCount: 0,
      );
    }

    // Build dedup fingerprint set from existing records
    final fingerprints = await _buildDedupFingerprints(metrics);
    final errors = <String>[];
    var success = 0;
    var skipped = 0;
    var failed = 0;

    for (final metric in metrics) {
      final input = mapper.mapToCreateInput(metric, source: _sourceTag);
      final fingerprint = _fingerprint(input);

      if (fingerprints.contains(fingerprint)) {
        skipped++;
        continue;
      }

      try {
        await dailyRecordRepo.create(input);
        fingerprints.add(fingerprint);
        success++;
      } catch (e) {
        appTalker.warning('HealthSync: failed to create record: $e');
        errors.add('$e');
        failed++;
      }
    }

    return HealthSyncResult(
      successCount: success,
      skippedCount: skipped,
      failedCount: failed,
      errors: errors,
    );
  }

  /// Build a set of existing record fingerprints for deduplication.
  ///
  /// Groups metrics by date, fetches existing records for each date, and
  /// creates (kind + occurredAt + source) fingerprints.
  Future<Set<String>> _buildDedupFingerprints(
    List<HealthMetric> metrics,
  ) async {
    final fingerprints = <String>{};
    final dates = <String>{};

    for (final metric in metrics) {
      final date = _formatDate(metric.recordedAt);
      dates.add(date);
    }

    for (final date in dates) {
      try {
        final result = await dailyRecordRepo.fetchRecords(date, pageSize: 200);
        for (final record in result.items) {
          final source = record.source ?? 'manual';
          fingerprints.add('${record.kind.name}|${record.occurredAt}|$source');
        }
      } catch (e) {
        appTalker.warning('HealthSync: failed to fetch existing records: $e');
      }
    }

    return fingerprints;
  }

  String _fingerprint(DailyRecordCreateInput input) {
    return '${input.kind.name}|${input.occurredAt}|${input.source ?? 'manual'}';
  }

  /// Pair blood pressure systolic/diastolic data points by proximity.
  ///
  /// When two blood pressure metrics are within 2 minutes of each other,
  /// merge them: the earlier one's value becomes the systolic value,
  /// the later one's value becomes the secondaryValue (diastolic).
  List<HealthMetric> _pairBloodPressure(List<HealthMetric> metrics) {
    final bpMetrics = metrics
        .where((m) => m.type == HealthMetricType.bloodPressure)
        .toList();
    if (bpMetrics.isEmpty) return metrics;

    bpMetrics.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    final used = List<bool>.filled(bpMetrics.length, false);
    final paired = <HealthMetric>[];

    for (var i = 0; i < bpMetrics.length; i++) {
      if (used[i]) continue;
      final first = bpMetrics[i];

      // Find the nearest unused BP metric within 2 minutes
      for (var j = i + 1; j < bpMetrics.length; j++) {
        if (used[j]) continue;
        final second = bpMetrics[j];
        final diff = second.recordedAt.difference(first.recordedAt).inMinutes;
        if (diff >= 0 && diff <= 2) {
          paired.add(
            first.copyWith(
              secondaryValue: second.value,
              secondaryUnit: second.unit,
            ),
          );
          used[i] = true;
          used[j] = true;
          break;
        }
      }
      if (!used[i]) {
        // No pair found — keep as single reading
        paired.add(first);
        used[i] = true;
      }
    }

    final nonBp = metrics.where(
      (m) => m.type != HealthMetricType.bloodPressure,
    );
    return [...nonBp, ...paired];
  }

  String _formatDate(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}'
        '-${dt.month.toString().padLeft(2, '0')}'
        '-${dt.day.toString().padLeft(2, '0')}';
  }

  static const _allSupportedTypes = <HealthMetricType>{
    HealthMetricType.heartRate,
    HealthMetricType.bloodPressure,
    HealthMetricType.bloodOxygen,
    HealthMetricType.bloodGlucose,
    HealthMetricType.bodyTemperature,
    HealthMetricType.weight,
    HealthMetricType.respiratoryRate,
    HealthMetricType.steps,
    HealthMetricType.flightsClimbed,
    HealthMetricType.exerciseTime,
    HealthMetricType.sleep,
    HealthMetricType.height,
    HealthMetricType.water,
  };
}
