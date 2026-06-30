import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_remote_data_source.dart';
import 'package:luminous/features/medicine/data/datasources/medicine_reminder_remote_data_source.dart';
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
    final medicines = snapshot.currentMedicines
        .where((medicine) => medicine.isCurrent)
        .toList(growable: false);

    // Fetch daily record summary for today
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    Map<String, num> recordCounts = {};
    Map<String, String?> recordLatest = {};
    Map<String, dynamic>? sleepPayload;
    try {
      final summary = await ref
          .read(dailyRecordRepositoryProvider)
          .fetchSummary(dateStr);
      for (final s in summary.summaries) {
        recordCounts[s.kind.name] = s.count;
        recordLatest[s.kind.name] = s.latest?.value;
        if (s.kind.name == 'sleep') {
          sleepPayload = s.latest?.payload;
        }
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
    final nextReminder = await _nextReminderFor(
      today,
      pendingMedicines.map((medicine) => medicine.id).toSet(),
    );
    final nextReminderMedicineId = nextReminder?.currentMedicineId;
    final nextMedicine = nextReminderMedicineId == null
        ? null
        : pendingMedicines
              .where((medicine) => medicine.id == nextReminderMedicineId)
              .firstOrNull;
    final fallbackMedicine = pendingMedicines.isNotEmpty
        ? pendingMedicines.first
        : (medicines.isNotEmpty ? medicines.first : null);
    final nextMedicineName =
        nextMedicine?.displayName ?? fallbackMedicine?.displayName;

    return TodayDashboard(
      user: TodayUserSnapshot(
        moment: todayDayMomentFromHour(today.hour),
        hasUnreadNotifications: false,
        updatedAtLabel: _formatTimeLabel(today),
      ),
      water: TodayWaterSummary(completedCount: waterCount, targetCount: 8),
      medication: TodayMedicationSummary(
        medicineCount: medicines.length,
        pendingCount: pendingMedicines.length,
        nextDoseTimeLabel: nextReminder?.timeLabel ?? '--',
        nextMedicine: TodayMedicationKind.atorvastatin,
        nextMedicineName: nextMedicineName,
      ),
      vitals: [
        TodayVitalSummary(
          type: TodayVitalType.heartRate,
          valueLabel: recordLatest['vital'] ?? '--',
        ),
        const TodayVitalSummary(
          type: TodayVitalType.bloodPressure,
          valueLabel: '--',
        ),
        TodayVitalSummary(
          type: TodayVitalType.sleep,
          valueLabel: _formatSleepLabel(sleepPayload),
        ),
        // Deferred by Product_Vision MVP: keep lightweight mood data in the
        // repository for future self-check-ins, but do not surface it as a
        // formal mental-health module in Today.
        TodayVitalSummary(
          type: TodayVitalType.mood,
          valueLabel: recordLatest['mood'] ?? '--',
        ),
      ],
      mealSuggestion: _staticMealSuggestion,
      environment: _staticEnvironment,
      lumiSuggestion: _staticLumiSuggestion,
      priorityItems: [
        TodayPriorityItem(
          id: 'medication',
          type: TodayPriorityItemType.medication,
          count: pendingMedicines.length,
          timeLabel: nextReminder?.timeLabel ?? '--',
          medicineName: nextMedicineName,
        ),
        TodayPriorityItem(
          id: 'water',
          type: TodayPriorityItemType.water,
          count: waterCount,
          targetCount: 8,
          progress: TodayWaterSummary(
            completedCount: waterCount,
            targetCount: 8,
          ).progress,
        ),
      ],
    );
  }

  static const _staticMealSuggestion = TodayMealSuggestion(
    type: TodayMealSuggestionType.highProteinBalancedLunch,
  );

  // Deferred by Product_Vision MVP: keep environment signals because Lucent has
  // a useful reference-data contract, but do not surface it until a concrete
  // Today or Mine product job is ready.
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

  Future<MedicineReminderItem?> _nextReminderFor(
    DateTime today,
    Set<String> pendingMedicineIds,
  ) async {
    if (pendingMedicineIds.isEmpty) return null;
    try {
      final reminders = await ref
          .read(medicineReminderRemoteDataSourceProvider)
          .fetchActive();
      final todayReminders =
          reminders
              .where((reminder) {
                final medicineId = reminder.currentMedicineId;
                return medicineId != null &&
                    pendingMedicineIds.contains(medicineId) &&
                    reminder.matchesDate(today);
              })
              .toList(growable: false)
            ..sort(_compareReminderTime);
      return todayReminders.firstOrNull;
    } catch (_) {
      return null;
    }
  }

  static int _compareReminderTime(
    MedicineReminderItem left,
    MedicineReminderItem right,
  ) {
    final hour = left.scheduledHour.compareTo(right.scheduledHour);
    if (hour != 0) return hour;
    return left.scheduledMinute.compareTo(right.scheduledMinute);
  }

  static String _formatSleepLabel(Map<String, dynamic>? payload) {
    if (payload == null) return '--';
    final durationMinutes = payload['durationMinutes'];
    if (durationMinutes is! num || durationMinutes <= 0) return '--';
    final hours = (durationMinutes / 60).toStringAsFixed(1);
    return '${hours}h';
  }

  static String _formatTimeLabel(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
