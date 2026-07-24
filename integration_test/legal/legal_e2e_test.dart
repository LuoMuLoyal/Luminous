import 'package:integration_test/integration_test.dart';
import '../support/e2e_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('legal list renders documents from mock repository', (
    tester,
  ) async {
    final container = await pumpOfflineApp(
      tester,
      legalRepository: E2eLegalRepository(),
    );
    container.read(appRouterProvider).go('/legal');
    await settleE2e(tester, frames: 10);

    // Verify all three mock documents appear.
    expect(find.text('E2E 服务条款'), findsWidgets);
    expect(find.text('E2E 隐私政策'), findsWidgets);
    expect(find.text('E2E 免责声明'), findsWidgets);
  });

  testWidgets('legal list tap navigates to detail page with content', (
    tester,
  ) async {
    final container = await pumpOfflineApp(
      tester,
      legalRepository: E2eLegalRepository(),
    );
    container.read(appRouterProvider).go('/legal');
    await settleE2e(tester, frames: 10);

    // Tap on the first document.
    final termsTile = find.text('E2E 服务条款');
    await pumpUntilFound(tester, termsTile);
    await tester.ensureVisible(termsTile);
    await tester.tap(termsTile);
    await settleE2e(tester, frames: 10);

    // Verify the detail page renders the Markdown content.
    expect(find.text('E2E terms'), findsWidgets);
    expect(find.text('This is a test document.'), findsWidgets);
  });

  testWidgets('legal detail with invalid docType shows error view', (
    tester,
  ) async {
    final container = await pumpOfflineApp(
      tester,
      legalRepository: E2eLegalRepository(),
    );
    container.read(appRouterProvider).go('/legal/invalid-type');
    await settleE2e(tester, frames: 10);

    // The detail page should show a not-found error view with a back action.
    expect(find.byType(BackButton), findsWidgets);
  });

  testWidgets('legal list back action returns to previous page', (
    tester,
  ) async {
    final container = await pumpOfflineApp(
      tester,
      legalRepository: E2eLegalRepository(),
    );

    // Start from home, navigate to legal.
    container.read(appRouterProvider).go('/legal');
    await settleE2e(tester, frames: 10);
    expect(find.text('E2E 服务条款'), findsWidgets);

    // Press back.
    await tester.tap(find.byType(BackButton).first);
    await settleE2e(tester, frames: 10);

    // Should return to the previous page (home/today).
    expect(find.byKey(const Key('shell-tab-today')), findsOneWidget);
  });
}
