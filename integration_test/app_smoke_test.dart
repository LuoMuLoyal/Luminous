import 'e2e_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('offline app smoke flow covers main tabs and record create', (
    tester,
  ) async {
    await pumpOfflineApp(tester);

    expect(find.text('今日'), findsOneWidget);
    expect(find.text('今日喝水'), findsOneWidget);

    await openTab(tester, '记录');
    expect(find.text('快速记录'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_rounded).last);
    await tester.pumpAndSettle();
    expect(find.text('尚未登录。'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '去登录'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('快速记录'), findsOneWidget);

    await openTab(tester, '用药');
    expect(find.text('今日服用计划'), findsOneWidget);

    await openTab(tester, '我的');
    expect(find.text('当前未登录'), findsOneWidget);
  });
}
