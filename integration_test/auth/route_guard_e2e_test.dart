import 'package:integration_test/integration_test.dart';

import '../support/e2e_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('route guard: signed-out access', () {
    testWidgets('protected account route redirects to login', (tester) async {
      final container = await pumpOfflineApp(tester);

      container.read(appRouterProvider).go('/account');
      await pumpUntilFound(
        tester,
        find.byKey(const Key('auth-login-submit-action')),
      );

      expect(find.text('邮箱'), findsWidgets);
      expect(find.byKey(const Key('auth-login-submit-action')), findsOneWidget);

      // Allow any pending async work (e.g. Dio interceptor callbacks) to
      // settle before the container is disposed in tearDown.
      await settleE2e(tester, frames: 30);
    });

    testWidgets('protected settings/export route redirects to login', (
      tester,
    ) async {
      final container = await pumpOfflineApp(tester);

      container.read(appRouterProvider).go('/settings/export');
      await pumpUntilFound(
        tester,
        find.byKey(const Key('auth-login-submit-action')),
      );

      expect(find.text('邮箱'), findsWidgets);
      expect(find.byKey(const Key('auth-login-submit-action')), findsOneWidget);

      await settleE2e(tester, frames: 30);
    });

    testWidgets('protected record/create route redirects to login', (
      tester,
    ) async {
      final container = await pumpOfflineApp(tester);

      container.read(appRouterProvider).go('/record/create');
      await pumpUntilFound(
        tester,
        find.byKey(const Key('auth-login-submit-action')),
      );

      expect(find.text('邮箱'), findsWidgets);
      expect(find.byKey(const Key('auth-login-submit-action')), findsOneWidget);

      await settleE2e(tester, frames: 30);
    });

    testWidgets('protected notifications route redirects to login', (
      tester,
    ) async {
      final container = await pumpOfflineApp(tester);

      container.read(appRouterProvider).go('/notifications');
      await pumpUntilFound(
        tester,
        find.byKey(const Key('auth-login-submit-action')),
      );

      expect(find.text('邮箱'), findsWidgets);
      expect(find.byKey(const Key('auth-login-submit-action')), findsOneWidget);

      await settleE2e(tester, frames: 30);
    });

    testWidgets('public shell tabs are accessible without authentication', (
      tester,
    ) async {
      await pumpOfflineApp(tester);

      // Today tab should render dashboard, not login.
      await openTab(tester, '今日');
      expect(find.byKey(const Key('today-summary-card')), findsOneWidget);
      // Login page should NOT be visible.
      expect(find.byKey(const Key('auth-login-submit-action')), findsNothing);

      // Record tab should render timeline, not login.
      await openTab(tester, '记录');
      expect(find.byKey(const Key('record-timeline')), findsOneWidget);

      // Medicine tab should render plan, not login.
      await openTab(tester, '用药');
      expect(find.byKey(const Key('medicine-today-plan')), findsOneWidget);

      // Mine tab should show signed-out preview, not login.
      await openTab(tester, '我的');
      await pumpUntilFound(
        tester,
        find.byKey(const Key('mine-account-header')),
        timeout: const Duration(seconds: 10),
      );
      // The preview badge and locked title should be visible.
      expect(find.text('预览'), findsWidgets);
    });

    testWidgets('public settings route is accessible without authentication', (
      tester,
    ) async {
      await pumpOfflineApp(tester);

      await openTab(tester, '我的');
      await tester.tap(find.byKey(const Key('mine-settings-action')));
      await settleE2e(tester);

      // Settings page should render, not login.
      expect(find.text('设置'), findsWidgets);
      expect(find.byKey(const Key('settings-row-theme')), findsOneWidget);
    });

    testWidgets('public legal route is accessible without authentication', (
      tester,
    ) async {
      final container = await pumpOfflineApp(
        tester,
        legalRepository: E2eLegalRepository(),
      );

      container.read(appRouterProvider).go('/legal');
      await settleE2e(tester, frames: 10);

      expect(find.text('E2E 服务条款'), findsWidgets);
    });
  });

  group('route guard: signed-in access', () {
    testWidgets('authenticated user visiting /login redirects to home', (
      tester,
    ) async {
      await pumpOfflineApp(
        tester,
        authSessionOverride: SignedInAuthSessionNotifier.new,
      );

      // Already signed in — navigating to /login should redirect to home.
      await openTab(tester, '今日');
      expect(find.byKey(const Key('today-summary-card')), findsOneWidget);

      // The login page should NOT be visible.
      expect(find.text('邮箱'), findsNothing);
    });

    testWidgets('authenticated user visiting /register redirects to home', (
      tester,
    ) async {
      final container = await pumpOfflineApp(
        tester,
        authSessionOverride: SignedInAuthSessionNotifier.new,
      );

      container.read(appRouterProvider).go('/register');
      await settleE2e(tester, frames: 10);

      // Should be redirected to home, not show the register page.
      expect(find.text('创建账号'), findsNothing);
      expect(find.byKey(const Key('today-summary-card')), findsOneWidget);

      await settleE2e(tester, frames: 30);
    });

    testWidgets(
      'authenticated user visiting /forgot-password redirects to home',
      (tester) async {
        final container = await pumpOfflineApp(
          tester,
          authSessionOverride: SignedInAuthSessionNotifier.new,
        );

        container.read(appRouterProvider).go('/forgot-password');
        await settleE2e(tester, frames: 10);

        // Should be redirected to home, not show the forgot password page.
        expect(find.text('重置密码'), findsNothing);
        expect(find.byKey(const Key('today-summary-card')), findsOneWidget);

        await settleE2e(tester, frames: 30);
      },
    );
  });
}
