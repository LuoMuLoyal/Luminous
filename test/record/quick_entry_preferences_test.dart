import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/record/data/quick_entry_preferences.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QuickEntryPreferences', () {
    test('default values', () {
      const prefs = QuickEntryPreferences();
      expect(prefs.dynamicSortEnabled, isFalse);
      expect(prefs.customOrder, isEmpty);
      expect(prefs.collapsed, isFalse);
      expect(prefs.frequency, isEmpty);
    });

    test('copyWith creates new instance with updated values', () {
      const original = QuickEntryPreferences();
      final updated = original.copyWith(
        dynamicSortEnabled: true,
        customOrder: const ['meal', 'water'],
        collapsed: true,
        frequency: const {'meal': 5},
      );

      expect(updated.dynamicSortEnabled, isTrue);
      expect(updated.customOrder, ['meal', 'water']);
      expect(updated.collapsed, isTrue);
      expect(updated.frequency, {'meal': 5});

      // Original unchanged
      expect(original.dynamicSortEnabled, isFalse);
      expect(original.customOrder, isEmpty);
      expect(original.collapsed, isFalse);
      expect(original.frequency, isEmpty);
    });

    test('copyWith partial update preserves other fields', () {
      const original = QuickEntryPreferences(
        dynamicSortEnabled: true,
        customOrder: ['water'],
        collapsed: true,
        frequency: {'water': 3},
      );

      final updated = original.copyWith(collapsed: false);

      expect(updated.dynamicSortEnabled, isTrue);
      expect(updated.customOrder, ['water']);
      expect(updated.collapsed, isFalse);
      expect(updated.frequency, {'water': 3});
    });
  });

  group('QuickEntryPreferencesController', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
      addTearDown(container.dispose);
    });

    Future<QuickEntryPreferences> readPrefs() async {
      return container.read(quickEntryPreferencesProvider.future);
    }

    test('build loads default values when no preferences stored', () async {
      final prefs = await readPrefs();

      expect(prefs.dynamicSortEnabled, isFalse);
      expect(prefs.customOrder, isEmpty);
      expect(prefs.collapsed, isFalse);
      expect(prefs.frequency, isEmpty);
    });

    test('build loads stored values from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'record.quickEntry.dynamicSortEnabled': true,
        'record.quickEntry.customOrder': ['meal', 'water'],
        'record.quickEntry.collapsed': true,
        'record.quickEntry.freq.meal': 5,
        'record.quickEntry.freq.water': 3,
      });

      final c = ProviderContainer();
      addTearDown(c.dispose);

      final prefs = await c.read(quickEntryPreferencesProvider.future);

      expect(prefs.dynamicSortEnabled, isTrue);
      expect(prefs.customOrder, ['meal', 'water']);
      expect(prefs.collapsed, isTrue);
      expect(prefs.frequency, {'meal': 5, 'water': 3});
    });

    test('setDynamicSortEnabled updates state and persists', () async {
      await readPrefs();

      final controller = container.read(
        quickEntryPreferencesProvider.notifier,
      );
      await controller.setDynamicSortEnabled(true);

      final state = container.read(quickEntryPreferencesProvider).requireValue;
      expect(state.dynamicSortEnabled, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('record.quickEntry.dynamicSortEnabled'), isTrue);
    });

    test('setCustomOrder updates state and persists', () async {
      await readPrefs();

      final controller = container.read(
        quickEntryPreferencesProvider.notifier,
      );
      await controller.setCustomOrder(['meal', 'sleep', 'water']);

      final state = container.read(quickEntryPreferencesProvider).requireValue;
      expect(state.customOrder, ['meal', 'sleep', 'water']);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('record.quickEntry.customOrder'),
          ['meal', 'sleep', 'water']);
    });

    test('setCollapsed updates state and persists', () async {
      await readPrefs();

      final controller = container.read(
        quickEntryPreferencesProvider.notifier,
      );
      await controller.setCollapsed(true);

      final state = container.read(quickEntryPreferencesProvider).requireValue;
      expect(state.collapsed, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('record.quickEntry.collapsed'), isTrue);
    });

    test('recordTap increments frequency count', () async {
      await readPrefs();

      final controller = container.read(
        quickEntryPreferencesProvider.notifier,
      );
      await controller.recordTap(RecordEntryType.meal);
      await controller.recordTap(RecordEntryType.meal);
      await controller.recordTap(RecordEntryType.water);

      final freq = container.read(quickEntryPreferencesProvider).requireValue.frequency;
      expect(freq['meal'], 2);
      expect(freq['water'], 1);
    });

    test('recordTap persists frequency to SharedPreferences', () async {
      await readPrefs();

      final controller = container.read(
        quickEntryPreferencesProvider.notifier,
      );
      await controller.recordTap(RecordEntryType.mood);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('record.quickEntry.freq.mood'), 1);
    });

    test('recordTap trims proportionally when total exceeds 50', () async {
      await readPrefs();

      final controller = container.read(
        quickEntryPreferencesProvider.notifier,
      );

      // Record 51 taps across two types
      for (var i = 0; i < 30; i++) {
        await controller.recordTap(RecordEntryType.meal);
      }
      for (var i = 0; i < 21; i++) {
        await controller.recordTap(RecordEntryType.water);
      }

      final freq = container.read(quickEntryPreferencesProvider).requireValue.frequency;

      // Total should be trimmed to ≤ 50
      final total = freq.values.fold(0, (a, b) => a + b);
      expect(total, lessThanOrEqualTo(50));

      // Meal should still have more counts than water (proportional)
      expect(freq['meal']!, greaterThan(freq['water']!));
    });

    test('recordTap removes zero entries after trimming', () async {
      await readPrefs();

      final controller = container.read(
        quickEntryPreferencesProvider.notifier,
      );

      // Record one type heavily and another just once
      for (var i = 0; i < 50; i++) {
        await controller.recordTap(RecordEntryType.meal);
      }
      await controller.recordTap(RecordEntryType.weight);

      final freq = container.read(quickEntryPreferencesProvider).requireValue.frequency;

      // weight count should be 0 after trimming and thus removed
      // (1 * 50/51 = 0.98 → floor = 0)
      expect(freq.containsKey('weight'), isFalse);
    });

    test('reset clears all state and SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'record.quickEntry.dynamicSortEnabled': true,
        'record.quickEntry.customOrder': ['meal'],
        'record.quickEntry.collapsed': true,
        'record.quickEntry.freq.meal': 5,
      });

      final c = ProviderContainer();
      addTearDown(c.dispose);

      await c.read(quickEntryPreferencesProvider.future);

      final controller = c.read(quickEntryPreferencesProvider.notifier);
      await controller.reset();

      final state = c.read(quickEntryPreferencesProvider).requireValue;
      expect(state.dynamicSortEnabled, isFalse);
      expect(state.customOrder, isEmpty);
      expect(state.collapsed, isFalse);
      expect(state.frequency, isEmpty);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('record.quickEntry.dynamicSortEnabled'), isNull);
      expect(prefs.getStringList('record.quickEntry.customOrder'), isNull);
      expect(prefs.getBool('record.quickEntry.collapsed'), isNull);
      expect(prefs.getInt('record.quickEntry.freq.meal'), isNull);
    });
  });
}
