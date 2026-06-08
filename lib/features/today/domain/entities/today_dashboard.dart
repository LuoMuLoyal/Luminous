TodayDayMoment todayDayMomentFromHour(int hour) {
  if (hour < 12) return TodayDayMoment.morning;
  if (hour < 18) return TodayDayMoment.afternoon;
  return TodayDayMoment.evening;
}

enum TodayDayMoment { morning, afternoon, evening }

enum TodayMedicationKind { atorvastatin, vitaminBComplex }

// Deferred by Product_Vision MVP: keep the lightweight mood vital type because
// future self-check-ins may use it, but do not surface it as a formal
// mental-health module in Today.
enum TodayVitalType { heartRate, bloodPressure, sleep, mood }

enum TodayMealSuggestionType { highProteinBalancedLunch }

enum TodayEnvironmentSignalType { pollen, uv }

enum TodayEnvironmentLevel { low, medium, high }

enum TodayLumiSuggestionType { pollenProtection }

class TodayDashboard {
  const TodayDashboard({
    required this.user,
    required this.water,
    required this.medication,
    required this.vitals,
    required this.mealSuggestion,
    required this.environment,
    required this.lumiSuggestion,
  });

  final TodayUserSnapshot user;
  final TodayWaterSummary water;
  final TodayMedicationSummary medication;
  final List<TodayVitalSummary> vitals;
  final TodayMealSuggestion mealSuggestion;

  // Deferred by Product_Vision MVP: keep environment signals because Lucent has
  // a useful reference-data contract, but do not surface it until a concrete
  // Today or Mine product job is ready.
  final TodayEnvironmentSummary environment;
  final TodayLumiSuggestion lumiSuggestion;
}

class TodayUserSnapshot {
  const TodayUserSnapshot({
    required this.moment,
    required this.hasUnreadNotifications,
    required this.updatedAtLabel,
  });

  final TodayDayMoment moment;
  final bool hasUnreadNotifications;
  final String updatedAtLabel;
}

class TodayWaterSummary {
  const TodayWaterSummary({
    required this.completedCount,
    required this.targetCount,
  }) : assert(targetCount > 0);

  final int completedCount;
  final int targetCount;

  int get remainingCount {
    final remaining = targetCount - completedCount;
    return remaining < 0 ? 0 : remaining;
  }

  double get progress {
    final ratio = completedCount / targetCount;
    return ratio.clamp(0, 1).toDouble();
  }
}

class TodayMedicationSummary {
  const TodayMedicationSummary({
    required this.medicineCount,
    required this.pendingCount,
    required this.nextDoseTimeLabel,
    required this.nextMedicine,
    this.nextMedicineName,
  });

  final int medicineCount;
  final int pendingCount;
  final String nextDoseTimeLabel;
  final TodayMedicationKind nextMedicine;

  /// When non-null, the view should use this raw name instead of the
  /// [nextMedicine] enum. Set by the real repository from health-context data.
  final String? nextMedicineName;
}

class TodayVitalSummary {
  const TodayVitalSummary({required this.type, required this.valueLabel});

  final TodayVitalType type;
  final String valueLabel;
}

class TodayMealSuggestion {
  const TodayMealSuggestion({required this.type});

  final TodayMealSuggestionType type;
}

class TodayEnvironmentSummary {
  const TodayEnvironmentSummary({required this.signals});

  final List<TodayEnvironmentSignal> signals;
}

class TodayEnvironmentSignal {
  const TodayEnvironmentSignal({required this.type, required this.level});

  final TodayEnvironmentSignalType type;
  final TodayEnvironmentLevel level;
}

class TodayLumiSuggestion {
  const TodayLumiSuggestion({required this.type});

  final TodayLumiSuggestionType type;
}
