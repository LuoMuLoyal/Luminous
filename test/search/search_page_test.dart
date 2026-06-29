import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/core/widgets/common/app_back_button.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_write_inputs.dart';
import 'package:luminous/features/health_context/domain/repositories/health_context_repository.dart';
import 'package:luminous/features/medicine/data/repositories/medicine_risk_check_repository.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_workspace.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_workspace_provider.dart';
import 'package:luminous/features/search/data/repositories/lucent_repository.dart';
import 'package:luminous/features/search/data/repositories/mock/mock_repository.dart';
import 'package:luminous/features/search/presentation/pages/search_page.dart';
import 'package:luminous/features/search/domain/entities/search_entities.dart';
import 'package:luminous/features/search/domain/repositories/search_repository.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../auth/auth_test_helpers.dart';

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

    await tester.enterText(find.byType(TextField), '布洛芬');
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
          const _FakeMedicineRiskCheckRepository(_clearRiskCheckResult),
        ),
        medicineWorkspaceProvider.overrideWith((ref) async {
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
    await tester.enterText(find.byType(TextField), 'empty');
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
    await tester.enterText(find.byType(TextField), '布洛芬');
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
    await tester.enterText(find.byType(TextField), 'error test');
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
            const _FakeMedicineRiskCheckRepository(_clearRiskCheckResult),
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

    await _pumpSearchApp(
      tester,
      overrides: [
        authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
        healthContextRepositoryProvider.overrideWithValue(fakeRepo),
        medicineRiskCheckRepositoryProvider.overrideWithValue(
          _FakeMedicineRiskCheckRepository(
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
          ),
        ),
      ],
    );

    await _searchForIbuprofen(tester);
    await tester.tap(find.text('加入药箱').first);
    await tester.pumpAndSettle();

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

    await _pumpSearchApp(
      tester,
      overrides: [
        authSessionProvider.overrideWith(() => SignedInAuthSessionNotifier()),
        healthContextRepositoryProvider.overrideWithValue(fakeRepo),
        medicineRiskCheckRepositoryProvider.overrideWithValue(
          _FakeMedicineRiskCheckRepository(
            const MedicineRiskCheckResult(
              currentMedicineCount: 1,
              checkedMedicineCount: 1,
              findings: [],
              coverageIssues: [],
            ),
          ),
        ),
      ],
    );

    await _searchForIbuprofen(tester);
    await tester.tap(find.text('加入药箱').first);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('添加前风险检查'), findsNothing);
    expect(fakeRepo.createdCurrentMedicine, isNotNull);
  });
}

Future<void> _pumpSearchApp(
  WidgetTester tester, {
  GoRouter? router,
  MedicineSearchRepository medicineSearchRepository =
      const MockMedicineSearchRepository(),
  List overrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        medicineSearchRepositoryProvider.overrideWith(
          (ref) => medicineSearchRepository,
        ),
        ...overrides,
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        locale: const Locale('zh'),
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router ?? _searchRouter(),
      ),
    ),
  );
}

GoRouter _searchRouter({bool watchWorkspace = false}) {
  return GoRouter(
    initialLocation: '/medicine/search',
    routes: [
      GoRoute(
        path: '/medicine/search',
        builder: (context, state) => watchWorkspace
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
      GoRoute(
        path: '/login',
        builder: (context, state) => Scaffold(
          body: Text("login-page:${state.uri.queryParameters['returnTo']}"),
        ),
      ),
    ],
  );
}

Future<void> _searchForIbuprofen(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.enterText(find.byType(TextField), '布洛芬');
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

  @override
  Future<HealthContextSnapshot> fetchHealthContext() async => _snapshot;

  @override
  Future<HealthContextSnapshot> updateProfile(
    HealthProfileUpdateInput input,
  ) async => _snapshot;

  @override
  Future<HealthContextSnapshot> createAllergy(
    HealthAllergyWriteInput input,
  ) async => _snapshot;

  @override
  Future<HealthContextSnapshot> updateAllergy(
    String id,
    HealthAllergyUpdateInput input,
  ) async => _snapshot;

  @override
  Future<HealthContextSnapshot> deleteAllergy(String id) async => _snapshot;

  @override
  Future<HealthContextSnapshot> createCondition(
    HealthConditionWriteInput input,
  ) async => _snapshot;

  @override
  Future<HealthContextSnapshot> updateCondition(
    String id,
    HealthConditionUpdateInput input,
  ) async => _snapshot;

  @override
  Future<HealthContextSnapshot> deleteCondition(String id) async => _snapshot;

  @override
  Future<HealthContextSnapshot> createCurrentMedicine(
    CurrentMedicineWriteInput input,
  ) async {
    createdCurrentMedicine = input;
    return _snapshot;
  }

  @override
  Future<HealthContextSnapshot> updateCurrentMedicine(
    String id,
    CurrentMedicineUpdateInput input,
  ) async => _snapshot;

  @override
  Future<HealthContextSnapshot> deleteCurrentMedicine(String id) async =>
      _snapshot;
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
    pregnancyState: null,
    lactationState: null,
    bloodType: null,
    locale: null,
    timezone: null,
    unitSystem: null,
    onboardingCompletedAt: null,
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
  const _FakeMedicineRiskCheckRepository(this.result);

  final MedicineRiskCheckResult result;

  @override
  Future<MedicineRiskCheckResult> fetchForSnapshot(
    HealthContextSnapshot snapshot,
  ) async => result;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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
