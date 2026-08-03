import 'package:health/health.dart';
import 'package:luminous/features/health_data/data/datasources/health_platform.dart';
import 'package:luminous/features/health_data/domain/entities/health_metric.dart';
import 'package:luminous/features/health_data/domain/entities/health_permission.dart';
import 'package:luminous/features/health_data/domain/entities/health_sync_result.dart';
import 'package:luminous/features/health_data/domain/repositories/health_sync.dart';

/// Test-only in-memory implementation of [HealthSyncRepository].
///
/// Exposes injection points for permission results, fetch results/errors and
/// sync results/errors so provider and page tests can drive every state.
class FakeHealthSyncRepository implements HealthSyncRepository {
  bool available = true;
  HealthPermissionStatus permissionStatus = HealthPermissionStatus.granted;
  List<HealthMetric> fetchResult = [];
  Object? fetchError;
  HealthSyncResult syncResult = const HealthSyncResult(
    successCount: 0,
    skippedCount: 0,
    failedCount: 0,
  );
  Object? syncError;

  /// When set, [syncToRecords] returns this future instead of [syncResult],
  /// allowing tests to keep the syncing state visible.
  Future<HealthSyncResult>? blockSync;
  Set<HealthMetricType>? lastFetchTypes;
  DateTime? lastFetchStart;
  DateTime? lastFetchEnd;

  @override
  bool get isPlatformAvailable => available;

  @override
  Future<Set<HealthMetricType>> getAuthorizedTypes() async => const {};

  @override
  Future<List<HealthMetric>> fetchMetrics({
    required Set<HealthMetricType> types,
    required DateTime start,
    required DateTime end,
  }) async {
    lastFetchTypes = types;
    lastFetchStart = start;
    lastFetchEnd = end;
    if (fetchError != null) throw fetchError!;
    return fetchResult;
  }

  @override
  Future<HealthPermissionStatus> requestPermissions(
    Set<HealthMetricType> types,
  ) async {
    return permissionStatus;
  }

  @override
  Future<HealthSyncResult> syncToRecords(List<HealthMetric> metrics) async {
    if (syncError != null) throw syncError!;
    if (blockSync != null) return blockSync!;
    return syncResult;
  }
}

/// Test-only [HealthPlatformDataSource] that records fetch arguments and
/// returns canned data without touching native health channels.
class FakeHealthPlatformDataSource extends HealthPlatformDataSource {
  FakeHealthPlatformDataSource({this.available = true, this.points = const []});

  bool available;
  List<HealthDataPoint> points;
  HealthPermissionStatus permissionResult = HealthPermissionStatus.granted;
  Set<HealthMetricType> authorizedResult = {};
  DateTime? lastFetchStart;
  DateTime? lastFetchEnd;
  Set<HealthMetricType>? lastFetchTypes;

  @override
  bool get isPlatformAvailable => available;

  @override
  Future<HealthPermissionStatus> requestPermissions(
    Set<HealthMetricType> types,
  ) async {
    return permissionResult;
  }

  @override
  Future<Set<HealthMetricType>> getAuthorizedTypes(
    Set<HealthMetricType> types,
  ) async {
    return authorizedResult;
  }

  @override
  Future<List<HealthDataPoint>> fetchDataPoints({
    required Set<HealthMetricType> types,
    required DateTime start,
    required DateTime end,
  }) async {
    lastFetchTypes = types;
    lastFetchStart = start;
    lastFetchEnd = end;
    return points;
  }
}
