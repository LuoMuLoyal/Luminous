import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/health_data/data/providers/health_sync.dart';
import 'package:luminous/features/health_data/domain/entities/health_metric.dart';
import 'package:luminous/features/health_data/domain/repositories/health_sync.dart';
import 'package:luminous/features/health_data/presentation/providers/health_sync.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'health_sync_controller.g.dart';

@riverpod
class HealthSyncController extends _$HealthSyncController {
  late HealthSyncRepository _repo;

  @override
  HealthSyncState build() {
    _repo = ref.watch(healthSyncRepositoryProvider);
    return const HealthSyncState();
  }

  void toggleType(HealthMetricType type) {
    final current = Set<HealthMetricType>.from(state.selectedTypes);
    if (current.contains(type)) {
      current.remove(type);
    } else {
      current.add(type);
    }
    state = state.copyWith(selectedTypes: current);
  }

  void setTimeRange(HealthSyncTimeRange range) {
    state = state.copyWith(timeRange: range);
  }

  Future<void> requestPermissions() async {
    state = state.copyWith(isRequestingPermissions: true, error: null);
    try {
      await _repo.requestPermissions(state.selectedTypes);
      state = state.copyWith(isRequestingPermissions: false);
    } catch (e) {
      state = state.copyWith(isRequestingPermissions: false, error: '$e');
    }
  }

  Future<void> fetchData() async {
    if (state.selectedTypes.isEmpty) return;

    state = state.copyWith(isFetching: true, error: null, fetchedMetrics: []);

    final now = DateTime.now();
    final start = switch (state.timeRange) {
      HealthSyncTimeRange.today => DateTime(now.year, now.month, now.day),
      HealthSyncTimeRange.threeDays => now.subtract(const Duration(days: 3)),
      HealthSyncTimeRange.sevenDays => now.subtract(const Duration(days: 7)),
    };

    try {
      final metrics = await _repo.fetchMetrics(
        types: state.selectedTypes,
        start: start,
        end: now,
      );
      state = state.copyWith(isFetching: false, fetchedMetrics: metrics);
    } catch (e) {
      state = state.copyWith(isFetching: false, error: '$e');
    }
  }

  Future<void> sync() async {
    if (state.fetchedMetrics.isEmpty) return;

    state = state.copyWith(isSyncing: true, error: null);

    try {
      final result = await _repo.syncToRecords(state.fetchedMetrics);
      if (result.successCount > 0) {
        ref
            .read(dataChangeBusProvider.notifier)
            .emit(DataChangeTopic.dailyRecords);
      }
      state = state.copyWith(isSyncing: false, syncResult: result);
    } catch (e) {
      state = state.copyWith(isSyncing: false, error: '$e');
    }
  }

  void reset() {
    state = state.copyWith(fetchedMetrics: [], syncResult: null, error: null);
  }
}
