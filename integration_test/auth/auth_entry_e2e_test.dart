import '../support/e2e_test_helpers.dart';

void main() {
  patrolTest('auth password login updates global session from app flow', (
    $,
  ) async {
    final remote = E2eAuthRemoteDataSource();
    final container = await pumpOfflineApp($, authRemoteDataSource: remote);

    await openLoginFromSignedOutMine($);

    expect($('邮箱').exists, true);

    await $.tester.enterText(
      find.byType(EditableText).at(0),
      'e2e@example.com',
    );
    await $.tester.enterText(find.byType(EditableText).at(1), 'Password123');
    await $.tester.tap(find.widgetWithText(FilledButton, '登录'));
    await settleE2e($);

    expect(remote.loginEmail, 'e2e@example.com');
    expect(remote.loginPassword, 'Password123');
    expect(remote.loginCode, isNull);
    expect(container.read(authSessionProvider).isAuthenticated, isTrue);
    expect(container.read(authSessionProvider).user?.email, 'e2e@example.com');
  });

  patrolTest('auth register flow submits registration from login entry', (
    $,
  ) async {
    final remote = E2eAuthRemoteDataSource();
    await pumpOfflineApp(
      $,
      authRemoteDataSource: remote,
      medicineWorkspaceRepository: E2eMedicineWorkspaceRepository(),
    );

    await openLoginFromSignedOutMine($);

    final registerLink = find.text('立即注册');
    await $.tester.scrollUntilVisible(
      registerLink,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await $.tester.tap(registerLink);
    await settleE2e($);

    expect($('创建账号').exists, true);

    final inputs = find.byType(EditableText);
    await $.tester.enterText(inputs.at(0), 'register-e2e@example.com');
    await $.tester.enterText(inputs.at(1), '123456');
    await $.tester.enterText(inputs.at(2), 'Password123');
    await $.tester.enterText(inputs.at(3), 'Password123');
    await $.tester.enterText(inputs.at(4), 'Register E2E');
    await $.tester.tap(find.widgetWithText(FilledButton, '创建账号'));
    await $.pumpAndSettle();

    expect(remote.registerEmail, 'register-e2e@example.com');
    expect(remote.registerCode, '123456');
    expect(remote.registerPassword, 'Password123');
    expect(remote.registerNickname, 'Register E2E');
    expect($('邮箱').exists, true);
  });

  patrolTest('auth register flow sends verification code from login entry', (
    $,
  ) async {
    final remote = E2eAuthRemoteDataSource();
    await pumpOfflineApp(
      $,
      authRemoteDataSource: remote,
      medicineWorkspaceRepository: E2eMedicineWorkspaceRepository(),
    );

    await openLoginFromSignedOutMine($);

    final registerLink = find.text('立即注册');
    await $.tester.scrollUntilVisible(
      registerLink,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await $.tester.tap(registerLink);
    await settleE2e($);

    final inputs = find.byType(EditableText);
    await $.tester.enterText(inputs.at(0), 'register-code-e2e@example.com');
    await $.tester.tap(find.text('发送验证码'));
    await $.pump();

    expect(remote.sentCodeEmail, 'register-code-e2e@example.com');
    expect(remote.sentCodeScene, AuthVerificationScene.register);
  });

  patrolTest('auth forgot password flow submits reset from login entry', (
    $,
  ) async {
    final remote = E2eAuthRemoteDataSource();
    await pumpOfflineApp(
      $,
      authRemoteDataSource: remote,
      medicineWorkspaceRepository: E2eMedicineWorkspaceRepository(),
    );

    await openLoginFromSignedOutMine($);

    final forgotLink = find.text('忘记密码？');
    await $.tester.scrollUntilVisible(
      forgotLink,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await $.tester.tap(forgotLink);
    await settleE2e($);

    expect($('重置密码').exists, true);

    final inputs = find.byType(EditableText);
    await $.tester.enterText(inputs.at(0), 'reset-e2e@example.com');
    await $.tester.enterText(inputs.at(1), '654321');
    await $.tester.enterText(inputs.at(2), 'Password123');
    await $.tester.enterText(inputs.at(3), 'Password123');
    await $.tester.tap(find.widgetWithText(FilledButton, '重置密码'));
    await settleE2e($);

    expect(remote.resetPasswordEmail, 'reset-e2e@example.com');
    expect(remote.resetPasswordCode, '654321');
    expect(remote.resetPasswordValue, 'Password123');
  });

  patrolTest('auth forgot password flow sends reset verification code', (
    $,
  ) async {
    final remote = E2eAuthRemoteDataSource();
    await pumpOfflineApp(
      $,
      authRemoteDataSource: remote,
      medicineWorkspaceRepository: E2eMedicineWorkspaceRepository(),
    );

    await openLoginFromSignedOutMine($);

    final forgotLink = find.text('忘记密码？');
    await $.tester.scrollUntilVisible(
      forgotLink,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await $.tester.tap(forgotLink);
    await settleE2e($);

    final inputs = find.byType(EditableText);
    await $.tester.enterText(inputs.at(0), 'reset-code-e2e@example.com');
    await $.tester.tap(find.text('发送验证码'));
    await $.pump();

    expect(remote.forgotPasswordEmail, 'reset-code-e2e@example.com');
    expect(remote.sentCodeEmail, isNull);
    expect(remote.sentCodeScene, isNull);
  });
}
