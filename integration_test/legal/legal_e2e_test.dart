import '../support/e2e_test_helpers.dart';

void main() {
  patrolTest('legal list renders documents from mock repository', ($) async {
    final container = await pumpOfflineApp(
      $,
      legalRepository: E2eLegalRepository(),
    );
    container.read(appRouterProvider).go('/legal');
    await settleE2e($, frames: 10);

    // Verify all three mock documents appear.
    expect($('E2E 服务条款').exists, true);
    expect($('E2E 隐私政策').exists, true);
    expect($('E2E 免责声明').exists, true);
  });

  patrolTest('legal list tap navigates to detail page with content', ($) async {
    final container = await pumpOfflineApp(
      $,
      legalRepository: E2eLegalRepository(),
    );
    container.read(appRouterProvider).go('/legal');
    await settleE2e($, frames: 10);

    // Tap on the first document.
    final termsTile = find.text('E2E 服务条款');
    await pumpUntilFound($, termsTile);
    await $.tester.ensureVisible(termsTile);
    await $.tester.tap(termsTile);
    await settleE2e($, frames: 10);

    // Verify the detail page renders the Markdown content.
    expect($('E2E terms').exists, true);
    expect($('This is a test document.').exists, true);
  });

  patrolTest('legal detail with invalid docType shows error view', ($) async {
    final container = await pumpOfflineApp(
      $,
      legalRepository: E2eLegalRepository(),
    );
    container.read(appRouterProvider).go('/legal/invalid-type');
    await settleE2e($, frames: 10);

    // The detail page should show a not-found error view with a back action.
    expect(find.byType(BackButton), findsWidgets);
  });

  patrolTest('legal list back action returns to previous page', ($) async {
    final container = await pumpOfflineApp(
      $,
      legalRepository: E2eLegalRepository(),
    );

    // Start from home, navigate to legal.
    container.read(appRouterProvider).go('/legal');
    await settleE2e($, frames: 10);
    expect($('E2E 服务条款').exists, true);

    // Press back.
    await $.tester.tap(find.byType(BackButton).first);
    await settleE2e($, frames: 10);

    // Should return to the previous page (home/today).
    expect(find.byKey(const Key('shell-tab-today')), findsOneWidget);
  });
}
