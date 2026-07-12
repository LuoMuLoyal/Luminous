import 'package:luminous/core/design/semantic_color.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:patrol/patrol.dart';
import 'package:lucent_api/api/export.dart'
    show CooldownMessageDto, LucentClient, MedicineDoseLogsApi;
import 'package:luminous/app/bootstrap.dart';
import 'package:luminous/app/router.dart' show router;
import 'package:luminous/core/network/network_providers.dart'
    show lucentBaseUrlProvider, lucentSessionStoreProvider;
import 'package:luminous/core/network/session_store.dart';
import 'package:luminous/features/auth/data/datasources/auth.dart';
import 'package:luminous/features/auth/data/providers/auth.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:luminous/features/health_context/domain/repositories/snapshot.dart';
import 'package:luminous/features/medicine/data/repositories/risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/domain/services/risk_checker.dart';
import 'package:luminous/features/search/data/datasources/medicine_search.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_remote.dart';
import 'package:luminous/features/medicine/data/repositories/mock_workspace.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';
import 'package:luminous/features/medicine/domain/repositories/workspace.dart';
import 'package:luminous/features/mine/data/repositories/mock.dart'
    show MockMineRepository;
import 'package:luminous/features/mine/presentation/providers/dashboard.dart'
    show mineRepositoryProvider;
import 'package:luminous/features/notification/presentation/providers/notification.dart'
    show notificationUnreadCountProvider;
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/data/repositories/mock.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/entities/candidates.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/domain/repositories/record.dart';
import 'package:luminous/features/record/domain/repositories/daily.dart';
import 'package:luminous/features/report/data/repositories/mock.dart'
    show reportRepositoryProvider;
import 'package:luminous/features/report/domain/repositories/report.dart'
    show ReportRepository;
import 'package:luminous/features/search/data/repositories/lucent.dart'
    show medicineSearchRepositoryProvider;
import 'package:luminous/features/search/domain/entities/entities.dart';
import 'package:luminous/features/search/domain/repositories/search.dart';
import 'package:luminous/features/settings/data/providers/notification_permission.dart';
import 'package:luminous/features/settings/data/services/notification_permission_service.dart';
import 'package:luminous/features/shell/presentation/tab.dart';
import 'package:luminous/features/today/data/repositories/mock.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'package:flutter/material.dart';
export 'package:flutter_test/flutter_test.dart';
export 'package:forui/forui.dart';
export 'package:patrol/patrol.dart' hide Notification;
export 'package:luminous/app/router.dart' show router;
export 'package:luminous/features/auth/data/datasources/auth.dart'
    show AuthVerificationScene;
export 'package:luminous/features/auth/presentation/providers/session.dart'
    show authSessionProvider;
export 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
export 'package:luminous/features/record/domain/entities/inputs.dart'
    show dailyRecordNoChange;
export 'package:luminous/features/record/domain/entities/record.dart'
    show DailyRecordKind;
export 'package:luminous/features/report/data/repositories/mock.dart'
    show MockReportRepository, reportRepositoryProvider;
export 'package:luminous/features/settings/data/services/notification_permission_service.dart';
export 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> pumpOfflineApp(
  PatrolIntegrationTester $, {
  AuthSessionNotifier Function()? authSessionOverride,
  AuthRemoteDataSource? authRemoteDataSource,
  HealthContextRepository? healthContextRepository,
  MedicineRiskCheckRepository? medicineRiskCheckRepository,
  NotificationPermissionService? notificationPermissionService,
  DailyRecordRepository? dailyRecordRepository,
  RecordRepository? recordRepository,
  ReportRepository? reportRepository,
  MedicineWorkspaceRepository? medicineWorkspaceRepository,
  DoseLogRemoteDataSource? doseLogRemoteDataSource,
}) async {
  SharedPreferences.setMockInitialValues(const <String, Object>{});
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  await prefs.setString('app.locale', 'zh-CN');
  router.go('/');

  final container = ProviderContainer(
    overrides: [
      authSessionProvider.overrideWith(
        authSessionOverride ?? _NoopRestoreAuthSessionNotifier.new,
      ),
      lucentBaseUrlProvider.overrideWithValue('http://localhost'),
      lucentSessionStoreProvider.overrideWithValue(_MemorySessionStore()),
      notificationUnreadCountProvider.overrideWith((ref) => Future.value(0)),
      if (authRemoteDataSource != null)
        authRemoteDataSourceProvider.overrideWithValue(authRemoteDataSource),
      healthContextSnapshotProvider.overrideWith(
        (ref) => Future.value(_emptyHealthContextSnapshot),
      ),
      if (healthContextRepository != null)
        healthContextRepositoryProvider.overrideWithValue(
          healthContextRepository,
        ),
      medicineRiskCheckRepositoryProvider.overrideWithValue(
        medicineRiskCheckRepository ?? const E2eMedicineRiskCheckRepository(),
      ),
      if (notificationPermissionService != null)
        notificationPermissionServiceProvider.overrideWithValue(
          notificationPermissionService,
        ),
      if (dailyRecordRepository != null)
        dailyRecordRepositoryProvider.overrideWithValue(dailyRecordRepository),
      if (doseLogRemoteDataSource != null)
        doseLogRemoteDataSourceProvider.overrideWithValue(
          doseLogRemoteDataSource,
        ),
      todayRepositoryProvider.overrideWithValue(const MockTodayRepository()),
      if (reportRepository != null)
        reportRepositoryProvider.overrideWithValue(reportRepository),
      recordRepositoryProvider.overrideWithValue(
        recordRepository ?? const MockRecordRepository(),
      ),
      medicineWorkspaceRepositoryProvider.overrideWithValue(
        medicineWorkspaceRepository ?? const MockMedicineWorkspaceRepository(),
      ),
      mineRepositoryProvider.overrideWithValue(const MockMineRepository()),
      medicineSearchRepositoryProvider.overrideWithValue(
        const MockMedicineSearchRepository(),
      ),
    ],
  );
  addTearDown(container.dispose);

  await $.pumpWidget(
    UncontrolledProviderScope(container: container, child: const LuminousApp()),
  );

  await settleE2e($);
  return container;
}

Future<void> settleE2e(
  PatrolIntegrationTester $, {
  Duration duration = const Duration(milliseconds: 100),
  int frames = 6,
}) async {
  for (var i = 0; i < frames; i += 1) {
    await $.pump(duration);
  }
}

Future<void> pumpUntilFound(
  PatrolIntegrationTester $,
  Finder finder, {
  Duration timeout = const Duration(seconds: 5),
  Duration step = const Duration(milliseconds: 100),
}) async {
  final endTime = $.tester.binding.clock.fromNowBy(timeout);

  do {
    await $.pump(step);
    if ($.tester.any(finder)) {
      return;
    }
  } while ($.tester.binding.clock.now().isBefore(endTime));

  fail('Timed out waiting for $finder');
}

Future<void> openTab(PatrolIntegrationTester $, String label) async {
  final shellTab = _shellTabForLabel(label);
  if (shellTab != null) {
    await openShellTab($, shellTab);
    return;
  }

  final tab = find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );
  await $.tester.tap(tab);
  await settleE2e($);
}

Future<void> openShellTab(
  PatrolIntegrationTester $,
  ShellTab tab, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final tabFinder = find.byKey(tab.testKey());
  await pumpUntilFound($, tabFinder, timeout: timeout);
  await $.tester.ensureVisible(tabFinder);
  await settleE2e($);
  await $.tester.tap(tabFinder);
  await settleE2e($);
}

Future<void> openSettings(PatrolIntegrationTester $) async {
  await openShellTab($, ShellTab.mine);
  await $.tester.tap(find.byKey(const Key('mine-settings-action')));
  await settleE2e($);
  expect($('设置').exists, true);
}

Future<void> tapSettingsFooterAction(PatrolIntegrationTester $) async {
  await tapVisible($, find.byKey(const Key('settings-footer-action')));
}

Future<void> tapVisible(PatrolIntegrationTester $, Finder finder) async {
  await pumpUntilFound($, finder);
  await $.tester.ensureVisible(finder);
  await settleE2e($);
  await $.tester.tap(finder);
  await settleE2e($);
}

Future<void> openLoginFromSignedOutMine(PatrolIntegrationTester $) async {
  await openShellTab($, ShellTab.mine);

  final loginAction = find.byKey(const Key('mine-signed-out-login-action'));
  await tapVisible($, loginAction);

  expect($('邮箱').exists, true);
  expect(find.widgetWithText(FilledButton, '登录'), findsOneWidget);
}

Future<void> tapMedicineDoseAction(
  PatrolIntegrationTester $,
  String label,
) async {
  final actionKey = switch (label) {
    '跳过' || 'Skipped' => 'medicine-next-dose-action-skipped',
    _ => 'medicine-next-dose-action-taken',
  };
  final action = find.byKey(Key(actionKey));
  await pumpUntilFound($, action);
  await $.tester.ensureVisible(action);
  await settleE2e($);
  await $.tester.tap(action);
  await settleE2e($);
}

String todayDateString() {
  final today = DateTime.now();
  return '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
}

Finder switchIn(Finder parent) {
  return find.descendant(of: parent, matching: find.byType(Switch)).first;
}

bool readSwitchValue(PatrolIntegrationTester $, Finder finder) {
  final switchFinder = finder.evaluate().first.widget is Switch
      ? finder
      : find.descendant(of: finder, matching: find.byType(Switch)).first;
  return $.tester.widget<Switch>(switchFinder).value;
}

Future<void> openMineProfileEntry(
  PatrolIntegrationTester $,
  String label,
) async {
  await openShellTab($, ShellTab.mine);
  final archiveSection = find.byKey(const Key('mine-archive-section'));
  await pumpUntilFound($, archiveSection);
  expect(archiveSection, findsOneWidget);

  final entry = find.descendant(of: archiveSection, matching: find.text(label));
  await tapVisible($, entry);
}

ShellTab? _shellTabForLabel(String label) {
  return switch (label.trim().toLowerCase()) {
    'today' || '今天' => ShellTab.today,
    'record' || '记录' => ShellTab.record,
    'medicine' || '用药' => ShellTab.medicine,
    'report' || '报告' => ShellTab.report,
    'mine' || '我的' || 'account' => ShellTab.mine,
    _ => null,
  };
}

class _NoopRestoreAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return const AuthSessionState();
  }

  @override
  Future<void> restore() async {}
}

class SignedInAuthSessionNotifier extends AuthSessionNotifier {
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

class SignedInWithWechatIdentityAuthSessionNotifier
    extends AuthSessionNotifier {
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
        linkedIdentities: [
          AuthLinkedIdentity(
            id: 'e2e-identity-1',
            provider: 'wechat_web',
            email: null,
            emailVerifiedAt: null,
            linkedAt: DateTime.parse('2026-06-06T01:00:00Z'),
          ),
        ],
        createdAt: DateTime.parse('2026-06-06T00:00:00Z'),
        updatedAt: DateTime.parse('2026-06-06T00:00:00Z'),
      ),
    );
  }

  @override
  Future<void> restore() async {}
}

class E2eAuthRemoteDataSource extends AuthRemoteDataSource {
  E2eAuthRemoteDataSource()
    : super(
        LucentClient(Dio(BaseOptions(baseUrl: 'http://localhost'))),
        _MemorySessionStore(),
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
  String? changePasswordOldPassword;
  String? changePasswordNewPassword;
  String? deleteAccountPassword;
  String? unlinkIdentityId;
  bool logoutCalled = false;

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
    return const CooldownMessageDto(message: 'sent', cooldown: 60);
  }

  @override
  Future<CooldownMessageDto> forgotPassword({required String email}) async {
    forgotPasswordEmail = email;
    return const CooldownMessageDto(message: 'sent', cooldown: 60);
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

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    changePasswordOldPassword = oldPassword;
    changePasswordNewPassword = newPassword;
  }

  @override
  Future<void> deleteAccount({String? password, String? code}) async {
    deleteAccountPassword = password;
  }

  @override
  Future<AuthUser> unlinkIdentity({required String identityId}) async {
    unlinkIdentityId = identityId;
    return AuthUser(
      id: 'e2e-user-1',
      email: 'e2e@example.com',
      nickname: 'E2E User',
      avatar: null,
      emailVerifiedAt: DateTime.parse('2026-06-06T00:00:00Z'),
      hasPassword: true,
      linkedIdentities: const [],
      createdAt: DateTime.parse('2026-06-06T00:00:00Z'),
      updatedAt: DateTime.parse('2026-06-06T03:00:00Z'),
    );
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
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

class E2eNotificationPermissionService extends NotificationPermissionService {
  E2eNotificationPermissionService({
    this.state = NotificationPermissionState.unsupported,
  });

  final NotificationPermissionState state;
  int requestCount = 0;

  @override
  Future<void> ensureInitialized() async {}

  @override
  Future<NotificationPermissionState> getPermissionState() async {
    return state;
  }

  @override
  Future<NotificationPermissionState> requestPermission() async {
    requestCount += 1;
    return state;
  }
}

class E2eMedicineRiskCheckRepository implements MedicineRiskCheckRepository {
  const E2eMedicineRiskCheckRepository();

  @override
  MedicineRiskChecker get checker => const MedicineRiskChecker();

  @override
  // ignore: unused_element
  MedicineSearchRemoteDataSource get remoteDataSource =>
      throw UnimplementedError();

  @override
  Future<MedicineRiskCheckResult> fetchForSnapshot(
    HealthContextSnapshot snapshot,
  ) async {
    return const MedicineRiskCheckResult(
      currentMedicineCount: 0,
      checkedMedicineCount: 0,
      findings: [],
      coverageIssues: [],
    );
  }
}

class E2eHealthContextRepository implements HealthContextRepository {
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

class E2eRecordRepository implements RecordRepository {
  final requestedDates = <DateTime>[];

  @override
  Future<RecordDashboard> fetchDashboard(
    DateTime selectedDate, {
    RecordEntryType? filterType,
  }) async {
    requestedDates.add(selectedDate);
    final mock = await const MockRecordRepository().fetchDashboard(
      selectedDate,
      filterType: filterType,
    );

    return RecordDashboard(
      selectedDate: selectedDate,
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
          icon: FLucideIcons.heart,
          accent: SemanticColor.destructive,
          softColor: SemanticColor.neutral,
          titleKey: RecordCopyKey.typeVitals,
          rawTitle: 'E2E blood pressure',
          value: '118/76 mmHg',
          recordId: 'e2e-record-1',
        ),
      ],
      trends: mock.trends,
    );
  }

  @override
  Future<RecordDashboard> signedOutDashboard(
    DateTime selectedDate, {
    RecordEntryType? filterType,
  }) => Future.value(RecordDashboard.signedOut(selectedDate));
}

class E2eDailyRecordRepository implements DailyRecordRepository {
  String? getCalledWith;
  String? updateCalledWith;
  String? deleteCalledWith;
  DailyRecordCreateInput? createInput;
  DailyRecordUpdateInput? updateInput;

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
  Future<DailyRecordCandidateResult> generateCandidates({
    required String text,
    required String occurredAt,
  }) async {
    return const DailyRecordCandidateResult(
      locale: 'zh-CN',
      generatedAt: '2026-06-14T00:00:00.000Z',
      confirmationHint: '确认后再保存。',
      items: <DailyRecordCandidateItem>[],
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
    updateCalledWith = id;
    updateInput = input;
    return _record;
  }

  @override
  Future<void> delete(String id) async {
    deleteCalledWith = id;
  }

  static final _record = const DailyRecordItem(
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

class E2eMedicineWorkspaceRepository implements MedicineWorkspaceRepository {
  @override
  Future<MedicineWorkspace> fetchWorkspace() async {
    final mock = await const MockMedicineWorkspaceRepository().fetchWorkspace();
    return MedicineWorkspace(
      hero: mock.hero,
      quickActions: mock.quickActions,
      plan: const MedicinePlanSurface(
        items: [
          MedicinePlanItem(
            color: SemanticColor.primary,
            nameKey: MedicineCopyKey.genericName,
            dosageKey: MedicineCopyKey.genericDosage,
            scheduleKey: MedicineCopyKey.genericSchedule,
            slots: [
              MedicineDoseSlot(
                rawTime: '08:00',
                statusKey: MedicineCopyKey.doseStatusPending,
                status: MedicineDoseStatus.pending,
              ),
            ],
            stateKey: MedicineCopyKey.statusStable,
            stateColor: SemanticColor.primary,
            rawName: 'E2E medicine',
            rawDosage: '1 tablet',
            rawSchedule: 'morning',
            rawState: 'pending',
            todayStatus: MedicineDoseStatus.pending,
            currentMedicineId: 'e2e-medicine-1',
          ),
        ],
      ),
      alerts: mock.alerts,
      promisePoints: mock.promisePoints,
    );
  }

  @override
  Future<MedicineWorkspace> get signedOutWorkspace =>
      Future.value(MedicineWorkspace.signedOut());
}

class E2eDoseLogRemoteDataSource extends DoseLogRemoteDataSource {
  E2eDoseLogRemoteDataSource()
    : super(
        api: MedicineDoseLogsApi(Dio(BaseOptions())),
        dio: Dio(BaseOptions()),
      );

  String? createCurrentMedicineId;
  String? createStatus;
  String? createDate;

  Future<DoseLogItem> markForDate(
    String currentMedicineId,
    String status,
    String date,
  ) async {
    return create(currentMedicineId, status, date);
  }

  @override
  Future<DoseLogItem> create(
    String currentMedicineId,
    String status,
    String date,
  ) async {
    createCurrentMedicineId = currentMedicineId;
    createStatus = status;
    createDate = date;
    return DoseLogItem(
      id: 'e2e-dose-log-1',
      currentMedicineId: currentMedicineId,
      status: DoseLogStatus.values.firstWhere((item) => item.name == status),
      scheduledFor: date,
      createdAt: '${date}T08:00:00.000Z',
      updatedAt: '',
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

/// Test-only mock with demo data prefixed to avoid confusion with real data.
class MockMedicineSearchRepository implements MedicineSearchRepository {
  const MockMedicineSearchRepository();

  @override
  Future<List<MedicineSearchResult>> search({
    required String query,
    required MedicineSearchSource source,
    int page = 1,
    int pageSize = 20,
  }) async {
    return const [
      MedicineSearchResult(
        id: '__mock_cn_ibuprofen__',
        source: MedicineSearchSource.cn,
        name: '[DEMO] 布洛芬片',
        subtitle: '[DEMO] 0.2g*12片 · 示例药业',
        summary: '[DEMO] 示例摘要，仅用于测试搜索界面。',
        tags: <String>['示例标签'],
        matchType: MedicineSearchMatchType.ingredient,
      ),
      MedicineSearchResult(
        id: '__mock_cn_acetaminophen__',
        source: MedicineSearchSource.cn,
        name: '[DEMO] 对乙酰氨基酚片',
        subtitle: '[DEMO] 0.5g*20片 · 示例药业',
        summary: '[DEMO] 示例摘要，仅用于测试搜索界面。',
        tags: <String>['示例标签'],
        matchType: MedicineSearchMatchType.ingredient,
      ),
    ];
  }

  @override
  Future<MedicineSearchSafetyPreview?> fetchDetail(
    String id,
    MedicineSearchSource source,
  ) async {
    return const MedicineSearchSafetyPreview(
      title: '[DEMO] Ibuprofen',
      conditions: ['[DEMO] 安全提示示例'],
      checklist: ['[DEMO] 已阅读示例说明'],
    );
  }
}
