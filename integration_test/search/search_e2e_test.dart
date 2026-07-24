import 'package:integration_test/integration_test.dart';
import '../support/e2e_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('search page opens from medicine tab and renders input', (
    tester,
  ) async {
    await pumpOfflineApp(tester);

    await openTab(tester, '用药');

    // Tap the search icon to open the search page.
    await tester.tap(find.byIcon(FLucideIcons.search).last);
    await settleE2e(tester);

    // The search page should render with a text input field.
    expect(find.text('搜索药品'), findsWidgets);
    expect(find.byType(TextField), findsWidgets);
  });

  testWidgets('search query returns results from mock data', (tester) async {
    await pumpOfflineApp(tester);

    await openTab(tester, '用药');
    await tester.tap(find.byIcon(FLucideIcons.search).last);
    await settleE2e(tester);

    await tester.enterText(find.byType(TextField), '布洛芬');
    await tester.pump(const Duration(seconds: 1));

    // Results should appear from the mock search repository.
    expect(find.text('布洛芬片'), findsWidgets);
  });

  testWidgets('search back action returns to medicine tab', (tester) async {
    await pumpOfflineApp(tester);

    await openTab(tester, '用药');
    await tester.tap(find.byIcon(FLucideIcons.search).last);
    await settleE2e(tester);

    // Press back.
    await tester.tap(find.byType(BackButton).first);
    await settleE2e(tester);

    // Should return to the medicine tab.
    expect(find.byKey(const Key('medicine-today-plan')), findsOneWidget);
  });

  testWidgets('search signed-out add to medicine box shows auth dialog', (
    tester,
  ) async {
    await pumpOfflineApp(tester);

    await openTab(tester, '用药');
    await tester.tap(find.byIcon(FLucideIcons.search).last);
    await settleE2e(tester);

    await tester.enterText(find.byType(TextField), '布洛芬');
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('布洛芬片'), findsWidgets);

    // Tap "加入药箱" button — signed-out user should see auth dialog.
    final addButton = find.text('加入药箱').first;
    await tester.scrollUntilVisible(
      addButton,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(addButton);
    await settleE2e(tester);

    // Auth required dialog should appear.
    expect(find.byKey(const Key('auth-required-dialog')), findsOneWidget);
  });
}
