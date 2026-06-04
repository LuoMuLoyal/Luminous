import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_remote_data_source.dart';
import 'package:luminous/features/medicine/data/repositories/mock_medicine_workspace_repository.dart';
import 'package:luminous/features/record/data/providers/daily_record_providers.dart';
import 'package:luminous/features/today/domain/entities/today_dashboard.dart';
import 'package:luminous/features/today/domain/repositories/today_repository.dart';

/// Lucent-backed [TodayRepository] that merges real health-context and
/// daily-record signals with static mock sections for unsupported surfaces.
class LucentTodayRepository implements TodayRepository {
  LucentTodayRepository({required this.ref});

  final Ref ref;

  @override
  Future<TodayDashboard> fetchDashboard() async {
    final snapshot = await ref.read(healthContextSnapshotProvider.future);
    final medicines = snapshot.currentMedicines;

    // Fetch daily record summary for today
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    Map<String, num> recordCounts = {};
    Map<String, String?> recordLatest = {};
    try {
      final summary = await ref
          .read(dailyRecordRepositoryProvider)
          .fetchSummary(dateStr);
      for (final s in summary.summaries) {
        recordCounts[s.kind.name] = s.count;
        recordLatest[s.kind.name] = s.latest?.value;
      }
    } catch (_) {
      // Fall back to static mock if records aren't available
    }

    final waterCount = (recordCounts['water'] ?? 0).toInt();
    final completedMedicineIds = <String>{};
    try {
      final doseLogs = await ref
          .read(doseLogRemoteDataSourceProvider)
          .fetchForDate(dateStr);
      for (final log in doseLogs) {
        final medicineId = log.currentMedicineId;
        if (medicineId != null &&
            (log.status == DoseLogStatus.taken ||
                log.status == DoseLogStatus.skipped)) {
          completedMedicineIds.add(medicineId);
        }
      }
    } catch (_) {
      // Keep Today factual and available even if manual dose logs are absent.
    }
    final pendingMedicines = medicines
        .where((m) => m.isCurrent && !completedMedicineIds.contains(m.id))
        .toList();

    return TodayDashboard(
      user: TodayUserSnapshot(
        moment: todayDayMomentFromHour(today.hour),
        hasUnreadNotifications: true, // mock
      ),
      water: TodayWaterSummary(completedCount: waterCount, targetCount: 8),
      medication: TodayMedicationSummary(
        medicineCount: snapshot.summary.currentMedicineCount,
        pendingCount: pendingMedicines.length,
        nextDoseTimeLabel: '--',
        nextMedicine: TodayMedicationKind.atorvastatin,
        nextMedicineName: pendingMedicines.isNotEmpty
            ? pendingMedicines.first.displayName
            : (medicines.isNotEmpty ? medicines.first.displayName : null),
      ),
      vitals: [
        TodayVitalSummary(
          type: TodayVitalType.heartRate,
          valueLabel: recordLatest['vital'] ?? '--',
        ),
        TodayVitalSummary(type: TodayVitalType.bloodPressure, valueLabel: '--'),
        TodayVitalSummary(type: TodayVitalType.sleep, valueLabel: '--'),
      ],
      mealSuggestion: _staticMealSuggestion,
      environment: _staticEnvironment,
      lumiSuggestion: _staticLumiSuggestion,
    );
  }

  static const _staticMealSuggestion = TodayMealSuggestion(
    type: TodayMealSuggestionType.highProteinBalancedLunch,
  );

  static const _staticEnvironment = TodayEnvironmentSummary(
    signals: <TodayEnvironmentSignal>[
      TodayEnvironmentSignal(
        type: TodayEnvironmentSignalType.pollen,
        level: TodayEnvironmentLevel.high,
      ),
      TodayEnvironmentSignal(
        type: TodayEnvironmentSignalType.uv,
        level: TodayEnvironmentLevel.medium,
      ),
    ],
  );

  static const _staticLumiSuggestion = TodayLumiSuggestion(
    type: TodayLumiSuggestionType.pollenProtection,
  );
}
