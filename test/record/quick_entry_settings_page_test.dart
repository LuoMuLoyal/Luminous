import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/storage/kv_store.dart';
import 'package:luminous/features/record/presentation/pages/quick_entry_reorder.dart';
import 'package:luminous/features/record/presentation/pages/quick_entry_settings.dart';

import '../helpers/kv_test_store.dart';
import '../helpers/test_forui_app.dart';

void main() {
  testWidgets('quick-entry settings exposes first-version settings sections', (
    tester,
  ) async {
    KvTestStore.install(seed: const <String, Object>{});

    await tester.pumpWidget(
      const ProviderScope(child: TestForuiApp(home: QuickEntrySettingsPage())),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('record-quick-settings-page')), findsOneWidget);
    expect(
      find.byKey(const Key('record-quick-settings-dynamic-sort')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('record-quick-settings-reorder')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('record-quick-settings-reset-order')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('record-quick-settings-water-default')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('record-quick-settings-water-badge')),
      findsOneWidget,
    );
  });

  testWidgets('manual reorder row explains disabled state under dynamic sort', (
    tester,
  ) async {
    KvTestStore.install(
      seed: <String, Object>{'record.quickEntry.dynamicSortEnabled': true},
    );

    await tester.pumpWidget(
      const ProviderScope(child: TestForuiApp(home: QuickEntrySettingsPage())),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('record-quick-settings-reorder')),
      findsOneWidget,
    );
    expect(find.text('请先关闭动态排序再编辑顺序'), findsOneWidget);
  });

  testWidgets('reset default order clears custom order only', (tester) async {
    KvTestStore.install(
      seed: <String, Object>{
        'record.quickEntry.customOrder': ['water', 'meal'],
        'record.quickEntry.water.defaultAmountMl': 'ml500',
      },
    );

    await tester.pumpWidget(
      const ProviderScope(child: TestForuiApp(home: QuickEntrySettingsPage())),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('record-quick-settings-reset-order')),
    );
    await tester.pumpAndSettle();

    final prefs = KvStore.instance;
    expect(
      prefs.getOrNull<List<String>>('record.quickEntry.customOrder'),
      isNull,
    );
    expect(
      prefs.getOrNull<String>('record.quickEntry.water.defaultAmountMl'),
      'ml500',
    );
  });

  testWidgets('custom water default prompts for ml and persists', (
    tester,
  ) async {
    KvTestStore.install(seed: const <String, Object>{});

    await tester.pumpWidget(
      const ProviderScope(child: TestForuiApp(home: QuickEntrySettingsPage())),
    );
    await tester.pumpAndSettle();

    // Open the water default choice list and pick the custom option.
    await tester.tap(
      find.byKey(const Key('record-quick-settings-water-default')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('自定义 (250 ml)').last);
    await tester.pumpAndSettle();

    // The amount dialog appears; enter a new amount and confirm.
    expect(find.byKey(const Key('water-custom-ml-field')), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('water-custom-ml-field')),
      '400',
    );
    await tester.tap(find.byKey(const Key('water-custom-ml-confirm')));
    await tester.pumpAndSettle();

    // The select now shows the custom amount and preferences persist.
    expect(find.text('自定义 (400 ml)'), findsOneWidget);
    final prefs = KvStore.instance;
    expect(
      prefs.getOrNull<String>('record.quickEntry.water.defaultAmountMl'),
      'custom',
    );
    expect(
      prefs.get<int>('record.quickEntry.water.customMl', fallback: 0),
      400,
    );
  });

  testWidgets('custom icon section lists every quick type with reset', (
    tester,
  ) async {
    KvTestStore.install(seed: const <String, Object>{});

    await tester.pumpWidget(
      const ProviderScope(child: TestForuiApp(home: QuickEntrySettingsPage())),
    );
    await tester.pumpAndSettle();

    for (final type in const [
      'symptom',
      'medication',
      'water',
      'meal',
      'sleep',
      'mood',
      'note',
    ]) {
      expect(
        find.byKey(Key('record-quick-settings-icon-$type')),
        findsOneWidget,
        reason: 'expected an icon tile for $type',
      );
    }

    // Reset is disabled when no custom icons are configured.
    final resetTile = tester.widget<FTile>(
      find.byKey(const Key('record-quick-settings-reset-icons')),
    );
    expect(resetTile.onPress, isNull);
  });

  testWidgets('custom icon reset clears stored custom icons', (tester) async {
    KvTestStore.install(
      seed: <String, Object>{
        'record.quickEntry.customIcons': ['water:coffee'],
      },
    );

    await tester.pumpWidget(
      const ProviderScope(child: TestForuiApp(home: QuickEntrySettingsPage())),
    );
    await tester.pumpAndSettle();

    final resetTile = tester.widget<FTile>(
      find.byKey(const Key('record-quick-settings-reset-icons')),
    );
    expect(resetTile.onPress, isNotNull);

    final resetFinder = find.byKey(
      const Key('record-quick-settings-reset-icons'),
    );
    await tester.ensureVisible(resetFinder);
    await tester.pumpAndSettle();
    await tester.tap(resetFinder);
    await tester.pumpAndSettle();

    final prefs = KvStore.instance;
    expect(
      prefs.getOrNull<List<String>>('record.quickEntry.customIcons'),
      isNull,
    );
  });

  testWidgets(
    'manual reorder page lists quick actions when dynamic sort is off',
    (tester) async {
      KvTestStore.install(seed: const <String, Object>{});

      await tester.pumpWidget(
        const ProviderScope(child: TestForuiApp(home: QuickEntryReorderPage())),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('record-quick-reorder-list')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('record-quick-reorder-water')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('record-quick-reorder-meal')),
        findsOneWidget,
      );
    },
  );

  testWidgets('manual reorder page blocks editing when dynamic sort is on', (
    tester,
  ) async {
    KvTestStore.install(
      seed: <String, Object>{'record.quickEntry.dynamicSortEnabled': true},
    );

    await tester.pumpWidget(
      const ProviderScope(child: TestForuiApp(home: QuickEntryReorderPage())),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('record-quick-reorder-disabled')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('record-quick-reorder-list')), findsNothing);
  });
}
