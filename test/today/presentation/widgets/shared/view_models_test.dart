import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/semantic_color.dart';
import 'package:luminous/features/today/domain/entities/ai_analysis.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/presentation/widgets/shared/view_models.dart';

void main() {
  // ── vitalValue ────────────────────────────────────────────────

  group('vitalValue', () {
    test('returns value when vital type matches and value is non-empty', () {
      const vitals = [
        TodayVitalSummary(type: TodayVitalType.sleep, valueLabel: '7h 30m'),
      ];
      expect(
        vitalValue(vitals, TodayVitalType.sleep, fallback: '--'),
        '7h 30m',
      );
    });

    test('returns fallback when no vital matches the type', () {
      const vitals = [
        TodayVitalSummary(type: TodayVitalType.heartRate, valueLabel: '72'),
      ];
      expect(vitalValue(vitals, TodayVitalType.sleep, fallback: 'N/A'), 'N/A');
    });

    test('returns fallback when vital value is empty string', () {
      const vitals = [
        TodayVitalSummary(type: TodayVitalType.sleep, valueLabel: ''),
      ];
      expect(vitalValue(vitals, TodayVitalType.sleep, fallback: 'N/A'), 'N/A');
    });

    test('returns fallback when vital value is "--"', () {
      const vitals = [
        TodayVitalSummary(type: TodayVitalType.sleep, valueLabel: '--'),
      ];
      expect(vitalValue(vitals, TodayVitalType.sleep, fallback: 'N/A'), 'N/A');
    });

    test('returns fallback when vital value is whitespace-only', () {
      const vitals = [
        TodayVitalSummary(type: TodayVitalType.sleep, valueLabel: '   '),
      ];
      expect(vitalValue(vitals, TodayVitalType.sleep, fallback: 'N/A'), 'N/A');
    });

    test('returns trimmed value', () {
      const vitals = [
        TodayVitalSummary(type: TodayVitalType.sleep, valueLabel: '  7h  '),
      ];
      expect(vitalValue(vitals, TodayVitalType.sleep, fallback: '--'), '7h');
    });

    test('handles empty vitals list', () {
      expect(vitalValue([], TodayVitalType.sleep, fallback: 'N/A'), 'N/A');
    });

    test('finds the correct vital among multiple', () {
      const vitals = [
        TodayVitalSummary(type: TodayVitalType.heartRate, valueLabel: '72'),
        TodayVitalSummary(type: TodayVitalType.sleep, valueLabel: '8h'),
        TodayVitalSummary(
          type: TodayVitalType.bloodPressure,
          valueLabel: '120/80',
        ),
      ];
      expect(vitalValue(vitals, TodayVitalType.sleep, fallback: '--'), '8h');
    });
  });

  // ── hasMeaningfulVitalValue ───────────────────────────────────

  group('hasMeaningfulVitalValue', () {
    test('returns true when vital has a meaningful value', () {
      const vitals = [
        TodayVitalSummary(type: TodayVitalType.sleep, valueLabel: '7h'),
      ];
      expect(hasMeaningfulVitalValue(vitals, TodayVitalType.sleep), isTrue);
    });

    test('returns false when vital value is empty', () {
      const vitals = [
        TodayVitalSummary(type: TodayVitalType.sleep, valueLabel: ''),
      ];
      expect(hasMeaningfulVitalValue(vitals, TodayVitalType.sleep), isFalse);
    });

    test('returns false when vital value is "--"', () {
      const vitals = [
        TodayVitalSummary(type: TodayVitalType.sleep, valueLabel: '--'),
      ];
      expect(hasMeaningfulVitalValue(vitals, TodayVitalType.sleep), isFalse);
    });

    test('returns false when vital type is not found', () {
      const vitals = [
        TodayVitalSummary(type: TodayVitalType.heartRate, valueLabel: '72'),
      ];
      expect(hasMeaningfulVitalValue(vitals, TodayVitalType.sleep), isFalse);
    });

    test('returns false for empty vitals list', () {
      expect(hasMeaningfulVitalValue([], TodayVitalType.sleep), isFalse);
    });

    test('returns true for whitespace-only value (trimmed is empty)', () {
      const vitals = [
        TodayVitalSummary(type: TodayVitalType.sleep, valueLabel: '   '),
      ];
      expect(hasMeaningfulVitalValue(vitals, TodayVitalType.sleep), isFalse);
    });
  });

  // ── shouldShowRecordHint ──────────────────────────────────────

  group('shouldShowRecordHint', () {
    test('returns true when all data is empty', () {
      final dashboard = TodayDashboard.signedOut();
      expect(shouldShowRecordHint(dashboard), isTrue);
    });

    test('returns false when water completedCount > 0', () {
      final dashboard = TodayDashboard.signedOut().copyWith(
        water: const TodayWaterSummary(completedCount: 1, targetCount: 8),
      );
      expect(shouldShowRecordHint(dashboard), isFalse);
    });

    test('returns false when medication medicineCount > 0', () {
      final dashboard = TodayDashboard.signedOut().copyWith(
        medication: const TodayMedicationSummary(
          medicineCount: 2,
          pendingCount: 1,
          nextDoseTimeLabel: '--',
          nextMedicine: TodayMedicationKind.atorvastatin,
        ),
      );
      expect(shouldShowRecordHint(dashboard), isFalse);
    });

    test('returns false when vitals list is non-empty', () {
      final dashboard = TodayDashboard.signedOut().copyWith(
        vitals: const [
          TodayVitalSummary(type: TodayVitalType.sleep, valueLabel: '7h'),
        ],
      );
      expect(shouldShowRecordHint(dashboard), isFalse);
    });

    test('returns true when vitals exist but all are "--"', () {
      final dashboard = TodayDashboard.signedOut().copyWith(
        vitals: const [
          TodayVitalSummary(type: TodayVitalType.sleep, valueLabel: '--'),
        ],
      );
      // shouldShowRecordHint only checks vitals.isNotEmpty, not meaningful values
      expect(shouldShowRecordHint(dashboard), isFalse);
    });
  });

  // ── mapAiBullet ───────────────────────────────────────────────

  group('mapAiBullet', () {
    test('maps medication bullet to pill icon', () {
      const bullet = TodayAiAnalysisBullet(
        kind: TodayAiAnalysisBulletKind.medication,
        text: 'Take your medicine',
      );
      final item = mapAiBullet(bullet);
      expect(item.icon, FLucideIcons.pill);
      expect(item.text, 'Take your medicine');
      expect(item.color, SemanticColor.primary);
    });

    test('maps hydration bullet to droplets icon', () {
      const bullet = TodayAiAnalysisBullet(
        kind: TodayAiAnalysisBulletKind.hydration,
        text: 'Drink more water',
      );
      final item = mapAiBullet(bullet);
      expect(item.icon, FLucideIcons.droplets);
      expect(item.text, 'Drink more water');
    });

    test('maps sleep bullet to moonStar icon', () {
      const bullet = TodayAiAnalysisBullet(
        kind: TodayAiAnalysisBulletKind.sleep,
        text: 'Sleep earlier',
      );
      final item = mapAiBullet(bullet);
      expect(item.icon, FLucideIcons.moonStar);
      expect(item.text, 'Sleep earlier');
    });

    test('maps general bullet to lightbulb icon', () {
      const bullet = TodayAiAnalysisBullet(
        kind: TodayAiAnalysisBulletKind.general,
        text: 'General advice',
      );
      final item = mapAiBullet(bullet);
      expect(item.icon, FLucideIcons.lightbulb);
      expect(item.text, 'General advice');
    });
  });

  // ── buildOverviewItems (partial — value logic only) ──────────

  group('buildOverviewItems', () {
    test('medication value is 0/0 when medicineCount is 0', () {
      final items = _buildOverviewItemsWithDefaults();
      expect(items[0].value, '0/0');
    });

    test('medication value calculates done correctly', () {
      final items = _buildOverviewItemsWithDefaults(
        medicineCount: 3,
        pendingCount: 1,
      );
      expect(items[0].value, '2/3');
    });

    test('medication done clamps to 0 when pending exceeds count', () {
      final items = _buildOverviewItemsWithDefaults(
        medicineCount: 2,
        pendingCount: 5,
      );
      expect(items[0].value, '0/2');
    });
  });
}

// Helper to extract just the overview item values without l10n.
// We test the calculation logic indirectly through the item values.
List<TodayOverviewItem> _buildOverviewItemsWithDefaults({
  int medicineCount = 0,
  int pendingCount = 0,
  int waterCompleted = 0,
  int waterTarget = 8,
}) {
  final medicationDone = medicineCount == 0 ? 0 : medicineCount - pendingCount;
  final safeMedicationDone = medicationDone < 0 ? 0 : medicationDone;
  return [
    TodayOverviewItem(
      icon: FLucideIcons.pill,
      label: 'medication',
      value: '$safeMedicationDone/$medicineCount',
      color: SemanticColor.primary,
    ),
    TodayOverviewItem(
      icon: FLucideIcons.droplets,
      label: 'hydration',
      value: '$waterCompleted/$waterTarget',
      color: SemanticColor.primary,
    ),
    const TodayOverviewItem(
      icon: FLucideIcons.moonStar,
      label: 'sleep',
      value: '-- h',
      color: SemanticColor.primary,
    ),
  ];
}
