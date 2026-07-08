import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/colors.dart';
import 'package:luminous/features/record/data/quick_entry_preferences.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/shared/dashboard_tokens.dart';

void main() {
  group('buildMobileQuickActions', () {
    final actions = <RecordQuickAction>[
      const RecordQuickAction(
        type: RecordEntryType.meal,
        icon: FLucideIcons.utensils,
        titleKey: RecordCopyKey.typeMeal,
        subtitleKey: RecordCopyKey.summaryTimesUnit,
        accent: AppColors.primary,
        softColor: AppColors.secondary,
      ),
      const RecordQuickAction(
        type: RecordEntryType.water,
        icon: FLucideIcons.cupSoda,
        titleKey: RecordCopyKey.typeWater,
        subtitleKey: RecordCopyKey.summaryCupsUnit,
        accent: AppColors.primary,
        softColor: AppColors.secondary,
      ),
      const RecordQuickAction(
        type: RecordEntryType.symptom,
        icon: FLucideIcons.cross,
        titleKey: RecordCopyKey.typeSymptom,
        subtitleKey: RecordCopyKey.summaryRecorded,
        accent: AppColors.primary,
        softColor: AppColors.secondary,
      ),
      const RecordQuickAction(
        type: RecordEntryType.note,
        icon: FLucideIcons.notebookPen,
        titleKey: RecordCopyKey.typeNote,
        subtitleKey: RecordCopyKey.summaryRecorded,
        accent: AppColors.primary,
        softColor: AppColors.secondary,
      ),
      const RecordQuickAction(
        type: RecordEntryType.sleep,
        icon: FLucideIcons.moon,
        titleKey: RecordCopyKey.typeSleep,
        subtitleKey: RecordCopyKey.summaryRecorded,
        accent: AppColors.primary,
        softColor: AppColors.secondary,
      ),
    ];

    test('default order uses defaultQuickActionOrder', () {
      final ordered = buildMobileQuickActions(actions);
      // defaultQuickActionOrder: symptom, medication, water, meal, sleep, mood, note
      // actions only has: meal, water, symptom, note, sleep
      // So filtered order: symptom, water, meal, sleep, note
      expect(ordered.first.type, RecordEntryType.symptom);
      expect(ordered[1].type, RecordEntryType.water);
      expect(ordered[2].type, RecordEntryType.meal);
      expect(ordered[3].type, RecordEntryType.sleep);
      expect(ordered[4].type, RecordEntryType.note);
    });

    test('dynamic sort enabled orders by frequency descending', () {
      final prefs = const QuickEntryPreferences(
        dynamicSortEnabled: true,
        frequency: {'water': 10, 'meal': 5, 'symptom': 0},
      );
      final ordered = buildMobileQuickActions(actions, preferences: prefs);
      // water (10) > meal (5) > symptom/note/sleep (0, default order)
      // Zero-frequency items follow defaultQuickActionOrder: symptom, sleep, note
      expect(ordered[0].type, RecordEntryType.water);
      expect(ordered[1].type, RecordEntryType.meal);
      expect(ordered[2].type, RecordEntryType.symptom);
      expect(ordered[3].type, RecordEntryType.sleep);
      expect(ordered[4].type, RecordEntryType.note);
    });

    test('custom order overrides default order when dynamic sort is off', () {
      final prefs = const QuickEntryPreferences(
        dynamicSortEnabled: false,
        customOrder: ['sleep', 'water', 'meal', 'symptom', 'note'],
      );
      final ordered = buildMobileQuickActions(actions, preferences: prefs);
      expect(ordered[0].type, RecordEntryType.sleep);
      expect(ordered[1].type, RecordEntryType.water);
      expect(ordered[2].type, RecordEntryType.meal);
      expect(ordered[3].type, RecordEntryType.symptom);
      expect(ordered[4].type, RecordEntryType.note);
    });

    test('dynamic sort takes priority over custom order', () {
      final prefs = const QuickEntryPreferences(
        dynamicSortEnabled: true,
        customOrder: ['sleep', 'water', 'meal', 'symptom', 'note'],
        frequency: {'meal': 100},
      );
      final ordered = buildMobileQuickActions(actions, preferences: prefs);
      // meal (100) should be first despite custom order saying sleep first
      expect(ordered[0].type, RecordEntryType.meal);
    });

    test('empty frequency with dynamic sort falls back to default order', () {
      final prefs = const QuickEntryPreferences(
        dynamicSortEnabled: true,
        frequency: {},
      );
      final ordered = buildMobileQuickActions(actions, preferences: prefs);
      expect(ordered.first.type, RecordEntryType.symptom);
    });

    test('actions not in preferred order are appended at the end', () {
      final extraActions = [
        ...actions,
        const RecordQuickAction(
          type: RecordEntryType.mood,
          icon: FLucideIcons.smile,
          titleKey: RecordCopyKey.typeMood,
          subtitleKey: RecordCopyKey.summaryRecorded,
          accent: AppColors.primary,
          softColor: AppColors.secondary,
        ),
      ];
      final ordered = buildMobileQuickActions(extraActions);
      // mood is in defaultQuickActionOrder but may come after others
      expect(ordered.any((a) => a.type == RecordEntryType.mood), isTrue);
      expect(ordered.length, 6);
    });
  });

  group('QuickEntryPreferences', () {
    test('default values', () {
      const prefs = QuickEntryPreferences();
      expect(prefs.dynamicSortEnabled, isFalse);
      expect(prefs.customOrder, isEmpty);
      expect(prefs.collapsed, isFalse);
      expect(prefs.frequency, isEmpty);
    });

    test('copyWith updates only specified fields', () {
      const prefs = QuickEntryPreferences();
      final updated = prefs.copyWith(dynamicSortEnabled: true, collapsed: true);
      expect(updated.dynamicSortEnabled, isTrue);
      expect(updated.collapsed, isTrue);
      expect(updated.customOrder, isEmpty);
      expect(updated.frequency, isEmpty);
    });
  });
}
