import 'e2e_test_helpers.dart';
import 'fullstack_e2e_helpers.dart';

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
    expect(find.byKey(const Key('daily-record-title-field')), findsOneWidget);

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

    final createdEntry = find.text(createdTitle);
    await tester.scrollUntilVisible(createdEntry, 240);
    expect(createdEntry, findsOneWidget);

    await tapVisible(tester, createdEntry);
    await pumpUntilFound(
      tester,
      find.byKey(const Key('record-detail-edit-action')),
    );
    expect(find.text(createdTitle), findsOneWidget);
    expect(find.text(createdNote), findsOneWidget);

    await tapVisible(
      tester,
      find.byKey(const Key('record-detail-edit-action')),
    );
    expect(find.byKey(const Key('daily-record-note-field')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('daily-record-note-field')),
      updatedNote,
    );
    await tapVisible(tester, find.byKey(const Key('record-edit-save-action')));

    await pumpUntilFound(tester, find.text(updatedNote));
    expect(find.text(updatedNote), findsOneWidget);

    await tapVisible(
      tester,
      find.byKey(const Key('record-detail-delete-action')),
    );
    await tapVisible(
      tester,
      find.byKey(const Key('record-delete-confirm-action')),
    );

    await openRecordTabForDate(tester, container, targetDate: targetDate);
    expect(find.text(createdTitle), findsNothing);
  });
}
