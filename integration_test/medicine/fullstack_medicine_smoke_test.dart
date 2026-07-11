import '../support/e2e_test_helpers.dart';
import '../support/fullstack_e2e_helpers.dart';

void main() {
  patrolTest('full-stack medicine search hits Lucent and renders results', (
    $,
  ) async {
    final config = FullstackE2eConfig.fromEnvironment();

    final container = await pumpFullstackApp($, config: config);

    await openTab($, '用药');
    expect(find.byKey(const Key('medicine-today-plan')), findsOneWidget);

    await $.tester.tap(find.byIcon(Icons.search_rounded).last);
    await settleE2e($);

    expect($('搜索药品').exists, true);
    await $.tester.enterText(find.byType(TextField), '去氧孕烯');
    await $.pump(const Duration(seconds: 2));

    // The imported 100 CN rows include this oral contraceptive product.
    expect($('去氧孕烯炔雌醇片(先安诺)').exists, true);

    final authState = container.read(authSessionProvider);
    expect(authState.isAuthenticated, isFalse);
  });
}
