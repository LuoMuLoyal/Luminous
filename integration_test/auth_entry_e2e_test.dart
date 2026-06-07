import 'e2e_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('auth password login updates global session from app flow', (
    tester,
  ) async {
    final remote = E2eAuthRemoteDataSource();
    final container = await pumpOfflineApp(
      tester,
      authRemoteDataSource: remote,
      medicineWorkspaceRepository: E2eMedicineWorkspaceRepository(),
    );

    await openTab(tester, '用药');

    final medicine = find.text('E2E medicine');
    await tester.scrollUntilVisible(medicine, 240);
    await tester.tap(find.text('已服用'));
    await tester.pumpAndSettle();

    expect(find.text('邮箱'), findsOneWidget);

    await tester.enterText(find.byType(EditableText).at(0), 'e2e@example.com');
    await tester.enterText(find.byType(EditableText).at(1), 'Password123');
    await tester.tap(find.widgetWithText(FilledButton, '登录'));
    await tester.pumpAndSettle();

    expect(remote.loginEmail, 'e2e@example.com');
    expect(remote.loginPassword, 'Password123');
    expect(remote.loginCode, isNull);
    expect(container.read(authSessionProvider).isAuthenticated, isTrue);
    expect(container.read(authSessionProvider).user?.email, 'e2e@example.com');
  });

  testWidgets('auth register flow updates global session from login entry', (
    tester,
  ) async {
    final remote = E2eAuthRemoteDataSource();
    final container = await pumpOfflineApp(
      tester,
      authRemoteDataSource: remote,
      medicineWorkspaceRepository: E2eMedicineWorkspaceRepository(),
    );

    await openLoginFromMedicineDose(tester);

    final registerLink = find.text('立即注册');
    await tester.scrollUntilVisible(
      registerLink,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(registerLink);
    await tester.pumpAndSettle();

    expect(find.text('创建账号'), findsAtLeastNWidgets(1));

    final inputs = find.byType(EditableText);
    await tester.enterText(inputs.at(0), 'register-e2e@example.com');
    await tester.enterText(inputs.at(1), '123456');
    await tester.enterText(inputs.at(2), 'Password123');
    await tester.enterText(inputs.at(3), 'Register E2E');
    await tester.tap(find.widgetWithText(FilledButton, '创建账号'));
    await tester.pumpAndSettle();

    expect(remote.registerEmail, 'register-e2e@example.com');
    expect(remote.registerCode, '123456');
    expect(remote.registerPassword, 'Password123');
    expect(remote.registerNickname, 'Register E2E');
    expect(container.read(authSessionProvider).isAuthenticated, isTrue);
    expect(
      container.read(authSessionProvider).user?.email,
      'register-e2e@example.com',
    );
  });

  testWidgets('auth register flow sends verification code from login entry', (
    tester,
  ) async {
    final remote = E2eAuthRemoteDataSource();
    await pumpOfflineApp(
      tester,
      authRemoteDataSource: remote,
      medicineWorkspaceRepository: E2eMedicineWorkspaceRepository(),
    );

    await openLoginFromMedicineDose(tester);

    final registerLink = find.text('立即注册');
    await tester.scrollUntilVisible(
      registerLink,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(registerLink);
    await tester.pumpAndSettle();

    final inputs = find.byType(EditableText);
    await tester.enterText(inputs.at(0), 'register-code-e2e@example.com');
    await tester.tap(find.text('发送验证码'));
    await tester.pump();

    expect(remote.sentCodeEmail, 'register-code-e2e@example.com');
    expect(remote.sentCodeScene, AuthVerificationScene.register);
  });

  testWidgets('auth forgot password flow submits reset from login entry', (
    tester,
  ) async {
    final remote = E2eAuthRemoteDataSource();
    await pumpOfflineApp(
      tester,
      authRemoteDataSource: remote,
      medicineWorkspaceRepository: E2eMedicineWorkspaceRepository(),
    );

    await openLoginFromMedicineDose(tester);

    final forgotLink = find.text('忘记密码？');
    await tester.scrollUntilVisible(
      forgotLink,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(forgotLink);
    await tester.pumpAndSettle();

    expect(find.text('重置密码'), findsAtLeastNWidgets(1));

    final inputs = find.byType(EditableText);
    await tester.enterText(inputs.at(0), 'reset-e2e@example.com');
    await tester.enterText(inputs.at(1), '654321');
    await tester.enterText(inputs.at(2), 'Password123');
    await tester.enterText(inputs.at(3), 'Password123');
    await tester.tap(find.widgetWithText(FilledButton, '重置密码'));
    await tester.pumpAndSettle();

    expect(remote.resetPasswordEmail, 'reset-e2e@example.com');
    expect(remote.resetPasswordCode, '654321');
    expect(remote.resetPasswordValue, 'Password123');
  });

  testWidgets('auth forgot password flow sends reset verification code', (
    tester,
  ) async {
    final remote = E2eAuthRemoteDataSource();
    await pumpOfflineApp(
      tester,
      authRemoteDataSource: remote,
      medicineWorkspaceRepository: E2eMedicineWorkspaceRepository(),
    );

    await openLoginFromMedicineDose(tester);

    final forgotLink = find.text('忘记密码？');
    await tester.scrollUntilVisible(
      forgotLink,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(forgotLink);
    await tester.pumpAndSettle();

    final inputs = find.byType(EditableText);
    await tester.enterText(inputs.at(0), 'reset-code-e2e@example.com');
    await tester.tap(find.text('发送验证码'));
    await tester.pump();

    expect(remote.forgotPasswordEmail, 'reset-code-e2e@example.com');
    expect(remote.sentCodeEmail, isNull);
    expect(remote.sentCodeScene, isNull);
  });
}
