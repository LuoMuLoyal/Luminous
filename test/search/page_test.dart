import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/core/widgets/common/back_button.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:luminous/features/health_context/domain/repositories/snapshot.dart';
import 'package:luminous/features/medicine/data/repositories/risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';
import 'package:luminous/features/medicine/domain/repositories/risk_check.dart';
import 'package:luminous/features/medicine/presentation/providers/workspace.dart';
import 'package:luminous/features/search/data/repositories/lucent.dart';
import 'package:luminous/features/search/domain/entities/entities.dart';
import 'package:luminous/features/search/domain/repositories/search.dart';
import 'package:luminous/features/search/presentation/pages/page.dart';
import 'package:luminous/features/search/presentation/widgets/views/view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/test_helpers.dart';

void main() {
  testWidgets('Medicine search page shows back button on mobile', (
    tester,
  ) async {
    await _pumpSearchApp(tester);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(AppBackButton), findsOneWidget);
  });

  testWidgets('Medicine search page renders search interface', (tester) async {
    await _pumpSearchApp(tester);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('搜索药品'), findsOneWidget);
    expect(find.text('搜索药品、成分、疾病、症状...'), findsOneWidget);

    await tester.enterText(find.byType(FTextField), '布洛芬');
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('[DEMO] 布洛芬片'), findsOneWidget);
  });

  testWidgets('add to current medicines shows login dialog when signed out', (
    tester,
  ) async {
    final fakeRepo = _FakeHealthContextRepository();
    final router = _searchRouter();

    await _pumpSearchApp(
      tester,
      router: router,
      overrides: [
        authSessionProvider.overrideWith(() => _SignedOutAuthSessionNotifier()),
        healthContextRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );

    await _searchForIbuprofen(tester);
    await tester.tap(find.text('加入药箱').first);
    await tester.pumpAndSettle();

    expect(find.byType(SearchPage), findsOneWidget);
    expect(find.byKey(const Key('auth-required-dialog')), findsOneWidget);
    expect(find.text('尚未登录'), findsOneWidget);
    expect(find.text('是否去登录'), findsOneWidget);
    expect(find.text('login-page:/medicine/search'), findsNothing);
    expect(fakeRepo.createdCurrentMedicine, isNull);

    await tester.tap(find.byKey(const Key('auth-required-cancel-action')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('auth-required-dialog')), findsNothing);
    expect(find.byType(SearchPage), findsOneWidget);

    await tester.tap(find.text('加入药箱').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('auth-required-login-action')));
    await tester.pumpAndSettle();

    expect(find.text('login-page:/medicine/search'), findsOneWidget);
    expect(fakeRepo.createdCurrentMedicine, isNull);
  });

  testWidgets('add to current medicines writes signed-in result', (
    tester,
  ) async {
    final fakeRepo = _FakeHealthContextRepository();
    var workspaceBuildCount = 0;

    await _pumpSearchApp(
      tester,
      router: _searchRouter(watchWorkspace: true),
      overrides: [
        authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
        healthContextRepositoryProvider.overrideWithValue(fakeRepo),
        medicineRiskCheckRepositoryProvider.overrideWithValue(
          _FakeMedicineRiskCheckRepository(_clearRiskCheckResult),
        ),
        medicineWorkspaceProvider.overrideWith((ref) async {
          ref.watch(
            dataChangeVersionProvider(DataChangeTopic.currentMedicines),
          );
          workspaceBuildCount += 1;
          return _workspace;
        }),
      ],
    );

    await _searchForIbuprofen(tester);
    await tester.tap(find.text('加入药箱').first);
    await tester.pump(const Duration(seconds: 2));

    final input = fakeRepo.createdCurrentMedicine;
    expect(input, isNotNull);
    expect(input!.source, HealthMedicineSource.cn);
    expect(input.sourceRefId, '__mock_cn_ibuprofen__');
    expect(input.displayName, '[DEMO] 布洛芬片');
    expect(workspaceBuildCount, greaterThan(1));
  });

  testWidgets('search shows no-result tools when query returns empty', (
    tester,
  ) async {
    final emptyRepo = _EmptySearchRepository();

    await _pumpSearchApp(tester, medicineSearchRepository: emptyRepo);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.enterText(find.byType(FTextField), 'empty');
    await tester.pump(const Duration(seconds: 1));

    // No results — show the "no result" suggestions
    expect(find.text('无结果？'), findsOneWidget);
    expect(find.text('检查关键词'), findsOneWidget);
    expect(find.text('拍照或扫码'), findsNothing);
  });

  testWidgets('search result shows source reference ID', (tester) async {
    await _pumpSearchApp(tester);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.enterText(find.byType(FTextField), '布洛芬');
    await tester.pump(const Duration(seconds: 1));

    // CN result should show approval number
    expect(find.textContaining('批准文号'), findsWidgets);

    // Switch to DrugBank and search
    await tester.tap(find.text('药物知识（DrugBank）').first);
    await tester.pump(const Duration(seconds: 1));

    // DrugBank result should show DrugBank ID
    expect(find.textContaining('DrugBank'), findsOneWidget);
  });

  testWidgets('search shows error view when search fails', (tester) async {
    final errorRepo = _ErrorSearchRepository();

    await _pumpSearchApp(tester, medicineSearchRepository: errorRepo);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.enterText(find.byType(FTextField), 'error test');
    await tester.pump(const Duration(seconds: 2));

    // Error view should appear
    expect(find.text('搜索页暂时没有加载出来'), findsOneWidget);
  });

  testWidgets(
    'source switch searches selected source and writes result source',
    (tester) async {
      final fakeSearchRepo = _SourceAwareSearchRepository();
      final fakeHealthRepo = _FakeHealthContextRepository();

      await _pumpSearchApp(
        tester,
        medicineSearchRepository: fakeSearchRepo,
        overrides: [
          authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
          healthContextRepositoryProvider.overrideWithValue(fakeHealthRepo),
          medicineRiskCheckRepositoryProvider.overrideWithValue(
            _FakeMedicineRiskCheckRepository(_clearRiskCheckResult),
          ),
        ],
      );

      await _searchForIbuprofen(tester);
      expect(fakeSearchRepo.searchSources, [MedicineSearchSource.cn]);

      await tester.tap(find.text('药物知识（DrugBank）').first);
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Ibuprofen'), findsOneWidget);
      expect(fakeSearchRepo.searchSources, [
        MedicineSearchSource.cn,
        MedicineSearchSource.drugbank,
      ]);

      await tester.tap(find.text('加入药箱').first);
      await tester.pump(const Duration(seconds: 2));

      final input = fakeHealthRepo.createdCurrentMedicine;
      expect(input, isNotNull);
      expect(input!.source, HealthMedicineSource.drugbank);
      expect(input.sourceRefId, 'DB01050');
      expect(input.displayName, 'Ibuprofen');
    },
  );

  testWidgets('add to current medicines shows precheck sheet before save', (
    tester,
  ) async {
    final fakeRepo = _FakeHealthContextRepository();
    final riskCheckRepo = _FakeMedicineRiskCheckRepository(
      const MedicineRiskCheckResult(
        currentMedicineCount: 1,
        checkedMedicineCount: 1,
        findings: [
          MedicineRiskFinding(
            type: MedicineRiskFindingType.interaction,
            severity: MedicineRiskSeverity.high,
            context: MedicineRiskFindingContext.none,
            primaryMedicineName: '[DEMO] 布洛芬片',
            secondaryMedicineName: '正在服用药物',
          ),
        ],
        coverageIssues: [],
      ),
    );

    await _pumpSearchApp(
      tester,
      overrides: [
        authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
        healthContextRepositoryProvider.overrideWithValue(fakeRepo),
        medicineRiskCheckRepositoryProvider.overrideWithValue(riskCheckRepo),
      ],
    );

    await _searchForIbuprofen(tester);
    await tester.tap(find.text('加入药箱').first);
    await tester.pumpAndSettle();

    // The pre-check runs against the candidate medicine about to be added.
    expect(riskCheckRepo.lastPrecheck, (
      source: 'cn',
      sourceRefId: '__mock_cn_ibuprofen__',
    ));
    expect(find.text('添加前风险检查'), findsOneWidget);
    expect(fakeRepo.createdCurrentMedicine, isNull);

    await tester.tap(find.byKey(const Key('medicine-search-precheck-confirm')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));

    expect(fakeRepo.createdCurrentMedicine, isNotNull);
  });

  testWidgets('add to current medicines skips precheck sheet when clear', (
    tester,
  ) async {
    final fakeRepo = _FakeHealthContextRepository();
    final riskCheckRepo = _FakeMedicineRiskCheckRepository(
      const MedicineRiskCheckResult(
        currentMedicineCount: 1,
        checkedMedicineCount: 1,
        findings: [],
        coverageIssues: [],
      ),
    );

    await _pumpSearchApp(
      tester,
      overrides: [
        authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
        healthContextRepositoryProvider.overrideWithValue(fakeRepo),
        medicineRiskCheckRepositoryProvider.overrideWithValue(riskCheckRepo),
      ],
    );

    await _searchForIbuprofen(tester);
    await tester.tap(find.text('加入药箱').first);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));

    expect(riskCheckRepo.lastPrecheck, isNotNull);
    expect(find.text('添加前风险检查'), findsNothing);
    expect(fakeRepo.createdCurrentMedicine, isNotNull);
  });

  testWidgets('add to current medicines continues without precheck dialog when '
      'precheck fails', (tester) async {
    final fakeRepo = _FakeHealthContextRepository();
    final createGate = Completer<void>();
    fakeRepo.createGate = createGate;
    fakeRepo.reflectCreatedMedicine = true;

    await _pumpSearchApp(
      tester,
      overrides: [
        authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
        healthContextRepositoryProvider.overrideWithValue(fakeRepo),
        medicineRiskCheckRepositoryProvider.overrideWithValue(
          _FakeMedicineRiskCheckRepository(
            _clearRiskCheckResult,
            failPrecheck: true,
          ),
        ),
      ],
    );

    await _searchForIbuprofen(tester);
    await tester.tap(find.text('加入药箱').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Pre-check failure must not block adding: no precheck dialog, but an
    // honest "review it later" toast while the add is still pending.
    expect(find.text('添加前风险检查'), findsNothing);
    expect(find.text('暂无法即时检查该药品，加入后可在风险检查中查看'), findsOneWidget);
    expect(fakeRepo.createdCurrentMedicine, isNull);

    // Let the add finish: success toast replaces the unavailable hint.
    createGate.complete();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(fakeRepo.createdCurrentMedicine, isNotNull);
    expect(find.text('已加入药箱'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('search shows loading skeleton while results load', (
    tester,
  ) async {
    final pending = Completer<List<MedicineSearchResult>>();
    final hangingRepo = _HangingSearchRepository(pending);

    await _pumpSearchApp(tester, medicineSearchRepository: hangingRepo);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.enterText(find.byType(FTextField), '布洛芬');
    await tester.pump(const Duration(milliseconds: 500));

    // Loading skeleton should appear while search is pending
    expect(find.byType(MedicineSearchLoadingView), findsOneWidget);
    // Real results should NOT be visible
    expect(find.text('[DEMO] 布洛芬片'), findsNothing);

    // Complete the search
    pending.complete(const [
      MedicineSearchResult(
        id: 'ibuprofen',
        source: MedicineSearchSource.cn,
        name: '[DEMO] 布洛芬片',
        subtitle: '',
        summary: '',
        tags: [],
        matchType: MedicineSearchMatchType.name,
      ),
    ]);
    await tester.pumpAndSettle();

    // After loading completes, skeleton gone and results appear
    expect(find.byType(MedicineSearchLoadingView), findsNothing);
    expect(find.text('[DEMO] 布洛芬片'), findsOneWidget);
  });
}

Future<void> _pumpSearchApp(
  WidgetTester tester, {
  GoRouter? router,
  MedicineSearchRepository medicineSearchRepository =
      const _MockMedicineSearchRepository(),
  List overrides = const [],
}) async {
  // The page watches the persisted recent-searches provider, which is backed
  // by SharedPreferences.
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        medicineSearchRepositoryProvider.overrideWith(
          (ref) => medicineSearchRepository,
        ),
        ...overrides,
      ],
      child: TestAuthApp(router: router ?? _searchRouter()),
    ),
  );
}

GoRouter _searchRouter({bool watchWorkspace = false}) {
  return GoRouter(
    initialLocation: '/medicine/search',
    routes: [
      GoRoute(
        path: '/medicine/search',
        builder: (context, state) => FToaster(
          // Toasts (precheck unavailable / added-to-box) need an FToaster
          // above the page, mirroring the production bootstrap.
          child: watchWorkspace
              ? Stack(
                  children: [
                    const SearchPage(),
                    Consumer(
                      builder: (context, ref, child) {
                        ref.watch(medicineWorkspaceProvider);
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                )
              : const SearchPage(),
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => Scaffold(
          body: Text("login-page:${state.uri.queryParameters['return-to']}"),
        ),
      ),
    ],
  );
}

Future<void> _searchForIbuprofen(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.enterText(find.byType(FTextField), '布洛芬');
  await tester.pump(const Duration(milliseconds: 500));
  expect(find.text('[DEMO] 布洛芬片'), findsOneWidget);
}

class _SignedOutAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return const AuthSessionState(isAuthenticated: false, isLoading: false);
  }
}

class _FakeHealthContextRepository implements HealthContextRepository {
  CurrentMedicineWriteInput? createdCurrentMedicine;

  /// When set, [createCurrentMedicine] suspends until the completer completes.
  /// Lets tests observe pre-create UI (e.g. the precheck-unavailable toast).
  Completer<void>? createGate;

  /// When true, [createCurrentMedicine] returns a snapshot that contains the
  /// newly created medicine, so the page's success toast can render.
  bool reflectCreatedMedicine = false;

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> fetchHealthContext() =>
      TaskEither.right(_snapshot);

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> updateProfile(
    HealthProfileUpdateInput input,
  ) => TaskEither.right(_snapshot);

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> createAllergy(
    HealthAllergyWriteInput input,
  ) => TaskEither.right(_snapshot);

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> updateAllergy(
    String id,
    HealthAllergyUpdateInput input,
  ) => TaskEither.right(_snapshot);

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> deleteAllergy(String id) =>
      TaskEither.right(_snapshot);

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> createCondition(
    HealthConditionWriteInput input,
  ) => TaskEither.right(_snapshot);

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> updateCondition(
    String id,
    HealthConditionUpdateInput input,
  ) => TaskEither.right(_snapshot);

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> deleteCondition(String id) =>
      TaskEither.right(_snapshot);

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> createCurrentMedicine(
    CurrentMedicineWriteInput input,
  ) {
    return TaskEither(() async {
      final gate = createGate;
      if (gate != null) {
        await gate.future;
      }
      createdCurrentMedicine = input;
      if (reflectCreatedMedicine) {
        return Right(
          _snapshot.copyWith(
            currentMedicines: [
              CurrentMedicineItem(
                id: 'created-medicine-1',
                source: input.source.name,
                sourceRefId: input.sourceRefId,
                displayName: input.displayName,
                strengthText: null,
                doseText: null,
                route: null,
                startedAt: null,
                endedAt: null,
                isCurrent: true,
                note: null,
                createdAt: '2026-08-16T00:00:00.000Z',
                updatedAt: '2026-08-16T00:00:00.000Z',
              ),
            ],
          ),
        );
      }
      return const Right(_snapshot);
    });
  }

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> updateCurrentMedicine(
    String id,
    CurrentMedicineUpdateInput input,
  ) => TaskEither.right(_snapshot);

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> deleteCurrentMedicine(
    String id,
  ) => TaskEither.right(_snapshot);
}

class _SourceAwareSearchRepository implements MedicineSearchRepository {
  final searchSources = <MedicineSearchSource>[];

  @override
  Future<List<MedicineSearchResult>> search({
    required String query,
    required MedicineSearchSource source,
    int page = 1,
    int pageSize = 20,
  }) async {
    searchSources.add(source);
    if (source == MedicineSearchSource.drugbank) {
      return const [
        MedicineSearchResult(
          id: 'DB01050',
          source: MedicineSearchSource.drugbank,
          name: 'Ibuprofen',
          subtitle: 'Small molecule',
          summary: 'A nonsteroidal anti-inflammatory drug.',
          tags: <String>['approved', 'anti-inflammatory'],
          matchType: MedicineSearchMatchType.name,
        ),
      ];
    }

    return const [
      MedicineSearchResult(
        id: '__mock_cn_ibuprofen__',
        source: MedicineSearchSource.cn,
        name: '[DEMO] 布洛芬片',
        subtitle: '0.2g*12片 · 石药集团欧意药业有限公司',
        summary: '用于缓解轻至中度疼痛。',
        tags: <String>['解热镇痛', '非处方药'],
        matchType: MedicineSearchMatchType.ingredient,
      ),
    ];
  }

  @override
  Future<MedicineSearchSafetyPreview?> fetchDetail(
    String id,
    MedicineSearchSource source,
  ) async {
    return MedicineSearchSafetyPreview(
      title: id,
      conditions: const [],
      checklist: const [],
    );
  }
}

const _snapshot = HealthContextSnapshot(
  summary: HealthSummary(
    age: null,
    onboardingCompleted: false,
    activeAllergyCount: 0,
    conditionCount: 0,
    currentMedicineCount: 0,
    missingCoreProfileFields: [],
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
    extras: {},
  ),
  allergies: [],
  conditions: [],
  currentMedicines: [],
);

class _EmptySearchRepository implements MedicineSearchRepository {
  @override
  Future<List<MedicineSearchResult>> search({
    required String query,
    required MedicineSearchSource source,
    int page = 1,
    int pageSize = 20,
  }) async => const [];

  @override
  Future<MedicineSearchSafetyPreview?> fetchDetail(
    String id,
    MedicineSearchSource source,
  ) async => null;
}

class _ErrorSearchRepository implements MedicineSearchRepository {
  @override
  Future<List<MedicineSearchResult>> search({
    required String query,
    required MedicineSearchSource source,
    int page = 1,
    int pageSize = 20,
  }) async => throw Exception('Search failed');

  @override
  Future<MedicineSearchSafetyPreview?> fetchDetail(
    String id,
    MedicineSearchSource source,
  ) async => throw Exception('Detail failed');
}

class _FakeMedicineRiskCheckRepository implements MedicineRiskCheckRepository {
  _FakeMedicineRiskCheckRepository(this.result, {this.failPrecheck = false});

  final MedicineRiskCheckResult result;

  /// When true, [runPrecheck] throws — simulating an unavailable pre-check.
  final bool failPrecheck;

  /// Records the most recent [runPrecheck] invocation arguments.
  ({String source, String sourceRefId})? lastPrecheck;

  @override
  Future<MedicineRiskCheckResult> runPrecheck({
    required String source,
    required String sourceRefId,
  }) async {
    lastPrecheck = (source: source, sourceRefId: sourceRefId);
    if (failPrecheck) {
      throw Exception('precheck unavailable');
    }
    return result;
  }

  @override
  Future<MedicineRiskCheckRecords> getRecords() async =>
      MedicineRiskCheckRecords(
        staticRecord: MedicineRiskCheckRecord(
          checkType: MedicineRiskCheckType.static_,
          result: result,
          riskScore: 0,
          riskLevel: result.overallRiskLevel,
          stale: false,
          createdAt: DateTime(2026, 7, 27),
          updatedAt: DateTime(2026, 7, 27),
        ),
      );

  @override
  Future<MedicineRiskCheckRecord> runCheck(MedicineRiskCheckType type) async =>
      MedicineRiskCheckRecord(
        checkType: type,
        result: result,
        riskScore: 0,
        riskLevel: result.overallRiskLevel,
        stale: false,
        createdAt: DateTime(2026, 7, 27),
        updatedAt: DateTime(2026, 7, 27),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Repository that hangs on [search] until the completer finishes.
/// Used to test the loading skeleton state.
class _HangingSearchRepository implements MedicineSearchRepository {
  _HangingSearchRepository(this._pending);

  final Completer<List<MedicineSearchResult>> _pending;

  @override
  Future<List<MedicineSearchResult>> search({
    required String query,
    required MedicineSearchSource source,
    int page = 1,
    int pageSize = 20,
  }) => _pending.future;

  @override
  Future<MedicineSearchSafetyPreview?> fetchDetail(
    String id,
    MedicineSearchSource source,
  ) async => null;
}

const _clearRiskCheckResult = MedicineRiskCheckResult(
  currentMedicineCount: 1,
  checkedMedicineCount: 1,
  findings: [],
  coverageIssues: [],
);

const _workspace = MedicineWorkspace(
  hero: MedicineHero(
    metricDosesToday: '0',
    metricAdherence: '--',
    metricNextDose: '--',
  ),
  quickActions: [],
  plan: MedicinePlanSurface(items: []),
  alerts: [],
  promisePoints: [],
);

/// Test-only mock with demo data prefixed to avoid confusion with real data.
class _MockMedicineSearchRepository implements MedicineSearchRepository {
  const _MockMedicineSearchRepository();

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
