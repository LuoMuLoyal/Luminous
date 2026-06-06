import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lucent_openapi/lucent_openapi.dart' show CooldownMessageDto;
import 'package:luminous/app/app.dart';
import 'package:luminous/app/router.dart' show router;
import 'package:luminous/core/network/lucent_dio_client.dart';
import 'package:luminous/core/network/lucent_session_store.dart';
import 'package:luminous/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:luminous/features/auth/data/providers/auth_data_providers.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_write_inputs.dart';
import 'package:luminous/features/health_context/domain/repositories/health_context_repository.dart';
import 'package:luminous/features/medicine/data/repositories/mock_medicine_workspace_repository.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_workspace.dart';
import 'package:luminous/features/medicine/domain/repositories/medicine_workspace_repository.dart';
import 'package:luminous/features/mine/data/repositories/mock_mine_repository.dart'
    show MockMineRepository;
import 'package:luminous/features/mine/presentation/providers/mine_dashboard_provider.dart'
    show mineRepositoryProvider;
import 'package:luminous/features/more/data/repositories/mock_more_repository.dart';
import 'package:luminous/features/record/data/providers/daily_record_providers.dart';
import 'package:luminous/features/record/data/repositories/mock_record_repository.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/features/record/domain/entities/daily_record_inputs.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/domain/repositories/daily_record_repository.dart';
import 'package:luminous/features/record/domain/repositories/record_repository.dart';
import 'package:luminous/features/search/data/repositories/lucent_repository.dart'
    show medicineSearchRepositoryProvider;
import 'package:luminous/features/search/data/repositories/mock/mock_repository.dart';
import 'package:luminous/features/settings/data/providers/notification_permission_providers.dart';
import 'package:luminous/features/settings/data/services/notification_permission_service.dart';
import 'package:luminous/features/today/data/repositories/mock_today_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('offline app smoke flow covers main tabs and record create', (
    tester,
  ) async {
    await _pumpOfflineApp(tester);

    expect(find.text('今日'), findsOneWidget);
    expect(find.text('今日喝水'), findsOneWidget);

    await _openTab(tester, '记录');
    expect(find.text('快速记录'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_rounded).last);
    await tester.pumpAndSettle();
    expect(find.text('尚未登录。'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '去登录'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('快速记录'), findsOneWidget);

    await _openTab(tester, '用药');
    expect(find.text('今日服用计划'), findsOneWidget);

    await _openTab(tester, '我的');
    expect(find.text('当前未登录'), findsOneWidget);

    await _openTab(tester, '更多');
    expect(find.byKey(const Key('more-emergency-section')), findsOneWidget);
  });

  testWidgets('settings theme flow uses system back button and persists mode', (
    tester,
  ) async {
    await _pumpOfflineApp(tester);

    await _openTab(tester, '我的');
    await tester.tap(find.byKey(const Key('mine-settings-action')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('settings-row-theme')), findsOneWidget);

    await tester.tap(find.byKey(const Key('settings-row-theme')));
    await tester.pumpAndSettle();

    expect(find.text('主题模式'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);

    await tester.tap(find.byKey(const Key('theme-row-dark')));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('theme.mode'), 'dark');

    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('settings-row-theme')), findsOneWidget);
    expect(find.text('深色 · 默认'), findsOneWidget);

    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();

    expect(find.text('当前未登录'), findsOneWidget);
  });

  testWidgets('settings language flow persists selected locale', (
    tester,
  ) async {
    await _pumpOfflineApp(tester);

    await _openSettings(tester);

    await tester.tap(find.byKey(const Key('settings-row-language')));
    await tester.pumpAndSettle();

    expect(find.text('语言'), findsOneWidget);
    expect(find.byKey(const Key('language-row-en')), findsOneWidget);

    await tester.tap(find.byKey(const Key('language-row-en')));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('app.locale'), 'en');

    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('settings notification toggle persists preference', (
    tester,
  ) async {
    await _pumpOfflineApp(
      tester,
      notificationPermissionService: _E2eNotificationPermissionService(
        state: NotificationPermissionState.granted,
      ),
    );

    await _openSettings(tester);

    await tester.tap(find.byKey(const Key('settings-row-notifications')));
    await tester.pumpAndSettle();

    expect(find.text('通知设置'), findsOneWidget);
    expect(find.text('系统通知已开启'), findsOneWidget);

    final medicationRow = find.byKey(const Key('notification-row-medication'));
    final before = _readSwitchValue(tester, _switchIn(medicationRow));

    await tester.tap(medicationRow);
    await tester.pumpAndSettle();

    final after = _readSwitchValue(tester, _switchIn(medicationRow));
    expect(after, isNot(before));

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getBool('settings.notifications.medicationReminders'),
      after,
    );

    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();

    expect(find.text('设置'), findsOneWidget);
  });

  testWidgets('record timeline opens detail and edit with system back', (
    tester,
  ) async {
    final dailyRecordRepository = _E2eDailyRecordRepository();

    await _pumpOfflineApp(
      tester,
      authSessionOverride: _SignedInAuthSessionNotifier.new,
      dailyRecordRepository: dailyRecordRepository,
      recordRepository: _E2eRecordRepository(),
    );

    await _openTab(tester, '记录');

    final entry = find.text('E2E blood pressure');
    await tester.scrollUntilVisible(entry, 240);
    await tester.tap(entry);
    await tester.pumpAndSettle();

    expect(dailyRecordRepository.getCalledWith, 'e2e-record-1');
    expect(find.text('记录详情'), findsOneWidget);
    expect(find.text('E2E blood pressure'), findsOneWidget);
    expect(find.text('118/76 mmHg'), findsOneWidget);
    expect(find.text('E2E detail note'), findsOneWidget);

    await tester.tap(find.byTooltip('编辑'));
    await tester.pumpAndSettle();

    expect(dailyRecordRepository.getCalledWith, 'e2e-record-1');
    expect(find.text('编辑'), findsOneWidget);
    expect(find.text('备注'), findsWidgets);

    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();
    expect(find.text('记录详情'), findsOneWidget);

    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('record-timeline')), findsOneWidget);
  });

  testWidgets('record create saves daily record and returns to timeline', (
    tester,
  ) async {
    final dailyRecordRepository = _E2eDailyRecordRepository();

    await _pumpOfflineApp(
      tester,
      authSessionOverride: _SignedInAuthSessionNotifier.new,
      dailyRecordRepository: dailyRecordRepository,
    );

    await _openTab(tester, '记录');

    await tester.tap(find.byIcon(Icons.add_rounded).last);
    await tester.pumpAndSettle();

    expect(find.text('类型'), findsOneWidget);
    expect(find.text('饮水'), findsOneWidget);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '6');
    await tester.enterText(fields.at(1), 'cups');
    await tester.enterText(fields.at(2), 'E2E hydration note');
    await tester.tap(find.widgetWithText(ElevatedButton, '保存'));
    await tester.pumpAndSettle();

    final input = dailyRecordRepository.createInput;
    expect(input, isNotNull);
    expect(input!.kind, DailyRecordKind.water);
    expect(input.value, '6');
    expect(input.unit, 'cups');
    expect(input.note, 'E2E hydration note');
    expect(input.attachments, isEmpty);
    expect(find.byKey(const Key('record-timeline')), findsOneWidget);
  });

  testWidgets('medicine search route works with offline search data', (
    tester,
  ) async {
    await _pumpOfflineApp(tester);

    await _openTab(tester, '用药');
    expect(find.byKey(const Key('medicine-today-plan')), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search_rounded).last);
    await tester.pumpAndSettle();

    expect(find.text('搜索药品'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '布洛芬');
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('布洛芬片'), findsOneWidget);

    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('medicine-today-plan')), findsOneWidget);
  });

  testWidgets('medicine dose action routes signed-out user to login', (
    tester,
  ) async {
    await _pumpOfflineApp(
      tester,
      medicineWorkspaceRepository: _E2eMedicineWorkspaceRepository(),
    );

    await _openTab(tester, '用药');

    final medicine = find.text('E2E medicine');
    await tester.scrollUntilVisible(medicine, 240);
    expect(medicine, findsOneWidget);

    await tester.tap(find.text('已服用'));
    await tester.pumpAndSettle();

    expect(find.text('邮箱'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '登录'), findsOneWidget);
  });

  testWidgets('auth password login updates global session from app flow', (
    tester,
  ) async {
    final remote = _E2eAuthRemoteDataSource();
    final container = await _pumpOfflineApp(
      tester,
      authRemoteDataSource: remote,
      medicineWorkspaceRepository: _E2eMedicineWorkspaceRepository(),
    );

    await _openTab(tester, '用药');

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
    final remote = _E2eAuthRemoteDataSource();
    final container = await _pumpOfflineApp(
      tester,
      authRemoteDataSource: remote,
      medicineWorkspaceRepository: _E2eMedicineWorkspaceRepository(),
    );

    await _openLoginFromMedicineDose(tester);

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

  testWidgets('auth forgot password flow submits reset from login entry', (
    tester,
  ) async {
    final remote = _E2eAuthRemoteDataSource();
    await _pumpOfflineApp(
      tester,
      authRemoteDataSource: remote,
      medicineWorkspaceRepository: _E2eMedicineWorkspaceRepository(),
    );

    await _openLoginFromMedicineDose(tester);

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

  testWidgets('account settings profile save updates global session', (
    tester,
  ) async {
    final remote = _E2eAuthRemoteDataSource();
    final container = await _pumpOfflineApp(
      tester,
      authSessionOverride: _SignedInAuthSessionNotifier.new,
      authRemoteDataSource: remote,
    );

    await _openTab(tester, '我的');
    await tester.tap(find.byKey(const Key('mine-account-manage-link')));
    await tester.pumpAndSettle();

    expect(find.text('账号与安全'), findsAtLeastNWidgets(1));
    expect(find.text('资料信息'), findsOneWidget);

    await tester.enterText(find.byType(EditableText).at(0), 'E2E Nick');
    await tester.enterText(
      find.byType(EditableText).at(1),
      'https://example.com/e2e-avatar.png',
    );

    final saveButton = find.widgetWithText(FilledButton, '保存资料');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(remote.updateProfileNickname, 'E2E Nick');
    expect(remote.updateProfileAvatar, 'https://example.com/e2e-avatar.png');
    expect(container.read(authSessionProvider).user?.nickname, 'E2E Nick');
    expect(
      container.read(authSessionProvider).user?.avatar,
      'https://example.com/e2e-avatar.png',
    );

    await tester.drag(find.byType(Scrollable).first, const Offset(0, 900));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('mine-profile-grid')), findsOneWidget);
  });

  testWidgets('account change email flow updates global session', (
    tester,
  ) async {
    final remote = _E2eAuthRemoteDataSource();
    final container = await _pumpOfflineApp(
      tester,
      authSessionOverride: _SignedInAuthSessionNotifier.new,
      authRemoteDataSource: remote,
    );

    await _openTab(tester, '我的');
    await tester.tap(find.byKey(const Key('mine-account-manage-link')));
    await tester.pumpAndSettle();

    final changeEmailButton = find.widgetWithText(FilledButton, '更换邮箱');
    await tester.scrollUntilVisible(
      changeEmailButton,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(changeEmailButton);
    await tester.pumpAndSettle();

    expect(find.text('更换邮箱'), findsOneWidget);

    await tester.enterText(
      find.byType(EditableText).at(0),
      'next-e2e@example.com',
    );
    await tester.enterText(find.byType(EditableText).at(1), '246810');
    await tester.tap(find.widgetWithText(FilledButton, '更新邮箱'));
    await tester.pumpAndSettle();

    expect(remote.changeEmailNewEmail, 'next-e2e@example.com');
    expect(remote.changeEmailCode, '246810');
    expect(
      container.read(authSessionProvider).user?.email,
      'next-e2e@example.com',
    );

    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();
    expect(find.text('账号与安全'), findsAtLeastNWidgets(1));
  });

  testWidgets('mine profile edit saves health context and returns', (
    tester,
  ) async {
    final healthContextRepository = _E2eHealthContextRepository();

    await _pumpOfflineApp(
      tester,
      authSessionOverride: _SignedInAuthSessionNotifier.new,
      healthContextRepository: healthContextRepository,
    );

    await _openTab(tester, '我的');
    expect(find.byKey(const Key('mine-profile-grid')), findsOneWidget);

    final basicInfo = find.text('基础资料');
    await tester.scrollUntilVisible(
      basicInfo,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(basicInfo);
    await tester.pumpAndSettle();

    expect(find.text('编辑档案'), findsOneWidget);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '1998-06-07');
    await tester.enterText(fields.at(1), '171');
    await tester.enterText(fields.at(2), 'AB');

    final saveButton = find.text('保存');
    await tester.scrollUntilVisible(
      saveButton,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    final input = healthContextRepository.profileUpdate;
    expect(input, isNotNull);
    expect(input!.birthDate, '1998-06-07');
    expect(input.heightCm, 171);
    expect(input.bloodType, 'AB');
    expect(find.byKey(const Key('mine-profile-grid')), findsOneWidget);
  });

  testWidgets('mine allergy create saves health context and returns', (
    tester,
  ) async {
    final healthContextRepository = _E2eHealthContextRepository();

    await _pumpOfflineApp(
      tester,
      authSessionOverride: _SignedInAuthSessionNotifier.new,
      healthContextRepository: healthContextRepository,
    );

    await _openMineProfileEntry(tester, '过敏史');

    expect(find.text('新增过敏'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('allergy-label-field')),
      'E2E penicillin',
    );
    await tester.tap(find.byKey(const Key('allergy-save-button')));
    await tester.pumpAndSettle();

    final input = healthContextRepository.allergyCreate;
    expect(input, isNotNull);
    expect(input!.label, 'E2E penicillin');
    expect(input.kind, HealthAllergyKind.drug);
    expect(find.byKey(const Key('mine-profile-grid')), findsOneWidget);
  });

  testWidgets('mine condition create saves health context and returns', (
    tester,
  ) async {
    final healthContextRepository = _E2eHealthContextRepository();

    await _pumpOfflineApp(
      tester,
      authSessionOverride: _SignedInAuthSessionNotifier.new,
      healthContextRepository: healthContextRepository,
    );

    await _openMineProfileEntry(tester, '基础病史');

    expect(find.text('新增疾病'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('condition-label-field')),
      'E2E asthma',
    );
    await tester.tap(find.byKey(const Key('condition-save-button')));
    await tester.pumpAndSettle();

    final input = healthContextRepository.conditionCreate;
    expect(input, isNotNull);
    expect(input!.label, 'E2E asthma');
    expect(input.status, HealthConditionStatus.active);
    expect(find.byKey(const Key('mine-profile-grid')), findsOneWidget);
  });

  testWidgets('mine current medicine create saves health context and returns', (
    tester,
  ) async {
    final healthContextRepository = _E2eHealthContextRepository();

    await _pumpOfflineApp(
      tester,
      authSessionOverride: _SignedInAuthSessionNotifier.new,
      healthContextRepository: healthContextRepository,
    );

    await _openMineProfileEntry(tester, '当前用药');

    expect(find.text('新增用药'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('medicine-displayname-field')),
      'E2E ibuprofen',
    );
    final saveButton = find.byKey(const Key('medicine-save-button'));
    await tester.scrollUntilVisible(
      saveButton,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    final input = healthContextRepository.medicineCreate;
    expect(input, isNotNull);
    expect(input!.displayName, 'E2E ibuprofen');
    expect(input.source, HealthMedicineSource.manual);
    expect(find.byKey(const Key('mine-profile-grid')), findsOneWidget);
  });
}

Future<ProviderContainer> _pumpOfflineApp(
  WidgetTester tester, {
  AuthSessionNotifier Function()? authSessionOverride,
  AuthRemoteDataSource? authRemoteDataSource,
  HealthContextRepository? healthContextRepository,
  NotificationPermissionService? notificationPermissionService,
  DailyRecordRepository? dailyRecordRepository,
  RecordRepository? recordRepository,
  MedicineWorkspaceRepository? medicineWorkspaceRepository,
}) async {
  SharedPreferences.setMockInitialValues(const <String, Object>{
    'app.locale': 'zh-CN',
  });
  router.go('/');

  final container = ProviderContainer(
    overrides: [
      authSessionProvider.overrideWith(
        authSessionOverride ?? _NoopRestoreAuthSessionNotifier.new,
      ),
      if (authRemoteDataSource != null)
        authRemoteDataSourceProvider.overrideWithValue(authRemoteDataSource),
      healthContextSnapshotProvider.overrideWith(
        (ref) => Future.value(_emptyHealthContextSnapshot),
      ),
      if (healthContextRepository != null)
        healthContextRepositoryProvider.overrideWithValue(
          healthContextRepository,
        ),
      if (notificationPermissionService != null)
        notificationPermissionServiceProvider.overrideWithValue(
          notificationPermissionService,
        ),
      if (dailyRecordRepository != null)
        dailyRecordRepositoryProvider.overrideWithValue(dailyRecordRepository),
      todayRepositoryProvider.overrideWithValue(const MockTodayRepository()),
      recordRepositoryProvider.overrideWithValue(
        recordRepository ?? const MockRecordRepository(),
      ),
      medicineWorkspaceRepositoryProvider.overrideWithValue(
        medicineWorkspaceRepository ?? const MockMedicineWorkspaceRepository(),
      ),
      mineRepositoryProvider.overrideWithValue(const MockMineRepository()),
      moreRepositoryProvider.overrideWithValue(const MockMoreRepository()),
      medicineSearchRepositoryProvider.overrideWithValue(
        const MockMedicineSearchRepository(),
      ),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const LuminousApp()),
  );

  await tester.pumpAndSettle();
  return container;
}

Future<void> _openTab(WidgetTester tester, String label) async {
  final tab = find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );
  await tester.tap(tab);
  await tester.pumpAndSettle();
}

Future<void> _openSettings(WidgetTester tester) async {
  await _openTab(tester, '我的');
  await tester.tap(find.byKey(const Key('mine-settings-action')));
  await tester.pumpAndSettle();
  expect(find.text('设置'), findsOneWidget);
}

Future<void> _openLoginFromMedicineDose(WidgetTester tester) async {
  await _openTab(tester, '用药');

  final medicine = find.text('E2E medicine');
  await tester.scrollUntilVisible(medicine, 240);
  await tester.tap(find.text('已服用'));
  await tester.pumpAndSettle();

  expect(find.text('邮箱'), findsOneWidget);
  expect(find.widgetWithText(FilledButton, '登录'), findsOneWidget);
}

Finder _switchIn(Finder parent) {
  return find.descendant(of: parent, matching: find.byType(Switch)).first;
}

bool _readSwitchValue(WidgetTester tester, Finder finder) {
  return tester.widget<Switch>(finder).value;
}

Future<void> _openMineProfileEntry(WidgetTester tester, String label) async {
  await _openTab(tester, '我的');
  final profileGrid = find.byKey(const Key('mine-profile-grid'));
  expect(profileGrid, findsOneWidget);

  final entry = find.descendant(of: profileGrid, matching: find.text(label));
  await tester.scrollUntilVisible(
    entry,
    240,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(entry);
  await tester.pumpAndSettle();
}

class _NoopRestoreAuthSessionNotifier extends AuthSessionNotifier {
  @override
  Future<void> restore() async {}
}

class _SignedInAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return AuthSessionState(
      isAuthenticated: true,
      isLoading: false,
      user: AuthUser(
        id: 'e2e-user-1',
        email: 'e2e@example.com',
        nickname: 'E2E User',
        avatar: null,
        emailVerifiedAt: DateTime.parse('2026-06-06T00:00:00Z'),
        hasPassword: true,
        createdAt: DateTime.parse('2026-06-06T00:00:00Z'),
        updatedAt: DateTime.parse('2026-06-06T00:00:00Z'),
      ),
    );
  }

  @override
  Future<void> restore() async {}
}

class _E2eAuthRemoteDataSource extends AuthRemoteDataSource {
  _E2eAuthRemoteDataSource()
    : super(
        LucentDioClient(
          baseUrl: 'http://localhost',
          sessionStore: _MemorySessionStore(),
        ),
      );

  String? loginEmail;
  String? loginPassword;
  String? loginCode;
  String? registerEmail;
  String? registerPassword;
  String? registerCode;
  String? registerNickname;
  String? sentCodeEmail;
  AuthVerificationScene? sentCodeScene;
  String? forgotPasswordEmail;
  String? resetPasswordEmail;
  String? resetPasswordCode;
  String? resetPasswordValue;
  String? changeEmailNewEmail;
  String? changeEmailCode;
  String? updateProfileNickname;
  String? updateProfileAvatar;

  @override
  Future<AuthSession> login({
    required String email,
    String? password,
    String? code,
  }) async {
    loginEmail = email;
    loginPassword = password;
    loginCode = code;
    return AuthSession(
      user: AuthUser(
        id: 'e2e-auth-user-1',
        email: email,
        nickname: 'E2E Auth User',
        avatar: null,
        emailVerifiedAt: DateTime.parse('2026-06-06T00:00:00Z'),
        hasPassword: true,
        createdAt: DateTime.parse('2026-06-06T00:00:00Z'),
        updatedAt: DateTime.parse('2026-06-06T00:00:00Z'),
      ),
      accessToken: 'e2e-access-token',
      refreshToken: 'e2e-refresh-token',
      expiresInSeconds: 3600,
    );
  }

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String code,
    String? nickname,
  }) async {
    registerEmail = email;
    registerPassword = password;
    registerCode = code;
    registerNickname = nickname;
    return AuthSession(
      user: AuthUser(
        id: 'e2e-register-user-1',
        email: email,
        nickname: nickname,
        avatar: null,
        emailVerifiedAt: DateTime.parse('2026-06-06T00:00:00Z'),
        hasPassword: true,
        createdAt: DateTime.parse('2026-06-06T00:00:00Z'),
        updatedAt: DateTime.parse('2026-06-06T00:00:00Z'),
      ),
      accessToken: 'e2e-register-access-token',
      refreshToken: 'e2e-register-refresh-token',
      expiresInSeconds: 3600,
    );
  }

  @override
  Future<CooldownMessageDto> sendVerificationCode({
    required String email,
    required AuthVerificationScene scene,
  }) async {
    sentCodeEmail = email;
    sentCodeScene = scene;
    return CooldownMessageDto(message: 'sent', cooldown: 60);
  }

  @override
  Future<CooldownMessageDto> forgotPassword({required String email}) async {
    forgotPasswordEmail = email;
    return CooldownMessageDto(message: 'sent', cooldown: 60);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    resetPasswordEmail = email;
    resetPasswordCode = code;
    resetPasswordValue = password;
  }

  @override
  Future<AuthUser> changeEmail({
    required String newEmail,
    required String code,
    required AuthUser currentUser,
  }) async {
    changeEmailNewEmail = newEmail;
    changeEmailCode = code;
    return currentUser.copyWith(
      email: newEmail,
      emailVerifiedAt: DateTime.parse('2026-06-06T00:00:00Z'),
      updatedAt: DateTime.parse('2026-06-06T02:00:00Z'),
    );
  }

  @override
  Future<AuthUser> updateAccountProfile({
    String? nickname,
    String? avatar,
  }) async {
    updateProfileNickname = nickname;
    updateProfileAvatar = avatar;
    return AuthUser(
      id: 'e2e-user-1',
      email: 'e2e@example.com',
      nickname: nickname,
      avatar: avatar,
      emailVerifiedAt: DateTime.parse('2026-06-06T00:00:00Z'),
      hasPassword: true,
      createdAt: DateTime.parse('2026-06-06T00:00:00Z'),
      updatedAt: DateTime.parse('2026-06-06T01:00:00Z'),
    );
  }
}

class _MemorySessionStore implements LucentSessionStore {
  LucentSessionTokens? tokens;

  @override
  Future<void> clear() async {
    tokens = null;
  }

  @override
  Future<LucentSessionTokens?> read() async => tokens;

  @override
  Future<String?> readAccessToken() async => tokens?.accessToken;

  @override
  Future<String?> readRefreshToken() async => tokens?.refreshToken;

  @override
  Future<void> write(LucentSessionTokens tokens) async {
    this.tokens = tokens;
  }
}

class _E2eNotificationPermissionService extends NotificationPermissionService {
  _E2eNotificationPermissionService({
    this.state = NotificationPermissionState.unsupported,
  });

  final NotificationPermissionState state;

  @override
  Future<void> ensureInitialized() async {}

  @override
  Future<NotificationPermissionState> getPermissionState() async {
    return state;
  }

  @override
  Future<NotificationPermissionState> requestPermission() async {
    return state;
  }
}

class _E2eHealthContextRepository implements HealthContextRepository {
  HealthProfileUpdateInput? profileUpdate;
  HealthAllergyWriteInput? allergyCreate;
  HealthConditionWriteInput? conditionCreate;
  CurrentMedicineWriteInput? medicineCreate;

  @override
  Future<HealthContextSnapshot> fetchHealthContext() async {
    return _emptyHealthContextSnapshot;
  }

  @override
  Future<HealthContextSnapshot> updateProfile(
    HealthProfileUpdateInput input,
  ) async {
    profileUpdate = input;
    return _emptyHealthContextSnapshot;
  }

  @override
  Future<HealthContextSnapshot> createAllergy(
    HealthAllergyWriteInput input,
  ) async {
    allergyCreate = input;
    return _emptyHealthContextSnapshot;
  }

  @override
  Future<HealthContextSnapshot> updateAllergy(
    String id,
    HealthAllergyUpdateInput input,
  ) async {
    return _emptyHealthContextSnapshot;
  }

  @override
  Future<HealthContextSnapshot> deleteAllergy(String id) async {
    return _emptyHealthContextSnapshot;
  }

  @override
  Future<HealthContextSnapshot> createCondition(
    HealthConditionWriteInput input,
  ) async {
    conditionCreate = input;
    return _emptyHealthContextSnapshot;
  }

  @override
  Future<HealthContextSnapshot> updateCondition(
    String id,
    HealthConditionUpdateInput input,
  ) async {
    return _emptyHealthContextSnapshot;
  }

  @override
  Future<HealthContextSnapshot> deleteCondition(String id) async {
    return _emptyHealthContextSnapshot;
  }

  @override
  Future<HealthContextSnapshot> createCurrentMedicine(
    CurrentMedicineWriteInput input,
  ) async {
    medicineCreate = input;
    return _emptyHealthContextSnapshot;
  }

  @override
  Future<HealthContextSnapshot> updateCurrentMedicine(
    String id,
    CurrentMedicineUpdateInput input,
  ) async {
    return _emptyHealthContextSnapshot;
  }

  @override
  Future<HealthContextSnapshot> deleteCurrentMedicine(String id) async {
    return _emptyHealthContextSnapshot;
  }
}

class _E2eRecordRepository implements RecordRepository {
  @override
  Future<RecordDashboard> fetchDashboard(DateTime selectedDate) async {
    final mock = await const MockRecordRepository().fetchDashboard(
      selectedDate,
    );

    return RecordDashboard(
      selectedDay: selectedDate.day,
      weekDays: mock.weekDays,
      monthDays: mock.monthDays,
      quickActions: mock.quickActions,
      summary: mock.summary,
      filters: mock.filters,
      timeline: const [
        RecordTimelineEntry(
          time: '09:45',
          type: RecordEntryType.vitals,
          icon: Icons.favorite_rounded,
          accent: Color(0xFFFF4D57),
          softColor: Color(0xFFFFEEEE),
          titleKey: RecordCopyKey.typeVitals,
          rawTitle: 'E2E blood pressure',
          value: '118/76 mmHg',
          recordId: 'e2e-record-1',
        ),
      ],
      trends: mock.trends,
      healthBag: mock.healthBag,
    );
  }
}

class _E2eDailyRecordRepository implements DailyRecordRepository {
  String? getCalledWith;
  DailyRecordCreateInput? createInput;

  @override
  Future<DailyRecordListData> fetchRecords(
    String date, {
    String? kind,
    int page = 1,
    int pageSize = 50,
  }) async {
    return DailyRecordListData(items: [_record], total: 1);
  }

  @override
  Future<DailyRecordSummaryData> fetchSummary(String date) async {
    return const DailyRecordSummaryData(summaries: []);
  }

  @override
  Future<DailyRecordItem> get(String id) async {
    getCalledWith = id;
    return _record;
  }

  @override
  Future<DailyRecordAttachmentInput> uploadImage(
    DailyRecordImageUploadInput input,
  ) async {
    return DailyRecordAttachmentInput(
      objectKey: 'daily-records/e2e/test.jpg',
      fileName: input.fileName,
      contentType: input.contentType,
      sizeBytes: input.sizeBytes,
      publicUrl: 'https://cdn.example.com/e2e.jpg',
    );
  }

  @override
  Future<DailyRecordItem> create(DailyRecordCreateInput input) async {
    createInput = input;
    return _record;
  }

  @override
  Future<DailyRecordItem> update(
    String id,
    DailyRecordUpdateInput input,
  ) async {
    return _record;
  }

  @override
  Future<void> delete(String id) async {}

  static final _record = DailyRecordItem(
    id: 'e2e-record-1',
    kind: DailyRecordKind.vital,
    occurredAt: '2026-06-06T09:45:00',
    title: 'E2E blood pressure',
    value: '118/76',
    unit: 'mmHg',
    note: 'E2E detail note',
    source: 'manual',
    createdAt: '2026-06-06T09:45:00',
    updatedAt: '2026-06-06T10:00:00',
  );
}

class _E2eMedicineWorkspaceRepository implements MedicineWorkspaceRepository {
  @override
  Future<MedicineWorkspace> fetchWorkspace() async {
    final mock = await const MockMedicineWorkspaceRepository().fetchWorkspace();
    return MedicineWorkspace(
      hero: mock.hero,
      quickActions: mock.quickActions,
      plan: const MedicinePlanSurface(
        items: [
          MedicinePlanItem(
            color: Color(0xFF159B55),
            nameKey: MedicineCopyKey.mockNameMetformin,
            dosageKey: MedicineCopyKey.mockDoseMetformin,
            scheduleKey: MedicineCopyKey.mockScheduleMorningEvening,
            slots: [
              MedicineDoseSlot(
                timeKey: MedicineCopyKey.mockTime0800,
                statusKey: MedicineCopyKey.doseStatusPending,
                status: MedicineDoseStatus.pending,
              ),
            ],
            stockKey: MedicineCopyKey.mockStock7Days,
            stateKey: MedicineCopyKey.statusStable,
            stateColor: Color(0xFF159B55),
            rawName: 'E2E medicine',
            rawDosage: '1 tablet',
            rawSchedule: 'morning',
            rawStock: '7 days',
            rawState: 'pending',
            currentMedicineId: 'e2e-medicine-1',
          ),
        ],
      ),
      alerts: mock.alerts,
      promisePoints: mock.promisePoints,
    );
  }
}

const _emptyHealthContextSnapshot = HealthContextSnapshot(
  summary: HealthSummary(
    age: null,
    onboardingCompleted: false,
    activeAllergyCount: 0,
    conditionCount: 0,
    currentMedicineCount: 0,
    missingCoreProfileFields: <String>[],
  ),
  profile: HealthProfile(
    birthDate: null,
    sexAtBirth: null,
    heightCm: null,
    pregnancyState: null,
    lactationState: null,
    bloodType: null,
    locale: null,
    timezone: null,
    unitSystem: null,
    onboardingCompletedAt: null,
    extras: <String, dynamic>{},
  ),
  allergies: <AllergyItem>[],
  conditions: <ConditionItem>[],
  currentMedicines: <CurrentMedicineItem>[],
);
