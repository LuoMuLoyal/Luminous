// ignore_for_file: avoid_print

import '../support/e2e_test_helpers.dart';

void main() {
  patrolTest('app smoke: renders shell with all five tabs', ($) async {
    await pumpOfflineApp($);

    // Verify all five tab keys are visible.
    expect($(const Key('shell-tab-today')).exists, true);
    expect($(const Key('shell-tab-record')).exists, true);
    expect($(const Key('shell-tab-medicine')).exists, true);
    expect($(const Key('shell-tab-report')).exists, true);
    expect($(const Key('shell-tab-mine')).exists, true);

    // Navigate through tabs.
    await $(const Key('shell-tab-record')).tap();
    await $.pumpAndSettle();

    await $(const Key('shell-tab-medicine')).tap();
    await $.pumpAndSettle();

    await $(const Key('shell-tab-report')).tap();
    await $.pumpAndSettle();

    await $(const Key('shell-tab-mine')).tap();
    await $.pumpAndSettle();

    // Return to today.
    await $(const Key('shell-tab-today')).tap();
    await $.pumpAndSettle();

    print('Patrol smoke test passed — all tabs navigable.');
  });
}
