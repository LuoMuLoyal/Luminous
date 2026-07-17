import '../support/e2e_test_helpers.dart';

void main() {
  patrolTest('account settings profile save updates global session', ($) async {
    final remote = E2eLucentAuthRepository();
    final container = await pumpOfflineApp(
      $,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      authRepository: remote,
    );

    await openTab($, '我的');
    await $.tester.tap(find.byKey(const Key('mine-account-manage-link')));
    await settleE2e($);

    expect($('账号与安全').exists, true);
    expect($('资料信息').exists, true);

    await $.tester.enterText(find.byType(EditableText).at(0), 'E2E Nick');
    await $.tester.enterText(
      find.byType(EditableText).at(1),
      'https://example.com/e2e-avatar.png',
    );

    final saveButton = find.widgetWithText(FilledButton, '保存资料');
    await $.tester.ensureVisible(saveButton);
    await $.tester.tap(saveButton);
    await settleE2e($);

    expect(remote.updateProfileNickname, 'E2E Nick');
    expect(remote.updateProfileAvatar, 'https://example.com/e2e-avatar.png');
    expect(container.read(authSessionProvider).user?.nickname, 'E2E Nick');
    expect(
      container.read(authSessionProvider).user?.avatar,
      'https://example.com/e2e-avatar.png',
    );

    await $.tester.drag(find.byType(Scrollable).first, const Offset(0, 900));
    await settleE2e($);
    await $.tester.tap(find.byType(BackButton).first);
    await settleE2e($);
    final archiveSection = find.byKey(const Key('mine-archive-section'));
    await pumpUntilFound($, archiveSection);
    expect(archiveSection, findsOneWidget);
  });

  patrolTest('account change email flow updates global session', ($) async {
    final remote = E2eLucentAuthRepository();
    final container = await pumpOfflineApp(
      $,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      authRepository: remote,
    );

    await openTab($, '我的');
    await $.tester.tap(find.byKey(const Key('mine-account-manage-link')));
    await settleE2e($);

    final changeEmailButton = find.widgetWithText(FilledButton, '更换邮箱');
    await $.tester.scrollUntilVisible(
      changeEmailButton,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await $.tester.tap(changeEmailButton);
    await settleE2e($);

    expect($('更换邮箱').exists, true);

    await $.tester.enterText(
      find.byType(EditableText).at(0),
      'next-e2e@example.com',
    );
    await $.tester.enterText(find.byType(EditableText).at(1), '246810');
    await $.tester.tap(find.widgetWithText(FilledButton, '更新邮箱'));
    await settleE2e($);

    expect(remote.changeEmailNewEmail, 'next-e2e@example.com');
    expect(remote.changeEmailCode, '246810');
    expect(
      container.read(authSessionProvider).user?.email,
      'next-e2e@example.com',
    );

    await $.tester.tap(find.byType(BackButton).first);
    await settleE2e($);
    expect($('账号与安全').exists, true);
  });

  patrolTest('account change email flow sends verification code', ($) async {
    final remote = E2eLucentAuthRepository();
    await pumpOfflineApp(
      $,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      authRepository: remote,
    );

    await openTab($, '我的');
    await $.tester.tap(find.byKey(const Key('mine-account-manage-link')));
    await settleE2e($);

    final changeEmailButton = find.widgetWithText(FilledButton, '更换邮箱');
    await $.tester.scrollUntilVisible(
      changeEmailButton,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await $.tester.tap(changeEmailButton);
    await settleE2e($);

    await $.tester.enterText(
      find.byType(EditableText).at(0),
      'change-code-e2e@example.com',
    );
    await $.tester.tap(find.text('发送验证码'));
    await $.pump();

    expect(remote.sentCodeEmail, 'change-code-e2e@example.com');
    expect(remote.sentCodeScene, AuthVerificationScene.changeEmail);
  });

  patrolTest('account change password clears session and routes to login', (
    $,
  ) async {
    final remote = E2eLucentAuthRepository();
    final container = await pumpOfflineApp(
      $,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      authRepository: remote,
    );

    await openTab($, '我的');
    await $.tester.tap(find.byKey(const Key('mine-account-manage-link')));
    await settleE2e($);

    final oldPasswordField = find.byType(EditableText).at(3);
    await $.tester.scrollUntilVisible(
      oldPasswordField,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await $.tester.enterText(oldPasswordField, 'old-password-e2e');
    await $.tester.enterText(
      find.byType(EditableText).at(4),
      'new-password-e2e',
    );

    final changePasswordButton = find.widgetWithText(FilledButton, '更新密码');
    await $.tester.ensureVisible(changePasswordButton);
    await $.tester.tap(changePasswordButton);
    await settleE2e($);

    expect(remote.changePasswordOldPassword, 'old-password-e2e');
    expect(remote.changePasswordNewPassword, 'new-password-e2e');
    expect(container.read(authSessionProvider).isAuthenticated, isFalse);
    expect($('邮箱').exists, true);
    expect(find.widgetWithText(FilledButton, '登录'), findsOneWidget);
  });

  patrolTest('account delete clears session and routes to login', ($) async {
    final remote = E2eLucentAuthRepository();
    final container = await pumpOfflineApp(
      $,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      authRepository: remote,
    );

    await openTab($, '我的');
    await $.tester.tap(find.byKey(const Key('mine-account-manage-link')));
    await settleE2e($);

    final deletePasswordField = find.byType(EditableText).at(5);
    await $.tester.scrollUntilVisible(
      deletePasswordField,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await $.tester.enterText(deletePasswordField, 'delete-password-e2e');

    final deleteButton = find.widgetWithText(FilledButton, '注销账号');
    await $.tester.ensureVisible(deleteButton);
    await $.tester.tap(deleteButton);
    await settleE2e($);

    expect(remote.deleteAccountPassword, 'delete-password-e2e');
    expect(container.read(authSessionProvider).isAuthenticated, isFalse);
    expect($('邮箱').exists, true);
    expect(find.widgetWithText(FilledButton, '登录'), findsOneWidget);
  });

  patrolTest('account unlink identity updates global session', ($) async {
    final remote = E2eLucentAuthRepository();
    final container = await pumpOfflineApp(
      $,
      authSessionOverride: SignedInWithWechatIdentityAuthSessionNotifier.new,
      authRepository: remote,
    );

    await openTab($, '我的');
    await $.tester.tap(find.byKey(const Key('mine-account-manage-link')));
    await settleE2e($);

    final unlinkButton = find.widgetWithText(TextButton, '解绑');
    await $.tester.scrollUntilVisible(
      unlinkButton,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await $.tester.tap(unlinkButton);
    await settleE2e($);

    final confirmButton = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(FilledButton, '解绑'),
    );
    await $.tester.tap(confirmButton);
    await settleE2e($);

    expect(remote.unlinkIdentityId, 'e2e-identity-1');
    expect(container.read(authSessionProvider).user?.linkedIdentities, isEmpty);
    expect($('尚未绑定第三方身份。').exists, true);
  });
}
