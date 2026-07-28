import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/sections/quick_entry_panel.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../../../helpers/test_forui_app.dart';

void main() {
  group('RecordQuickEntryPanel', () {
    late AppLocalizations l10n;

    setUpAll(() async {
      l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    });

    testWidgets('renders six grid tiles and one separate note tile', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(480, 1200);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      final actions = RecordDashboard.signedOut(
        DateTime(2026, 7, 21),
      ).quickActions;
      expect(actions.length, 7, reason: 'test setup must provide 7 actions');

      await tester.pumpWidget(
        ProviderScope(
          child: TestForuiApp(
            home: Scaffold(
              body: RecordQuickEntryPanel(actions: actions, l10n: l10n),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('record-quick-help-action')), findsOneWidget);
      expect(find.byKey(const Key('record-quick-dynamic-sort')), findsNothing);

      final gridTileKeys = <String>[
        'record-quick-symptom',
        'record-quick-medication',
        'record-quick-water',
        'record-quick-meal',
        'record-quick-sleep',
        'record-quick-mood',
      ];

      for (final key in gridTileKeys) {
        expect(find.byKey(Key(key)), findsOneWidget);
      }

      // Note must be rendered as a separate tile, not inside the 3-column grid.
      expect(find.byKey(const Key('record-quick-note')), findsOneWidget);

      // Total quick-action tappable tiles must be exactly seven.
      final allTileKeys = [...gridTileKeys, 'record-quick-note'];
      var totalTiles = 0;
      for (final key in allTileKeys) {
        totalTiles += find.byKey(Key(key)).evaluate().length;
      }
      expect(totalTiles, 7);
    });

    testWidgets('note tile uses horizontal icon-left text-right layout', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(480, 1200);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      final actions = RecordDashboard.signedOut(
        DateTime(2026, 7, 21),
      ).quickActions;

      await tester.pumpWidget(
        ProviderScope(
          child: TestForuiApp(
            home: Scaffold(
              body: RecordQuickEntryPanel(actions: actions, l10n: l10n),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final noteFinder = find.byKey(const Key('record-quick-note'));
      expect(noteFinder, findsOneWidget);

      // Note must not be rendered as a Forui ghost button (the old gray style).
      expect(
        find.descendant(of: noteFinder, matching: find.byType(FButton)),
        findsNothing,
      );

      // Note must contain an FAvatar with the same subtle background as grid tiles.
      final avatarFinder = find.descendant(
        of: noteFinder,
        matching: find.byType(FAvatar),
      );
      expect(avatarFinder, findsOneWidget);

      // Note must lay out icon and label horizontally (Row), not vertically (Column).
      final rowFinder = find.descendant(
        of: noteFinder,
        matching: find.byType(Row),
      );
      expect(rowFinder, findsOneWidget);
      expect(
        find.descendant(of: noteFinder, matching: find.byType(Column)),
        findsNothing,
      );
    });

    testWidgets('default quick actions include medication and mood', (
      tester,
    ) async {
      final dashboard = RecordDashboard.signedOut(DateTime(2026, 7, 21));

      expect(dashboard.quickActions.length, 7);
      final types = dashboard.quickActions.map((a) => a.type).toSet();
      expect(types, contains(RecordEntryType.medication));
      expect(types, contains(RecordEntryType.mood));
    });
  });
}
