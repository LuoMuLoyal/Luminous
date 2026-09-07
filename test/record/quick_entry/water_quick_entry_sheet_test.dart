import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/record/presentation/widgets/dialogs/water_quick_entry_sheet.dart';

import '../../helpers/test_forui_app.dart';

void main() {
  Future<void> openSheet(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showWaterQuickEntrySheet(context),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  Future<void> openSheetAndCollect(
    WidgetTester tester,
    ValueChanged<WaterQuickEntryResult?> onResult,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                onResult(await showWaterQuickEntrySheet(context));
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('WaterQuickEntrySheet renders preset chips and manual field', (
    tester,
  ) async {
    await openSheet(tester);

    // All preset chips use the "+X ml" pattern in a 3-column grid.
    expect(find.text('+50ml'), findsOneWidget);
    expect(find.text('+100ml'), findsOneWidget);
    expect(find.text('+150ml'), findsOneWidget);
    expect(find.text('+200ml'), findsOneWidget);
    expect(find.text('+250ml'), findsOneWidget);
    expect(find.text('+300ml'), findsOneWidget);
    expect(find.text('+350ml'), findsOneWidget);
    expect(find.text('+400ml'), findsOneWidget);
    expect(find.text('+500ml'), findsOneWidget);
    expect(find.text('+750ml'), findsOneWidget);
    expect(find.text('+1000ml'), findsOneWidget);

    // No plain "200ml" etc. labels (all have the + prefix).
    expect(find.text('200ml'), findsNothing);
    expect(find.text('500ml'), findsNothing);

    // Manual input + confirm (next to the field).
    expect(
      find.byKey(const Key('water-quick-entry-manual-field')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('water-quick-entry-manual-confirm')),
      findsOneWidget,
    );
  });

  testWidgets('WaterQuickEntrySheet returns result on preset tap', (
    tester,
  ) async {
    WaterQuickEntryResult? result;
    await openSheetAndCollect(tester, (v) => result = v);

    await tester.tap(find.text('+500ml'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.amountMl, 500);
    expect(result!.unit, 'ml');
  });

  testWidgets(
    'WaterQuickEntrySheet manual input validates and returns result',
    (tester) async {
      WaterQuickEntryResult? result;
      await openSheetAndCollect(tester, (v) => result = v);

      await tester.enterText(
        find.byKey(const Key('water-quick-entry-manual-field')),
        '333',
      );
      await tester.tap(
        find.byKey(const Key('water-quick-entry-manual-confirm')),
      );
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.amountMl, 333);
      expect(result!.unit, 'ml');
    },
  );

  testWidgets('WaterQuickEntrySheet returns null on dismiss via outside tap', (
    tester,
  ) async {
    WaterQuickEntryResult? result;
    await openSheetAndCollect(tester, (v) => result = v);

    // Tap the barrier (outside the sheet) to dismiss.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });
}
