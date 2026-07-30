import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/features/health_data/domain/entities/health_metric.dart';
import 'package:luminous/features/health_data/domain/entities/health_sync_result.dart';

part 'health_sync.freezed.dart';

enum HealthSyncTimeRange { today, threeDays, sevenDays }

@freezed
abstract class HealthSyncState with _$HealthSyncState {
  const HealthSyncState._();

  const factory HealthSyncState({
    @Default({
      HealthMetricType.heartRate,
      HealthMetricType.bloodPressure,
      HealthMetricType.bloodOxygen,
      HealthMetricType.weight,
      HealthMetricType.steps,
      HealthMetricType.sleep,
    })
    Set<HealthMetricType> selectedTypes,
    @Default(HealthSyncTimeRange.threeDays) HealthSyncTimeRange timeRange,
    @Default([]) List<HealthMetric> fetchedMetrics,
    HealthSyncResult? syncResult,
    @Default(false) bool isFetching,
    @Default(false) bool isSyncing,
    @Default(false) bool isRequestingPermissions,
    String? error,
  }) = _HealthSyncState;

  bool get isLoading => isFetching || isSyncing || isRequestingPermissions;
}
