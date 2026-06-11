import 'e2e_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('offline app smoke flow covers main tabs and record create', (
    tester,
  ) async {
    await pumpOfflineApp(tester);

    expect(find.text('今日'), findsAtLeastNWidgets(1));
    expect(find.byKey(const Key('today-medication-card')), findsOneWidget);

    await openTab(tester, '记录');
    expect(find.text('快速记录'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_rounded).last);
    await settleE2e(tester);
    expect(find.byKey(const Key('auth-required-dialog')), findsOneWidget);
    expect(find.byKey(const Key('auth-required-login-action')), findsOneWidget);

    await tester.tap(find.byKey(const Key('auth-required-cancel-action')));
    await settleE2e(tester);
    expect(find.text('快速记录'), findsOneWidget);

    await openTab(tester, '用药');
    await pumpUntilFound(tester, find.byKey(const Key('medicine-today-plan')));
    expect(find.byKey(const Key('medicine-today-plan')), findsOneWidget);

    await openTab(tester, '我的');
    expect(find.text('当前未登录'), findsOneWidget);
  });
}
