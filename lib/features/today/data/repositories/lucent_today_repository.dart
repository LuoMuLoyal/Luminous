import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/today/domain/entities/today_dashboard.dart';
import 'package:luminous/features/today/domain/repositories/today_repository.dart';

/// Lucent-backed [TodayRepository] that merges real health-context signals
/// with static mock sections for surfaces the backend does not yet support.
class LucentTodayRepository implements TodayRepository {
  LucentTodayRepository({required this.ref});

  final Ref ref;

  @override
  Future<TodayDashboard> fetchDashboard() async {
    final snapshot = await ref.read(healthContextSnapshotProvider.future);

    final medicines = snapshot.currentMedicines;

    return TodayDashboard(
      user: TodayUserSnapshot(
        moment: todayDayMomentFromHour(DateTime.now().hour),
        hasUnreadNotifications: true, // mock: no notification service yet
      ),
      water:
          _staticWater, // mock: backend does not yet provide water tracking
      medication: TodayMedicationSummary(
        medicineCount: snapshot.summary.currentMedicineCount,
        pendingCount: 0, // mock: no dose schedule yet
        nextDoseTimeLabel: '--', // mock
        nextMedicine: TodayMedicationKind.atorvastatin, // fallback enum
        nextMedicineName:
            medicines.isNotEmpty ? medicines.first.displayName : null,
      ),
      vitals:
          _staticVitals, // mock: backend does not yet provide vitals/records
      mealSuggestion:
          _staticMealSuggestion, // mock: no meal service yet
      environment:
          _staticEnvironment, // mock: no environment API yet
      lumiSuggestion:
          _staticLumiSuggestion, // mock: no AI suggestion layer yet
    );
  }

  // --- mock sections (backend does not yet provide) ---

  static const _staticWater = TodayWaterSummary(
    completedCount: 5,
    targetCount: 8,
  );

  static const _staticVitals = <TodayVitalSummary>[
    TodayVitalSummary(type: TodayVitalType.heartRate, valueLabel: '72'),
    TodayVitalSummary(type: TodayVitalType.bloodPressure, valueLabel: '118/76'),
    TodayVitalSummary(type: TodayVitalType.sleep, valueLabel: '7.2'),
  ];

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
