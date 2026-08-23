import 'dart:io' show Platform;

import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/features/health_data/data/datasources/health_platform.dart';
import 'package:luminous/features/health_data/data/mappers/health_record_mapper.dart';
import 'package:luminous/features/health_data/domain/entities/health_metric.dart';
import 'package:luminous/features/health_data/domain/entities/health_permission.dart';
import 'package:luminous/features/health_data/domain/entities/health_sync_result.dart';
import 'package:luminous/features/health_data/domain/repositories/health_sync.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
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
    return metrics;
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
      final fingerprint = _fingerprintForMetric(metric, input, _sourceTag);

      if (fingerprints.contains(fingerprint)) {
        skipped++;
        continue;
      }

      try {
        final result = await dailyRecordRepo.create(input).run();
        result.fold(
          (failure) {
            appTalker.warning('HealthSync: failed to create record: $failure');
            errors.add('$failure');
            failed++;
          },
          (_) {
            fingerprints.add(fingerprint);
            success++;
          },
        );
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
  /// Groups metrics by date, fetches existing records for each date (with
  /// pagination), and creates identity- or interval-based fingerprints.
  Future<Set<String>> _buildDedupFingerprints(
    List<HealthMetric> metrics,
  ) async {
    final fingerprints = <String>{};
    final dates = <String>{};

    for (final metric in metrics) {
      dates.add(_formatDate(metric.recordedAt));
      if (metric.startAt != null) {
        dates.add(_formatDate(metric.startAt!));
      }
      if (metric.endAt != null) {
        dates.add(_formatDate(metric.endAt!));
      }
    }

    for (final date in dates) {
      try {
        // Bounded pagination: `_maxDedupPages` caps the loop even if the
        // backend reports a bogus `total`, and an empty page breaks early
        // instead of spinning on repeated fetches.
        var page = 1;
        while (page <= _maxDedupPages) {
          final result = await dailyRecordRepo
              .fetchRecords(date, page: page, pageSize: _dedupPageSize)
              .run();
          // Left aborts the sync: dedup relies on the existing records, and
          // silently importing duplicates would corrupt the data.
          final data = result.fold((failure) {
            appTalker.error(
              'HealthSync: failed to fetch existing records for $date: '
              '$failure',
            );
            throw failure;
          }, (data) => data);
          for (final record in data.items) {
            final source = record.source ?? 'manual';
            final fingerprint = _fingerprintForRecord(record, source);
            if (fingerprint != null) fingerprints.add(fingerprint);
          }
          if (data.items.isEmpty || page * _dedupPageSize >= data.total) {
            break;
          }
          page++;
        }
      } catch (e) {
        // Dedup relies on the existing records; abort the sync instead of
        // silently importing duplicates.
        appTalker.error(
          'HealthSync: failed to fetch existing records for $date: $e',
        );
        rethrow;
      }
    }

    return fingerprints;
  }

  String _fingerprintForMetric(
    HealthMetric metric,
    DailyRecordCreateInput input,
    String source,
  ) {
    final externalId = metric.externalId;
    if (externalId != null && externalId.isNotEmpty) {
      return '${input.kind.name}|$source|external:$externalId';
    }

    final start = metric.startAt ?? metric.recordedAt;
    final end = metric.endAt ?? metric.recordedAt;
    return _intervalFingerprint(
      kind: input.kind.name,
      source: source,
      start: start,
      end: end,
      value: metric.value,
      unit: metric.unit,
    );
  }

  String? _fingerprintForRecord(DailyRecordItem record, String source) {
    final payload = record.payload;
    final externalId = payload?['externalId'];
    if (externalId is String && externalId.isNotEmpty) {
      return '${record.kind.name}|$source|external:$externalId';
    }

    final start =
        _parsePayloadTime(payload?['startedAt']) ??
        _parsePayloadTime(payload?['startAt']) ??
        _recordDateTime(record);
    final end =
        _parsePayloadTime(payload?['endedAt']) ??
        _parsePayloadTime(payload?['endAt']) ??
        _recordDateTime(record);
    if (start == null || end == null) return null;

    final Object? value;
    if (record.kind == DailyRecordKind.sleep) {
      value = payload == null
          ? record.value
          : (payload['durationMinutes'] ?? record.value);
    } else {
      value = record.value ?? (payload == null ? null : payload['value']);
    }
    final unit =
        record.unit ??
        (payload == null ? null : payload['unit']) ??
        (record.kind == DailyRecordKind.sleep ? 'min' : null);
    if (value == null || unit == null) return null;
    return _intervalFingerprint(
      kind: record.kind.name,
      source: source,
      start: start,
      end: end,
      value: value,
      unit: unit,
    );
  }

  String _intervalFingerprint({
    required String kind,
    required String source,
    required DateTime start,
    required DateTime end,
    required Object value,
    required String unit,
  }) {
    final normalizedValue = _normalizeFingerprintValue(value);
    return '$kind|$source|${start.toUtc().toIso8601String()}|'
        '${end.toUtc().toIso8601String()}|$normalizedValue|$unit';
  }

  String _normalizeFingerprintValue(Object value) {
    final numeric = switch (value) {
      num() => value.toDouble(),
      String() => double.tryParse(value.trim()),
      _ => null,
    };
    if (numeric == null || !numeric.isFinite) return value.toString();
    return numeric == numeric.round()
        ? numeric.round().toString()
        : numeric.toString();
  }

  DateTime? _parsePayloadTime(Object? value) {
    return value is String ? DateTime.tryParse(value) : null;
  }

  DateTime? _recordDateTime(DailyRecordItem record) {
    final date = DateTime.tryParse(record.occurredAt);
    if (date == null) return null;
    final time = record.occurredTime;
    if (time == null) return date;
    final parts = time.split(':');
    if (parts.length != 2) return date;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return date;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  String _formatDate(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}'
        '-${dt.month.toString().padLeft(2, '0')}'
        '-${dt.day.toString().padLeft(2, '0')}';
  }

  /// Page size used when fetching existing records for deduplication.
  static const _dedupPageSize = 500;

  /// Maximum pages fetched per date during dedup (500 × 100 = 50k records).
  /// Guards against a backend `total` regression that would otherwise keep
  /// the `while` loop alive forever.
  static const _maxDedupPages = 100;

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
