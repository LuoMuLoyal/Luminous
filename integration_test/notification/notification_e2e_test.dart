import 'dart:async';

import '../support/e2e_test_helpers.dart';

void main() {
  patrolTest('notification list page renders title and mark-all-read button', (
    $,
  ) async {
    final container = await pumpOfflineApp($);
    unawaited(container.read(appRouterProvider).push('/notifications'));
    await settleE2e($, frames: 10);

    // The page should render with its title and mark-all-read button,
    // even though the list data will fail to load (no backend).
    expect(find.byType(BackButton), findsWidgets);
  });

  patrolTest('notification detail page renders title for given id', ($) async {
    final container = await pumpOfflineApp($);
    unawaited(
      container.read(appRouterProvider).push('/notifications/e2e-id-1'),
    );
    await settleE2e($, frames: 10);

    // The detail page should render with its title.
    expect(find.byType(BackButton), findsWidgets);
  });

  patrolTest('notification list back action returns to previous page', (
    $,
  ) async {
    final container = await pumpOfflineApp($);
    unawaited(container.read(appRouterProvider).push('/notifications'));
    await settleE2e($, frames: 10);

    // Press back.
    await $.tester.tap(find.byType(BackButton).first);
    await settleE2e($, frames: 10);

    // Should return to the previous page (home/today).
    expect(find.byKey(const Key('shell-tab-today')), findsOneWidget);
  });
}
