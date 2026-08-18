import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:lucent_api/lucent_api.dart' show LucentApi, MedicineDoseLogsApi;
import 'package:luminous/app/bootstrap.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/semantic_color.dart';
import 'package:luminous/core/network/client_providers.dart'
    show
        lucentBaseUrlProvider,
        lucentDioClientProvider,
        lucentSessionStoreProvider;
import 'package:luminous/core/network/dio_client.dart';
import 'package:luminous/core/network/session_store.dart';
import 'package:luminous/features/auth/data/datasources/auth.dart';
import 'package:luminous/features/auth/data/providers/auth.dart';
import 'package:luminous/features/auth/domain/entities/auth_verification_scene.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/auth/domain/entities/verification_code.dart';
import 'package:luminous/features/auth/domain/repositories/auth.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:luminous/features/health_context/domain/repositories/snapshot.dart';
import 'package:luminous/features/health_event/data/providers/health_event.dart';
import 'package:luminous/features/health_event/domain/repositories/health_event.dart';
import 'package:luminous/features/legal/data/repositories/lucent.dart'
    show legalRepositoryProvider;
import 'package:luminous/features/legal/domain/entities/doc_type.dart';
import 'package:luminous/features/legal/domain/entities/document.dart';
import 'package:luminous/features/legal/domain/repositories/documents.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_remote.dart';
import 'package:luminous/features/medicine/data/providers/workspace.dart';
import 'package:luminous/features/medicine/data/repositories/risk_check.dart'
    show medicineRiskCheckRepositoryProvider;
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';
import 'package:luminous/features/medicine/domain/repositories/risk_check.dart';
import 'package:luminous/features/medicine/domain/repositories/workspace.dart';
import 'package:luminous/features/mine/data/providers/mine.dart'
    show mineRepositoryProvider;
import 'package:luminous/features/notification/data/providers/unread_count.dart'
    show notificationUnreadCountProvider;
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/domain/entities/candidates.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/repositories/daily.dart';
import 'package:luminous/features/record/domain/repositories/record.dart';
import 'package:luminous/features/report/data/providers/report.dart'
    show reportRepositoryProvider;
import 'package:luminous/features/report/data/providers/review.dart'
    show reviewRepositoryProvider;
import 'package:luminous/features/report/domain/entities/review.dart';
import 'package:luminous/features/report/domain/repositories/report.dart'
    show ReportRepository;
import 'package:luminous/features/report/domain/repositories/review.dart';
import 'package:luminous/features/search/data/repositories/lucent.dart'
    show medicineSearchRepositoryProvider;
import 'package:luminous/features/search/domain/entities/entities.dart';
import 'package:luminous/features/search/domain/repositories/search.dart';
import 'package:luminous/features/settings/data/providers/notification_permission.dart';
import 'package:luminous/features/settings/domain/services/notification_permission.dart';
import 'package:luminous/features/shell/presentation/tab.dart';
import 'package:luminous/features/today/data/providers/today_suggestion.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../test/helpers/feature_mocks.dart';

export 'package:flutter/material.dart';
export 'package:flutter_test/flutter_test.dart';
export 'package:forui/forui.dart';
export 'package:luminous/app/router.dart' show appRouterProvider;
export 'package:luminous/core/auth/session_provider.dart'
    show authSessionProvider;
export 'package:luminous/features/auth/domain/entities/auth_verification_scene.dart'
    show AuthVerificationScene;
export 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
export 'package:luminous/features/legal/data/repositories/lucent.dart'
    show legalRepositoryProvider;
export 'package:luminous/features/legal/domain/entities/doc_type.dart';
export 'package:luminous/features/legal/domain/entities/document.dart';
export 'package:luminous/features/legal/domain/repositories/documents.dart';
export 'package:luminous/features/record/domain/entities/inputs.dart'
    show dailyRecordNoChange;
export 'package:luminous/features/record/domain/entities/record.dart'
    show DailyRecordKind;
export 'package:luminous/features/report/data/providers/report.dart'
    show reportRepositoryProvider;
export 'package:luminous/features/settings/domain/services/notification_permission.dart';
export 'package:shared_preferences/shared_preferences.dart';

export '../../test/helpers/feature_mocks.dart' show MockReportRepository;

Future<ProviderContainer> pumpOfflineApp(
  WidgetTester tester, {
  AuthSessionNotifier Function()? authSessionOverride,
  AuthRepository? authRepository,
  HealthContextRepository? healthContextRepository,
  HealthEventRepository? healthEventRepository,
  MedicineRiskCheckRepository? medicineRiskCheckRepository,
  NotificationPermissionService? notificationPermissionService,
  DailyRecordRepository? dailyRecordRepository,
  RecordRepository? recordRepository,
  ReportRepository? reportRepository,
  ReviewRepository? reviewRepository,
  MedicineWorkspaceRepository? medicineWorkspaceRepository,
  DoseLogRemoteDataSource? doseLogRemoteDataSource,
  LegalRepository? legalRepository,
}) async {
  SharedPreferences.setMockInitialValues(const <String, Object>{});
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  await prefs.setString('app.locale', 'zh-CN');
  final sessionStore = _MemorySessionStore();
  final container = ProviderContainer(
    overrides: [
      authSessionProvider.overrideWith(
        authSessionOverride ?? _NoopRestoreAuthSessionNotifier.new,
      ),
      lucentBaseUrlProvider.overrideWithValue('http://localhost'),
      lucentSessionStoreProvider.overrideWithValue(sessionStore),
      // Override the Dio client to clear interceptors on disposal. This
      // prevents UnmountedRefException (AuthInterceptor using a disposed
      // ref) when the ProviderContainer is disposed between tests.
      lucentDioClientProvider.overrideWith((ref) {
        final client = LucentDioClient(
          baseUrl: 'http://localhost',
          sessionStore: sessionStore,
          localeResolver: () => 'zh-CN',
        );
        ref.onDispose(() {
          client.dio.interceptors.clear();
        });
        return client;
      }),
      notificationUnreadCountProvider.overrideWith((ref) => Future.value(0)),
      if (authRepository != null)
        authRepositoryProvider.overrideWithValue(authRepository),
      if (healthContextRepository != null) ...[
        healthContextRepositoryProvider.overrideWithValue(
          healthContextRepository,
        ),
        healthContextSnapshotProvider.overrideWith(
          (ref) async => healthContextRepository.fetchHealthContext(),
        ),
      ] else ...[
        healthContextSnapshotProvider.overrideWith(
          (ref) => Future.value(_emptyHealthContextSnapshot),
        ),
      ],
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
      if (healthEventRepository != null)
        healthEventRepositoryProvider.overrideWithValue(healthEventRepository),
      if (reviewRepository != null)
        reviewRepositoryProvider.overrideWithValue(reviewRepository),
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
      if (legalRepository != null)
        legalRepositoryProvider.overrideWithValue(legalRepository),
    ],
  );
  addTearDown(container.dispose);

  container.read(appRouterProvider).go('/');

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const LuminousApp()),
  );

  await settleE2e(tester);
  return container;
}

Future<void> settleE2e(
  WidgetTester tester, {
  Duration duration = const Duration(milliseconds: 100),
  int frames = 6,
}) async {
  for (var i = 0; i < frames; i += 1) {
    await tester.pump(duration);
  }
}

Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 5),
  Duration step = const Duration(milliseconds: 100),
}) async {
  final endTime = tester.binding.clock.fromNowBy(timeout);

  do {
    await tester.pump(step);
    if (tester.any(finder)) {
      return;
    }
  } while (tester.binding.clock.now().isBefore(endTime));

  fail('Timed out waiting for $finder');
}

Future<void> openTab(WidgetTester tester, String label) async {
  final shellTab = _shellTabForLabel(label);
  if (shellTab != null) {
    await openShellTab(tester, shellTab);
    return;
  }

  final tab = find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );
  await tester.tap(tab);
  await settleE2e(tester);
}

Future<void> openShellTab(
  WidgetTester tester,
  ShellTab tab, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final tabFinder = find.byKey(tab.testKey());
  await pumpUntilFound(tester, tabFinder, timeout: timeout);
  await tester.ensureVisible(tabFinder);
  await settleE2e(tester);
  await tester.tap(tabFinder);
  await settleE2e(tester);
}

Future<void> openSettings(WidgetTester tester) async {
  await openShellTab(tester, ShellTab.mine);
  await tester.tap(find.byKey(const Key('mine-settings-action')));
  await settleE2e(tester);
  expect(find.text('设置'), findsWidgets);
}

Future<void> tapSettingsFooterAction(WidgetTester tester) async {
  await tapVisible(tester, find.byKey(const Key('settings-footer-action')));
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await pumpUntilFound(tester, finder);
  await tester.ensureVisible(finder);
  await settleE2e(tester);
  await tester.tap(finder);
  await settleE2e(tester);
}

Future<void> openLoginFromSignedOutMine(WidgetTester tester) async {
  await openShellTab(tester, ShellTab.mine);

  final loginAction = find.byKey(const Key('mine-readiness-action'));
  await tapVisible(tester, loginAction);

  expect(find.text('邮箱'), findsWidgets);
  expect(find.widgetWithText(FButton, '登录'), findsOneWidget);
}

Future<void> tapMedicineDoseAction(WidgetTester tester, String label) async {
  final actionKey = switch (label) {
    '跳过' || 'Skipped' => 'medicine-plan-dose-action-skipped',
    _ => 'medicine-plan-dose-action-taken',
  };
  final action = find.byKey(Key(actionKey));
  await pumpUntilFound(tester, action);
  await tester.ensureVisible(action);
  await settleE2e(tester);
  await tester.tap(action);
  await settleE2e(tester);
}

String todayDateString() {
  final today = DateTime.now();
  return '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
}

Finder switchIn(Finder parent) {
  return find.descendant(of: parent, matching: find.byType(Switch)).first;
}

bool readSwitchValue(WidgetTester tester, Finder finder) {
  final switchFinder = finder.evaluate().first.widget is Switch
      ? finder
      : find.descendant(of: finder, matching: find.byType(Switch)).first;
  return tester.widget<Switch>(switchFinder).value;
}

Future<void> openMineProfileEntry(WidgetTester tester, String label) async {
  await openShellTab(tester, ShellTab.mine);
  final archiveSection = find.byKey(const Key('mine-archive-section'));
  await pumpUntilFound(tester, archiveSection);
  expect(archiveSection, findsOneWidget);

  final entry = find.descendant(of: archiveSection, matching: find.text(label));
  await tapVisible(tester, entry);
}

ShellTab? _shellTabForLabel(String label) {
  return switch (label.trim().toLowerCase()) {
    'today' || '今天' || '今日' => ShellTab.today,
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

class E2eLucentAuthRepository extends LucentAuthRepository {
  E2eLucentAuthRepository()
    : super(
        LucentClient(
          LucentApi(dio: Dio(BaseOptions(baseUrl: 'http://localhost'))),
        ),
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
  Future<VerificationCooldown> sendVerificationCode({
    required String email,
    required AuthVerificationScene scene,
  }) async {
    sentCodeEmail = email;
    sentCodeScene = scene;
    return const VerificationCooldown(message: 'sent', cooldownSeconds: 60);
  }

  @override
  Future<VerificationCooldown> forgotPassword({required String email}) async {
    forgotPasswordEmail = email;
    return const VerificationCooldown(message: 'sent', cooldownSeconds: 60);
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
  Future<MedicineRiskCheckRecords> getRecords() async {
    return const MedicineRiskCheckRecords();
  }

  @override
  Future<MedicineRiskCheckRecord> runCheck(MedicineRiskCheckType type) async {
    return MedicineRiskCheckRecord(
      checkType: type,
      result: const MedicineRiskCheckResult(
        currentMedicineCount: 0,
        checkedMedicineCount: 0,
        findings: [],
        coverageIssues: [],
      ),
      riskScore: 0,
      riskLevel: MedicineRiskLevel.safe,
      stale: false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  @override
  Future<MedicineRiskCheckResult> runPrecheck({
    required String source,
    required String sourceRefId,
  }) async {
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
    return const DailyRecordListData(items: [_record], total: 1);
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

  static const _record = DailyRecordItem(
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
  String? markCurrentMedicineId;
  String? markStatus;
  String? markDate;

  /// 已写入的剂量条目（按 scheduledFor 日期留存），供
  /// [fetchForDate] 返回——CachedDoseLogDataSource.mark 成功后经
  /// `_refreshCache` 调 fetchForDate，若不覆盖会走真实 HTTP（DioException
  /// → 幻影 pending-sync 条目 + 失败 toast 噪声）。
  final List<DoseLogItem> _itemsByDate = [];

  Future<DoseLogItem> markForDate(
    String currentMedicineId,
    String status,
    String date,
  ) async {
    return create(currentMedicineId, status, date);
  }

  @override
  Future<List<DoseLogItem>> fetchForDate(String date) async {
    return _itemsByDate
        .where((item) => item.scheduledFor == date)
        .toList(growable: false);
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
    final item = _item(currentMedicineId, status, date);
    _itemsByDate.add(item);
    return item;
  }

  @override
  Future<DoseLogItem> mark({
    required String currentMedicineId,
    required String status,
    required String date,
    String? reminderId,
    String? scheduledTime,
  }) async {
    markCurrentMedicineId = currentMedicineId;
    markStatus = status;
    markDate = date;
    final item = _item(currentMedicineId, status, date);
    _itemsByDate.add(item);
    return item;
  }

  DoseLogItem _item(String currentMedicineId, String status, String date) {
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
    weightKg: null,
    bloodType: null,
    locale: null,
    timezone: null,
    unitSystem: null,
    onboardingCompletedAt: null,
    emergencyContactName: null,
    emergencyContactPhone: null,
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

/// E2E mock for [LegalRepository] that returns test data.
class E2eLegalRepository implements LegalRepository {
  E2eLegalRepository();

  @override
  Future<List<LegalDocumentSummary>> findAll() async {
    return const [
      LegalDocumentSummary(
        docType: LegalDocType.terms,
        title: 'E2E 服务条款',
        updatedAt: '2026-07-01',
      ),
      LegalDocumentSummary(
        docType: LegalDocType.privacy,
        title: 'E2E 隐私政策',
        updatedAt: '2026-07-02',
      ),
      LegalDocumentSummary(
        docType: LegalDocType.disclaimer,
        title: 'E2E 免责声明',
        updatedAt: '2026-07-03',
      ),
    ];
  }

  @override
  Future<LegalDocument> findOne(LegalDocType docType) async {
    return LegalDocument(
      docType: docType,
      title: 'E2E ${docType.pathSegment}',
      content: '# E2E ${docType.pathSegment}\n\nThis is a test document.',
      updatedAt: '2026-07-01',
    );
  }
}

/// Enhanced health context repository that returns a snapshot with existing
/// items, so edit pages can prefill fields.
class E2eHealthContextRepositoryWithItems implements HealthContextRepository {
  E2eHealthContextRepositoryWithItems();

  HealthProfileUpdateInput? profileUpdate;
  HealthAllergyUpdateInput? allergyUpdate;
  String? allergyDeleteId;
  HealthConditionUpdateInput? conditionUpdate;
  String? conditionDeleteId;
  CurrentMedicineUpdateInput? medicineUpdate;
  String? medicineDeleteId;

  @override
  Future<HealthContextSnapshot> fetchHealthContext() async {
    return _snapshotWithItems;
  }

  @override
  Future<HealthContextSnapshot> updateProfile(
    HealthProfileUpdateInput input,
  ) async {
    profileUpdate = input;
    return _snapshotWithItems;
  }

  @override
  Future<HealthContextSnapshot> createAllergy(
    HealthAllergyWriteInput input,
  ) async {
    return _snapshotWithItems;
  }

  @override
  Future<HealthContextSnapshot> updateAllergy(
    String id,
    HealthAllergyUpdateInput input,
  ) async {
    allergyUpdate = input;
    return _snapshotWithItems;
  }

  @override
  Future<HealthContextSnapshot> deleteAllergy(String id) async {
    allergyDeleteId = id;
    return _snapshotWithItems;
  }

  @override
  Future<HealthContextSnapshot> createCondition(
    HealthConditionWriteInput input,
  ) async {
    return _snapshotWithItems;
  }

  @override
  Future<HealthContextSnapshot> updateCondition(
    String id,
    HealthConditionUpdateInput input,
  ) async {
    conditionUpdate = input;
    return _snapshotWithItems;
  }

  @override
  Future<HealthContextSnapshot> deleteCondition(String id) async {
    conditionDeleteId = id;
    return _snapshotWithItems;
  }

  @override
  Future<HealthContextSnapshot> createCurrentMedicine(
    CurrentMedicineWriteInput input,
  ) async {
    return _snapshotWithItems;
  }

  @override
  Future<HealthContextSnapshot> updateCurrentMedicine(
    String id,
    CurrentMedicineUpdateInput input,
  ) async {
    medicineUpdate = input;
    return _snapshotWithItems;
  }

  @override
  Future<HealthContextSnapshot> deleteCurrentMedicine(String id) async {
    medicineDeleteId = id;
    return _snapshotWithItems;
  }
}

const _snapshotWithItems = HealthContextSnapshot(
  summary: HealthSummary(
    age: 28,
    onboardingCompleted: true,
    activeAllergyCount: 1,
    conditionCount: 1,
    currentMedicineCount: 1,
    missingCoreProfileFields: <String>[],
  ),
  profile: HealthProfile(
    birthDate: '1998-06-07',
    sexAtBirth: 'male',
    heightCm: 171,
    weightKg: null,
    bloodType: 'AB',
    locale: 'zh-CN',
    timezone: 'Asia/Shanghai',
    unitSystem: 'metric',
    onboardingCompletedAt: '2026-06-06T00:00:00Z',
    emergencyContactName: null,
    emergencyContactPhone: null,
    extras: <String, dynamic>{},
  ),
  allergies: <AllergyItem>[
    AllergyItem(
      id: 'e2e-allergy-1',
      kind: 'drug',
      label: 'E2E Penicillin',
      reaction: 'rash',
      severity: 'moderate',
      isActive: true,
      note: 'test note',
      createdAt: '2026-06-01T00:00:00Z',
      updatedAt: '2026-06-01T00:00:00Z',
    ),
  ],
  conditions: <ConditionItem>[
    ConditionItem(
      id: 'e2e-condition-1',
      label: 'E2E Asthma',
      status: 'active',
      diagnosedAt: '2020-01-01',
      resolvedAt: null,
      note: 'chronic condition',
      createdAt: '2026-06-01T00:00:00Z',
      updatedAt: '2026-06-01T00:00:00Z',
    ),
  ],
  currentMedicines: <CurrentMedicineItem>[
    CurrentMedicineItem(
      id: 'e2e-medicine-1',
      source: 'manual',
      sourceRefId: null,
      displayName: 'E2E Ibuprofen',
      strengthText: '200mg',
      doseText: '1 tablet',
      route: 'oral',
      startedAt: '2026-01-01',
      endedAt: null,
      isCurrent: true,
      note: 'as needed',
      createdAt: '2026-06-01T00:00:00Z',
      updatedAt: '2026-06-01T00:00:00Z',
    ),
  ],
);

/// Test-only fake [ReviewRepository]：离线 e2e 报告 Tab 数据源。
///
/// `current` / `page` 可变，测试内可先置空（no-event）再置入事件（active /
/// ended）验证 Review 首屏各状态；不连接真实后端。
class E2eReviewRepository implements ReviewRepository {
  E2eReviewRepository({this.current, this.page});

  EventReview? current;
  ReviewEventPage? page;

  int currentCalls = 0;
  int historyCalls = 0;

  @override
  Future<EventReview?> fetchCurrentReview() async {
    currentCalls += 1;
    return current;
  }

  @override
  Future<ReviewEventPage> fetchHistory({
    ReviewEventStatus? status,
    String? cursor,
    int limit = 20,
  }) async {
    historyCalls += 1;
    final items = page?.items ?? const <ReviewEvent>[];
    return ReviewEventPage(
      items: status == null
          ? items
          : items.where((event) => event.status == status).toList(),
      total: status == null ? (page?.total ?? 0) : items.length,
    );
  }

  @override
  Future<EventReview> fetchReview(String eventId) async {
    throw UnimplementedError('e2e 不需要事件详情回顾');
  }
}
