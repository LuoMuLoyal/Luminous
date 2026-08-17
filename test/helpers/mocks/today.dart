import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/domain/repositories/dashboard.dart';

/// Test-only mock implementation of [TodayRepository].
///
/// Vital/metric values are intentionally placeholder so they cannot be
/// mistaken for real health data.
class MockTodayRepository implements TodayRepository {
  const MockTodayRepository();

  @override
  Future<TodayDashboard> get signedOutDashboard =>
      Future.value(placeholderDashboard);

  static const placeholderDashboard = TodayDashboard(
    user: TodayUserSnapshot(
      moment: TodayDayMoment.morning,
      hasUnreadNotifications: false,
      updatedAtLabel: '--:--',
    ),
    water: TodayWaterSummary(
      completedCount: 0,
      targetCount: TodayDashboard.defaultWaterTargetCount,
    ),
    medication: TodayMedicationSummary(
      medicineCount: 0,
      pendingCount: 0,
      nextDoseTimeLabel: '--:--',
    ),
    vitals: <TodayVitalSummary>[
      TodayVitalSummary(type: TodayVitalType.heartRate, valueLabel: '--'),
      TodayVitalSummary(type: TodayVitalType.bloodPressure, valueLabel: '--'),
      TodayVitalSummary(type: TodayVitalType.sleep, valueLabel: '--'),
      TodayVitalSummary(type: TodayVitalType.mood, valueLabel: '--'),
    ],
    mealSuggestion: TodayMealSuggestion(
      type: TodayMealSuggestionType.highProteinBalancedLunch,
    ),
    environment: TodayEnvironmentSummary(
      signals: <TodayEnvironmentSignal>[
        TodayEnvironmentSignal(
          type: TodayEnvironmentSignalType.pollen,
          level: TodayEnvironmentLevel.low,
        ),
        TodayEnvironmentSignal(
          type: TodayEnvironmentSignalType.uv,
          level: TodayEnvironmentLevel.low,
        ),
      ],
    ),
    lumiSuggestion: TodayLumiSuggestion(
      type: TodayLumiSuggestionType.pollenProtection,
    ),
  );

  static const previewDashboard = TodayDashboard(
    user: TodayUserSnapshot(
      moment: TodayDayMoment.morning,
      hasUnreadNotifications: true,
      updatedAtLabel: '--:--',
    ),
    water: TodayWaterSummary(completedCount: 5, targetCount: 8),
    medication: TodayMedicationSummary(
      medicineCount: 1,
      pendingCount: 1,
      nextDoseTimeLabel: '--:--',
    ),
    vitals: <TodayVitalSummary>[
      TodayVitalSummary(type: TodayVitalType.heartRate, valueLabel: '--'),
      TodayVitalSummary(type: TodayVitalType.bloodPressure, valueLabel: '--'),
      TodayVitalSummary(type: TodayVitalType.sleep, valueLabel: '--'),
      TodayVitalSummary(type: TodayVitalType.mood, valueLabel: '--'),
    ],
    mealSuggestion: TodayMealSuggestion(
      type: TodayMealSuggestionType.highProteinBalancedLunch,
    ),
    environment: TodayEnvironmentSummary(
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
    ),
    lumiSuggestion: TodayLumiSuggestion(
      type: TodayLumiSuggestionType.pollenProtection,
    ),
  );

  @override
  Future<TodayDashboard> fetchDashboard() async {
    return previewDashboard;
  }
}
