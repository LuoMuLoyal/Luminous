import 'package:luminous/features/health_data/domain/entities/health_metric.dart';
import 'package:luminous/features/health_data/domain/entities/health_permission.dart';
import 'package:luminous/features/health_data/domain/entities/health_sync_result.dart';

abstract interface class HealthSyncRepository {
  /// Check whether the health platform is available
  /// (iOS: always available; Android: requires Health Connect installed).
  bool get isPlatformAvailable;

  /// Request read permissions for the given metric types.
  Future<HealthPermissionStatus> requestPermissions(
    Set<HealthMetricType> types,
  );

  /// Get currently authorized metric types.
  Future<Set<HealthMetricType>> getAuthorizedTypes();

  /// Fetch health metrics in the given time range.
  Future<List<HealthMetric>> fetchMetrics({
    required Set<HealthMetricType> types,
    required DateTime start,
    required DateTime end,
  });

  /// Sync health metrics to daily-records via the existing DailyRecordRepository.
  Future<HealthSyncResult> syncToRecords(List<HealthMetric> metrics);
}
