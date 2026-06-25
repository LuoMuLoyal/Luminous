import '../support/e2e_test_helpers.dart';
import '../support/fullstack_e2e_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('full-stack medicine search hits Lucent and renders results', (
    tester,
  ) async {
    final config = FullstackE2eConfig.fromEnvironment();

    final container = await pumpFullstackApp(tester, config: config);

    await openTab(tester, '用药');
    expect(find.byKey(const Key('medicine-today-plan')), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search_rounded).last);
    await settleE2e(tester);

    expect(find.text('搜索药品'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '去氧孕烯');
    await tester.pump(const Duration(seconds: 2));

    // The imported 100 CN rows include this oral contraceptive product.
    expect(find.text('去氧孕烯炔雌醇片(先安诺)'), findsOneWidget);

    final authState = container.read(authSessionProvider);
    expect(authState.isAuthenticated, isFalse);
  });
}
