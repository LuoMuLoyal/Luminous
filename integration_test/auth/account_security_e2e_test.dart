import 'package:integration_test/integration_test.dart';
import '../support/e2e_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('account settings profile save updates global session', (
    tester,
  ) async {
    final remote = E2eLucentAuthRepository();
    final container = await pumpOfflineApp(
      tester,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      authRepository: remote,
    );

    await openTab(tester, '我的');
    await tester.tap(find.byKey(const Key('mine-account-manage-link')));
    await settleE2e(tester);

    expect(find.text('账号与安全'), findsWidgets);
    expect(find.text('资料信息'), findsWidgets);

    await tester.enterText(find.byType(EditableText).at(0), 'E2E Nick');
    await tester.enterText(
      find.byType(EditableText).at(1),
      'https://example.com/e2e-avatar.png',
    );

    final saveButton = find.widgetWithText(FButton, '保存资料');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await settleE2e(tester);

    expect(remote.updateProfileNickname, 'E2E Nick');
    expect(remote.updateProfileAvatar, 'https://example.com/e2e-avatar.png');
    expect(container.read(authSessionProvider).user?.nickname, 'E2E Nick');
    expect(
      container.read(authSessionProvider).user?.avatar,
      'https://example.com/e2e-avatar.png',
    );

    await tester.drag(find.byType(Scrollable).first, const Offset(0, 900));
    await settleE2e(tester);
    await tester.tap(find.byType(BackButton).first);
    await settleE2e(tester);
    final archiveSection = find.byKey(const Key('mine-archive-section'));
    await pumpUntilFound(tester, archiveSection);
    expect(archiveSection, findsOneWidget);
  });

  testWidgets('account change email flow updates global session', (
    tester,
  ) async {
    final remote = E2eLucentAuthRepository();
    final container = await pumpOfflineApp(
      tester,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      authRepository: remote,
    );

    await openTab(tester, '我的');
    await tester.tap(find.byKey(const Key('mine-account-manage-link')));
    await settleE2e(tester);

    final changeEmailButton = find.widgetWithText(FButton, '更换邮箱');
    await tester.scrollUntilVisible(
      changeEmailButton,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(changeEmailButton);
    await settleE2e(tester);

    expect(find.text('更换邮箱'), findsWidgets);

    await tester.enterText(
      find.byType(EditableText).at(0),
      'next-e2e@example.com',
    );
    await tester.enterText(find.byType(EditableText).at(1), '246810');
    await tester.tap(find.widgetWithText(FButton, '更新邮箱'));
    await settleE2e(tester);

    expect(remote.changeEmailNewEmail, 'next-e2e@example.com');
    expect(remote.changeEmailCode, '246810');
    expect(
      container.read(authSessionProvider).user?.email,
      'next-e2e@example.com',
    );

    await tester.tap(find.byType(BackButton).first);
    await settleE2e(tester);
    expect(find.text('账号与安全'), findsWidgets);
  });

  testWidgets('account change email flow sends verification code', (
    tester,
  ) async {
    final remote = E2eLucentAuthRepository();
    await pumpOfflineApp(
      tester,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      authRepository: remote,
    );

    await openTab(tester, '我的');
    await tester.tap(find.byKey(const Key('mine-account-manage-link')));
    await settleE2e(tester);

    final changeEmailButton = find.widgetWithText(FButton, '更换邮箱');
    await tester.scrollUntilVisible(
      changeEmailButton,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(changeEmailButton);
    await settleE2e(tester);

    await tester.enterText(
      find.byType(EditableText).at(0),
      'change-code-e2e@example.com',
    );
    await tester.tap(find.text('发送验证码'));
    await tester.pump();

    expect(remote.sentCodeEmail, 'change-code-e2e@example.com');
    expect(remote.sentCodeScene, AuthVerificationScene.changeEmail);
  });

  testWidgets('account change password clears session and routes to login', (
    tester,
  ) async {
    final remote = E2eLucentAuthRepository();
    final container = await pumpOfflineApp(
      tester,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      authRepository: remote,
    );

    await openTab(tester, '我的');
    await tester.tap(find.byKey(const Key('mine-account-manage-link')));
    await settleE2e(tester);

    final oldPasswordField = find.byType(EditableText).at(3);
    await tester.scrollUntilVisible(
      oldPasswordField,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(oldPasswordField, 'old-password-e2e');
    await tester.enterText(find.byType(EditableText).at(4), 'new-password-e2e');

    final changePasswordButton = find.widgetWithText(FButton, '更新密码');
    await tester.ensureVisible(changePasswordButton);
    await tester.tap(changePasswordButton);
    await settleE2e(tester);

    expect(remote.changePasswordOldPassword, 'old-password-e2e');
    expect(remote.changePasswordNewPassword, 'new-password-e2e');
    expect(container.read(authSessionProvider).isAuthenticated, isFalse);
    expect(find.text('邮箱'), findsWidgets);
    expect(find.widgetWithText(FButton, '登录'), findsOneWidget);
  });

  testWidgets('account delete clears session and routes to login', (
    tester,
  ) async {
    final remote = E2eLucentAuthRepository();
    final container = await pumpOfflineApp(
      tester,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      authRepository: remote,
    );

    await openTab(tester, '我的');
    await tester.tap(find.byKey(const Key('mine-account-manage-link')));
    await settleE2e(tester);

    final deletePasswordField = find.byType(EditableText).at(5);
    await tester.scrollUntilVisible(
      deletePasswordField,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(deletePasswordField, 'delete-password-e2e');

    final deleteButton = find.widgetWithText(FButton, '注销账号');
    await tester.ensureVisible(deleteButton);
    await tester.tap(deleteButton);
    await settleE2e(tester);

    expect(remote.deleteAccountPassword, 'delete-password-e2e');
    expect(container.read(authSessionProvider).isAuthenticated, isFalse);
    expect(find.text('邮箱'), findsWidgets);
    expect(find.widgetWithText(FButton, '登录'), findsOneWidget);
  });

  testWidgets('account unlink identity updates global session', (tester) async {
    final remote = E2eLucentAuthRepository();
    final container = await pumpOfflineApp(
      tester,
      authSessionOverride: SignedInWithWechatIdentityAuthSessionNotifier.new,
      authRepository: remote,
    );

    await openTab(tester, '我的');
    await tester.tap(find.byKey(const Key('mine-account-manage-link')));
    await settleE2e(tester);

    final unlinkButton = find.widgetWithText(FButton, '解绑');
    await tester.scrollUntilVisible(
      unlinkButton,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(unlinkButton);
    await settleE2e(tester);

    // The confirmation dialog uses showAppDialog (FDialog), not AlertDialog.
    final confirmButton = find.widgetWithText(FButton, '解绑').at(1);
    await tester.tap(confirmButton);
    await settleE2e(tester);

    expect(remote.unlinkIdentityId, 'e2e-identity-1');
    expect(container.read(authSessionProvider).user?.linkedIdentities, isEmpty);
    expect(find.text('尚未绑定第三方身份。'), findsWidgets);
  });
}
