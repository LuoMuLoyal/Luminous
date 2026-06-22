import '../support/e2e_test_helpers.dart';
import '../support/fullstack_e2e_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('full-stack record lane creates updates and deletes one note', (
    tester,
  ) async {
    final config = FullstackE2eConfig.fromEnvironment();
    final targetDate = parseRecordDate(config.recordDate);
    const createdTitle = 'FS Note 2026';
    const createdNote = 'created from fullstack lane';
    const updatedNote = 'updated from fullstack lane';

    await prepareFullstackRecordLane(config);
    final container = await pumpFullstackApp(tester, config: config);

    await signInThroughUi(tester, config: config);
    await waitForAuthenticatedSession(tester, container);
    expect(container.read(authSessionProvider).isAuthenticated, isTrue);

    await openRecordTabForDate(tester, container, targetDate: targetDate);

    await tapVisible(tester, find.byKey(const Key('record-quick-note')));
    await pumpUntilFound(
      tester,
      find.byKey(const Key('record-fast-entry-note')),
      timeout: const Duration(seconds: 10),
    );
    await tapVisible(
      tester,
      find.byKey(const Key('record-fast-entry-more-action')),
    );
    await pumpUntilFound(
      tester,
      find.byKey(const Key('daily-record-title-field')),
      timeout: const Duration(seconds: 10),
    );

    await tester.enterText(
      find.byKey(const Key('daily-record-title-field')),
      createdTitle,
    );
    await tester.enterText(
      find.byKey(const Key('daily-record-note-field')),
      createdNote,
    );
    await tapVisible(
      tester,
      find.byKey(const Key('record-create-save-action')),
    );

    await waitForRoute(
      tester,
      predicate: (uri) => uri.path == '/',
      description: 'return to record timeline after create',
    );
    final createdEntry = find.byKey(const Key('record-timeline-entry-index-0'));
    await pumpUntilFound(
      tester,
      createdEntry,
      timeout: const Duration(seconds: 15),
    );
    await tester.ensureVisible(createdEntry.first);
    await settleE2e(tester, frames: 6);
    expect(createdEntry, findsOneWidget);

    await tapVisible(tester, createdEntry.first);
    await pumpUntilFound(
      tester,
      find.byKey(const Key('record-detail-edit-action')),
    );
    expect(find.text(createdTitle), findsWidgets);
    expect(find.text(createdNote), findsWidgets);

    await tapVisible(
      tester,
      find.byKey(const Key('record-detail-edit-action')),
    );
    expect(find.byKey(const Key('daily-record-note-field')), findsOneWidget);
    expect(find.byKey(const Key('record-time-field')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('daily-record-note-field')),
      updatedNote,
    );
    await tapVisible(tester, find.byKey(const Key('record-edit-save-action')));

    await pumpUntilFound(tester, find.text(updatedNote));
    expect(find.text(updatedNote), findsWidgets);

    await tapVisible(
      tester,
      find.byKey(const Key('record-detail-delete-action')),
    );
    await tapVisible(
      tester,
      find.byKey(const Key('record-delete-confirm-action')),
    );

    await openRecordTabForDate(tester, container, targetDate: targetDate);
    expect(find.byKey(const Key('record-timeline-entry-index-0')), findsNothing);
  });
}
