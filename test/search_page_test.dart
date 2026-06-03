import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_write_inputs.dart';
import 'package:luminous/features/health_context/domain/repositories/health_context_repository.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_workspace.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_workspace_provider.dart';
import 'package:luminous/features/search/data/repositories/lucent_repository.dart';
import 'package:luminous/features/search/data/repositories/mock/mock_repository.dart';
import 'package:luminous/features/search/presentation/pages/search_page.dart';
import 'package:luminous/l10n/app_localizations.dart';

import 'auth_test_helpers.dart';

void main() {
  testWidgets('Medicine search page renders search interface', (tester) async {
    await _pumpSearchApp(tester);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('搜索药品'), findsOneWidget);
    expect(
      find.text('搜索药品、成分、疾病、症状...'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField), '布洛芬');
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('布洛芬片'), findsOneWidget);
  });

  testWidgets('add to current medicines routes signed-out user to login', (
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

    expect(find.text('login-page'), findsOneWidget);
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
    expect(input.sourceRefId, 'cn_ibuprofen_1');
    expect(input.displayName, '布洛芬片');
    expect(workspaceBuildCount, greaterThan(1));
  });
}

Future<void> _pumpSearchApp(
  WidgetTester tester, {
  GoRouter? router,
  List overrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        medicineSearchRepositoryProvider
            .overrideWith((ref) => const MockMedicineSearchRepository()),
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
        builder: (context, state) => const Scaffold(body: Text('login-page')),
      ),
    ],
  );
}

Future<void> _searchForIbuprofen(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.enterText(find.byType(TextField), '布洛芬');
  await tester.pump(const Duration(milliseconds: 500));
  expect(find.text('布洛芬片'), findsOneWidget);
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
