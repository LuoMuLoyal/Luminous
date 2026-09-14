import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/record/domain/services/sleep_entry.dart';
import 'package:luminous/features/record/presentation/widgets/forms/sleep_structured_fields.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../../../helpers/test_forui_app.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('zh'));
  });

  Future<void> pumpFields(
    WidgetTester tester, {
    required SleepEntryKind kind,
    required ValueChanged<SleepEntryKind> onKindChanged,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(480, 1200);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SleepStructuredFields(
              l10n: l10n,
              sleepKind: kind,
              bedtime: const TimeOfDay(hour: 23, minute: 0),
              wakeTime: const TimeOfDay(hour: 7, minute: 0),
              onSleepKindChanged: onKindChanged,
              onBedtimeChanged: (_) {},
              onWakeTimeChanged: (_) {},
              onQualityChanged: (_) {},
              onDeepMinutesChanged: (_) {},
              onLightMinutesChanged: (_) {},
              onRemMinutesChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('exposes night sleep and nap tabs', (tester) async {
    final changes = <SleepEntryKind>[];
    await pumpFields(
      tester,
      kind: SleepEntryKind.nightSleep,
      onKindChanged: changes.add,
    );

    expect(find.byKey(const Key('sleep-kind-tabs')), findsOneWidget);
    expect(find.text(l10n.recordSleepKindNight), findsOneWidget);
    expect(find.text(l10n.recordSleepKindNap), findsOneWidget);
    expect(find.byKey(const Key('sleep-bedtime-picker')), findsOneWidget);
    expect(find.byKey(const Key('sleep-waketime-picker')), findsOneWidget);

    await tester.tap(find.text(l10n.recordSleepKindNap));
    await tester.pumpAndSettle();

    expect(changes, [SleepEntryKind.nap]);
  });

  testWidgets('shows the derived duration', (tester) async {
    await pumpFields(
      tester,
      kind: SleepEntryKind.nightSleep,
      onKindChanged: (_) {},
    );

    // 23:00 → 07:00
    expect(find.textContaining('8'), findsWidgets);
    expect(find.byKey(const Key('sleep-quality-field')), findsOneWidget);
  });
}
