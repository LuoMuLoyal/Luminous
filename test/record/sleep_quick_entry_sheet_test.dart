import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/features/record/domain/services/sleep_entry.dart';
import 'package:luminous/features/record/presentation/utils/sleep_formatters.dart';
import 'package:luminous/features/record/presentation/widgets/dialogs/sleep_quick_entry_sheet.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../helpers/test_forui_app.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('zh'));
  });

  /// Opens the real sheet entry point and returns the list that receives the
  /// sheet result once it pops (empty while the sheet is still open).
  Future<List<SleepQuickEntryResult?>> openSheet(
    WidgetTester tester, {
    required SleepEntryKind kind,
    required TimeOfDay bedtime,
    required TimeOfDay wakeTime,
    DateTime? recordDate,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(480, 1200);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    final captured = <SleepQuickEntryResult?>[];
    await tester.pumpWidget(
      TestForuiApp(
        home: Builder(
          builder: (context) => Center(
            child: FButton(
              key: const Key('open-sleep-sheet'),
              onPress: () async {
                captured.add(
                  await showSleepQuickEntrySheet(
                    context,
                    recordDate: recordDate ?? DateTime(2026, 9, 14),
                    initialKind: kind,
                    initialBedtime: bedtime,
                    initialWakeTime: wakeTime,
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('open-sleep-sheet')));
    await tester.pumpAndSettle();
    return captured;
  }

  Future<void> save(WidgetTester tester) async {
    final button = find.byKey(const Key('sleep-quick-entry-save'));
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  testWidgets('shows the record date and the derived duration', (tester) async {
    final captured = await openSheet(
      tester,
      kind: SleepEntryKind.nightSleep,
      bedtime: const TimeOfDay(hour: 23, minute: 0),
      wakeTime: const TimeOfDay(hour: 7, minute: 0),
    );

    expect(find.text(l10n.recordQuickSleepSheetTitle), findsOneWidget);
    // The record date (wake date) must be spelled out in the form.
    expect(find.text(l10n.recordQuickSleepRecordedOn(9, 14)), findsOneWidget);
    expect(
      find.text(
        '${l10n.recordSleepDurationLabel}: '
        '${formatSleepDurationLabel(480, l10n)}',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('sleep-quick-entry-error')), findsNothing);
    expect(captured, isEmpty, reason: 'nothing is recorded before saving');

    await save(tester);

    expect(captured, hasLength(1));
    final result = captured.single!;
    expect(result.kind, SleepEntryKind.nightSleep);
    expect(result.bedtime, const TimeOfDay(hour: 23, minute: 0));
    expect(result.wakeTime, const TimeOfDay(hour: 7, minute: 0));
    expect(result.quality, isNull);
    expect(result.note, isNull);
  });

  testWidgets('switching to nap falls back to a same-day window', (
    tester,
  ) async {
    final captured = await openSheet(
      tester,
      kind: SleepEntryKind.nightSleep,
      bedtime: const TimeOfDay(hour: 23, minute: 0),
      wakeTime: const TimeOfDay(hour: 7, minute: 0),
    );

    await tester.tap(find.text(l10n.recordQuickSleepNapAction));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('sleep-quick-entry-error')), findsNothing);

    await save(tester);

    final result = captured.single!;
    expect(result.kind, SleepEntryKind.nap);
    expect(result.bedtime, const TimeOfDay(hour: 13, minute: 0));
    expect(result.wakeTime, const TimeOfDay(hour: 13, minute: 30));
  });

  testWidgets('blocks a nap that crosses midnight', (tester) async {
    await openSheet(
      tester,
      kind: SleepEntryKind.nap,
      bedtime: const TimeOfDay(hour: 23, minute: 0),
      wakeTime: const TimeOfDay(hour: 7, minute: 0),
    );

    expect(
      find.text(l10n.recordQuickSleepNapCrossesMidnightError),
      findsOneWidget,
    );
    final button = tester.widget<FButton>(
      find.byKey(const Key('sleep-quick-entry-save')),
    );
    expect(button.onPress, isNull);
  });

  testWidgets('blocks a night sleep longer than the cap', (tester) async {
    await openSheet(
      tester,
      kind: SleepEntryKind.nightSleep,
      bedtime: const TimeOfDay(hour: 5, minute: 0),
      wakeTime: const TimeOfDay(hour: 22, minute: 0),
    );

    expect(find.text(l10n.recordQuickSleepNightTooLongError), findsOneWidget);
    final button = tester.widget<FButton>(
      find.byKey(const Key('sleep-quick-entry-save')),
    );
    expect(button.onPress, isNull);
  });

  testWidgets('returns the trimmed note', (tester) async {
    final captured = await openSheet(
      tester,
      kind: SleepEntryKind.nightSleep,
      bedtime: const TimeOfDay(hour: 23, minute: 0),
      wakeTime: const TimeOfDay(hour: 7, minute: 0),
    );

    await tester.enterText(
      find.byKey(const Key('sleep-quick-entry-note')),
      '  睡得不错  ',
    );
    await tester.pumpAndSettle();
    await save(tester);

    expect(captured.single!.note, '睡得不错');
  });
}
