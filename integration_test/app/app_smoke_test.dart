// ignore_for_file: avoid_print

import 'package:integration_test/integration_test.dart';
import '../support/e2e_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('app smoke: renders shell with all five tabs', (tester) async {
    await pumpOfflineApp(tester);

    // Verify all five tab keys are visible.
    expect(find.byKey(const Key('shell-tab-today')), findsOneWidget);
    expect(find.byKey(const Key('shell-tab-record')), findsOneWidget);
    expect(find.byKey(const Key('shell-tab-medicine')), findsOneWidget);
    expect(find.byKey(const Key('shell-tab-report')), findsOneWidget);
    expect(find.byKey(const Key('shell-tab-mine')), findsOneWidget);

    // Navigate through tabs.
    await tester.tap(find.byKey(const Key('shell-tab-record')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('shell-tab-medicine')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('shell-tab-report')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('shell-tab-mine')));
    await tester.pumpAndSettle();

    // Return to today.
    await tester.tap(find.byKey(const Key('shell-tab-today')));
    await tester.pumpAndSettle();

    print('Integration test smoke test passed — all tabs navigable.');
  });
}
