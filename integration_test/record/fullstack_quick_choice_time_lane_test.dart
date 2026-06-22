import '../support/e2e_test_helpers.dart';
import '../support/fullstack_e2e_helpers.dart';

/// Quick-choice time lane: verifies that after quick-choice save for
/// water / meal / symptom / note / sleep, the frontend displays the
/// actual HH:mm (not a fallback), that editing preserves occurredTime
/// without day-crossing, and that timeline + detail read the same
/// backend time field.
///
/// Run via the shared full-stack entrypoint:
///   dart run tool/run_fullstack_checks.dart
///
/// Or with an env-style define file:
///   dart run tool/run_fullstack_checks.dart --define-file .env.fullstack-e2e
///
/// Or standalone (e.g. for debugging a single lane):
///   cd Luminous
///   flutter test integration_test/record/fullstack_quick_choice_time_lane_test.dart \
///     --dart-define=LUCENT_BASE_URL=http://10.0.2.2:3000 \
///     --dart-define=E2E_TEST_EMAIL=test@example.com \
///     --dart-define=E2E_TEST_PASSWORD=your-password \
///     --dart-define=E2E_RECORD_DATE=2026-06-22
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Matches a time label like "14:30" — two digits, colon, two digits.
  /// Must NOT be "--:--" (the fallback placeholder).
  final timeLabelPattern = RegExp(r'^\d{2}:\d{2}$');

  bool isRealTime(String? visibleText) {
    if (visibleText == null) return false;
    return timeLabelPattern.hasMatch(visibleText.trim());
  }

  testWidgets(
    'full-stack quick-choice lane: water / meal / symptom / note / sleep '
    'display real HH:mm and preserve occurredTime through edit',
    (tester) async {
      final config = FullstackE2eConfig.fromEnvironment();
      final targetDate = parseRecordDate(config.recordDate);

      await prepareFullstackRecordLane(config);
      final container = await pumpFullstackApp(tester, config: config);

      await signInThroughUi(tester, config: config);
      await waitForAuthenticatedSession(tester, container);
      expect(container.read(authSessionProvider).isAuthenticated, isTrue);

      await openRecordTabForDate(tester, container, targetDate: targetDate);

      const kinds = <String>['water', 'meal', 'symptom', 'note', 'sleep'];

      // ── Phase 1: quick-choice save for each kind ───────────────

      final createdTimes = <String, String>{};

      for (final kind in kinds) {
        // 1. Open the quick-action bottom sheet
        final actionKey = Key('record-quick-$kind');
        await tapVisible(tester, find.byKey(actionKey));

        // 2. Wait for the fast-entry sheet to appear, then read the
        //    first chip's label so we can verify it lands in the
        //    timeline entry after save.
        final sheetKey = Key('record-fast-entry-$kind');
        await pumpUntilFound(
          tester,
          find.byKey(sheetKey),
          timeout: const Duration(seconds: 10),
        );

        final chipKey = Key('record-fast-entry-choice-$kind-0');
        await pumpUntilFound(tester, find.byKey(chipKey));
        final chipLabelFinder = find.descendant(
          of: find.byKey(chipKey),
          matching: find.byType(Text),
        );
        await pumpUntilFound(tester, chipLabelFinder);
        final chipLabel = tester.widget<Text>(chipLabelFinder.first).data!;

        // 3. Tap the chip — this calls Navigator.pop() after saving,
        //    NOT a route change. The route stays at /.
        await tapVisible(tester, find.byKey(chipKey));

        // 4. Wait for the bottom sheet to actually disappear.
        await _waitForSheetDismissed(tester, kind);

        // 5. Find the newest timeline entry and verify it contains
        //    the chip label (proves it's the entry we just created,
        //    not a stale one from a prior kind).
        final entry = find.byKey(const Key('record-timeline-entry-index-0'));
        await pumpUntilFound(
          tester,
          entry,
          timeout: const Duration(seconds: 15),
        );
        await tester.ensureVisible(entry.first);
        await settleE2e(tester, frames: 4);

        final chipLabelInEntry = find.descendant(
          of: entry,
          matching: find.textContaining(chipLabel),
        );
        expect(
          tester.any(chipLabelInEntry),
          isTrue,
          reason:
              'timeline entry for $kind should contain chip label "$chipLabel"',
        );

        // 6. Now read the HH:mm from this same entry.
        final timeFinder = find.descendant(
          of: entry,
          matching: find.byWidgetPredicate(
            (widget) => widget is Text && isRealTime(widget.data),
          ),
        );
        expect(
          tester.any(timeFinder),
          isTrue,
          reason: 'timeline entry for $kind should display a real HH:mm time',
        );

        final timeWidget = tester.widget<Text>(timeFinder.first);
        final timeText = timeWidget.data!.trim();
        expect(isRealTime(timeText), isTrue);

        createdTimes[kind] = timeText;
      }

      // Every kind produced a distinguishable entry with a real time.
      expect(createdTimes.length, kinds.length);

      // ── Phase 2: detail page shows same occurredTime ────────────

      // The latest entry (index 0) is sleep, the last kind created.
      final sleepTime = createdTimes['sleep']!;
      await _tapTimelineEntry(tester, 0);

      expect(
        find.textContaining(sleepTime),
        findsWidgets,
        reason: 'detail page should show occurredTime $sleepTime',
      );

      // ── Phase 3: edit preserves occurredTime, no day-crossing ───

      await tapVisible(
        tester,
        find.byKey(const Key('record-detail-edit-action')),
      );

      await pumpUntilFound(tester, find.byKey(const Key('record-time-field')));
      expect(
        find.textContaining(sleepTime),
        findsWidgets,
        reason: 'edit page time field should show $sleepTime',
      );

      // Change the note field only (don't touch time)
      final noteField = find.byKey(const Key('daily-record-note-field'));
      if (tester.any(noteField)) {
        await tester.enterText(noteField, 'edit-preserve-time');
      }

      await tapVisible(
        tester,
        find.byKey(const Key('record-edit-save-action')),
      );

      await pumpUntilFound(
        tester,
        find.byKey(const Key('record-detail-edit-action')),
        timeout: const Duration(seconds: 10),
      );

      expect(
        find.textContaining(sleepTime),
        findsWidgets,
        reason:
            'after edit, detail page should still show occurredTime $sleepTime',
      );

      // Date should NOT have changed (no day-crossing)
      final dateText =
          '${targetDate.year}-'
          '${targetDate.month.toString().padLeft(2, '0')}-'
          '${targetDate.day.toString().padLeft(2, '0')}';
      expect(
        find.textContaining(dateText),
        findsWidgets,
        reason: 'date should still be $dateText after edit',
      );
    },
  );
}

// ── Helpers ───────────────────────────────────────────────────────

/// Poll until the fast-entry bottom sheet for [kind] is gone.
Future<void> _waitForSheetDismissed(
  WidgetTester tester,
  String kind, {
  Duration timeout = const Duration(seconds: 10),
  Duration step = const Duration(milliseconds: 100),
}) async {
  final sheetKey = Key('record-fast-entry-$kind');
  final endTime = tester.binding.clock.fromNowBy(timeout);

  do {
    await tester.pump(step);
    if (!tester.any(find.byKey(sheetKey))) {
      return;
    }
  } while (tester.binding.clock.now().isBefore(endTime));

  throw TestFailure('Timed out waiting for fast-entry sheet $kind to dismiss');
}

Future<void> _tapTimelineEntry(WidgetTester tester, int index) async {
  final entry = find.byKey(Key('record-timeline-entry-index-$index'));
  await pumpUntilFound(tester, entry);
  await tester.ensureVisible(entry.first);
  await settleE2e(tester, frames: 4);
  await tester.tap(entry.first);
  await settleE2e(tester, frames: 6);
}
