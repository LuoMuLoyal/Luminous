import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/features/health_context/data/datasources/health_context_remote_data_source.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_write_inputs.dart';
import 'package:luminous/features/health_context/domain/repositories/health_context_repository.dart';
import 'package:luminous/features/mine/presentation/pages/allergy_edit.dart';
import 'package:luminous/features/mine/presentation/pages/condition_edit.dart';
import 'package:luminous/features/mine/presentation/pages/current_medicine_edit.dart';
import 'package:luminous/features/mine/presentation/pages/profile_edit.dart';
import 'package:luminous/l10n/app_localizations.dart';

void main() {
  // ── Profile ──

  testWidgets('Profile edit saves domain input with explicit null clears', (
    tester,
  ) async {
    final fakeRepo = _FakeHealthContextRepository();

    await tester.pumpWidget(_app(fakeRepo, const ProfileEditPage()));

    await tester.tap(find.text('open-profile-edit'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '1999-02-03');
    await tester.enterText(fields.at(1), '170');
    await tester.enterText(fields.at(2), '');
    await _scrollToSave(tester);
    await tester.tap(find.text('完成新手引导'));
    await tester.pump();
    await _scrollToSave(tester);
    await tester.tap(find.text('保存'));
    await tester.pump(const Duration(seconds: 2));

    final input = fakeRepo.profileUpdate;
    expect(input, isNotNull);
    final payload = healthProfileUpdatePayload(input!);
    expect(payload, containsPair('birthDate', '1999-02-03'));
    expect(payload, containsPair('heightCm', 170));
    expect(payload, containsPair('bloodType', null));
    expect(payload, containsPair('onboardingCompleted', false));
  });

  testWidgets('Profile edit shows login dialog when signed out', (
    tester,
  ) async {
    final fakeRepo = _FakeHealthContextRepository();

    await tester.pumpWidget(
      _app(
        fakeRepo,
        const ProfileEditPage(),
        authSessionNotifier: _SignedOutAuthSessionNotifier.new,
      ),
    );

    await tester.tap(find.text('open-profile-edit'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileEditPage), findsOneWidget);
    expect(find.byKey(const Key('auth-required-dialog')), findsOneWidget);
    expect(find.text('尚未登录'), findsOneWidget);
    expect(find.text('是否去登录'), findsOneWidget);

    await tester.tap(find.byKey(const Key('auth-required-cancel-action')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('auth-required-dialog')), findsNothing);
    expect(find.text('编辑档案'), findsOneWidget);
  });

  // ── Allergy ──

  testWidgets('Allergy create saves with label', (tester) async {
    final fakeRepo = _FakeHealthContextRepository();

    await tester.pumpWidget(_app(fakeRepo, const AllergyEditPage()));

    await tester.tap(find.text('open-profile-edit'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('allergy-label-field')),
      'Penicillin',
    );
    await tester.pump();
    await _scrollToSave(tester);
    await tester.tap(find.byKey(const Key('allergy-save-button')));
    await tester.pump(const Duration(seconds: 2));

    expect(fakeRepo.allergyCreate, isNotNull);
    expect(fakeRepo.allergyCreate!.label, 'Penicillin');
  });

  testWidgets('Allergy create blocks empty label', (tester) async {
    final fakeRepo = _FakeHealthContextRepository();

    await tester.pumpWidget(_app(fakeRepo, const AllergyEditPage()));

    await tester.tap(find.text('open-profile-edit'));
    await tester.pumpAndSettle();

    // Don't fill label
    await _scrollToSave(tester);
    await tester.tap(find.byKey(const Key('allergy-save-button')));
    await tester.pump(const Duration(seconds: 2));

    // Should not have called save
    expect(fakeRepo.allergyCreate, isNull);
  });

  testWidgets('Allergy edit prefills from snapshot by ID', (tester) async {
    final fakeRepo = _FakeHealthContextRepository();

    await tester.pumpWidget(
      _app(
        fakeRepo,
        const AllergyEditPage(allergyId: 'allergy-1'),
        snapshot: _snapshotWithItems,
      ),
    );

    await tester.tap(find.text('open-profile-edit'));
    await tester.pumpAndSettle();

    // Should prefill the label
    expect(find.text('Penicillin'), findsOneWidget);
    // Verify text field has the value
    final field = tester.widget<TextField>(
      find.byKey(const Key('allergy-label-field')),
    );
    expect(field.controller?.text, 'Penicillin');
  });

  testWidgets('Allergy edit delete calls soft-delete', (tester) async {
    final fakeRepo = _FakeHealthContextRepository();

    await tester.pumpWidget(
      _app(
        fakeRepo,
        const AllergyEditPage(allergyId: 'allergy-1'),
        snapshot: _snapshotWithItems,
      ),
    );

    await tester.tap(find.text('open-profile-edit'));
    await tester.pumpAndSettle();

    await _scrollToSave(tester);
    await tester.tap(find.byKey(const Key('allergy-delete-button')));
    await tester.pump(const Duration(seconds: 2));

    expect(fakeRepo.allergyDeleted, 'allergy-1');
  });

  // ── Condition ──

  testWidgets('Condition create saves with label', (tester) async {
    final fakeRepo = _FakeHealthContextRepository();

    await tester.pumpWidget(_app(fakeRepo, const ConditionEditPage()));

    await tester.tap(find.text('open-profile-edit'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('condition-label-field')),
      'Asthma',
    );
    await tester.pump();
    await _scrollToSave(tester);
    await tester.tap(find.byKey(const Key('condition-save-button')));
    await tester.pump(const Duration(seconds: 2));

    expect(fakeRepo.conditionCreate, isNotNull);
    expect(fakeRepo.conditionCreate!.label, 'Asthma');
  });

  testWidgets('Condition create blocks empty label', (tester) async {
    final fakeRepo = _FakeHealthContextRepository();

    await tester.pumpWidget(_app(fakeRepo, const ConditionEditPage()));

    await tester.tap(find.text('open-profile-edit'));
    await tester.pumpAndSettle();

    await _scrollToSave(tester);
    await tester.tap(find.byKey(const Key('condition-save-button')));
    await tester.pump(const Duration(seconds: 2));

    expect(fakeRepo.conditionCreate, isNull);
  });

  testWidgets('Condition delete calls soft-resolve', (tester) async {
    final fakeRepo = _FakeHealthContextRepository();

    await tester.pumpWidget(
      _app(
        fakeRepo,
        const ConditionEditPage(conditionId: 'cond-1'),
        snapshot: _snapshotWithItems,
      ),
    );

    await tester.tap(find.text('open-profile-edit'));
    await tester.pumpAndSettle();

    await _scrollToSave(tester);
    await tester.tap(find.byKey(const Key('condition-delete-button')));
    await tester.pump(const Duration(seconds: 2));

    expect(fakeRepo.conditionDeleted, 'cond-1');
  });

  // ── Current Medicine ──

  testWidgets('Medicine create saves with displayName', (tester) async {
    final fakeRepo = _FakeHealthContextRepository();

    await tester.pumpWidget(_app(fakeRepo, const CurrentMedicineEditPage()));

    await tester.tap(find.text('open-profile-edit'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('medicine-displayname-field')),
      'Ibuprofen',
    );
    await tester.pump();
    await _scrollToSave(tester);
    await tester.tap(find.byKey(const Key('medicine-save-button')));
    await tester.pump(const Duration(seconds: 2));

    expect(fakeRepo.medicineCreate, isNotNull);
    expect(fakeRepo.medicineCreate!.displayName, 'Ibuprofen');
  });

  testWidgets('Medicine create blocks empty displayName', (tester) async {
    final fakeRepo = _FakeHealthContextRepository();

    await tester.pumpWidget(_app(fakeRepo, const CurrentMedicineEditPage()));

    await tester.tap(find.text('open-profile-edit'));
    await tester.pumpAndSettle();

    await _scrollToSave(tester);
    await tester.tap(find.byKey(const Key('medicine-save-button')));
    await tester.pump(const Duration(seconds: 2));

    expect(fakeRepo.medicineCreate, isNull);
  });

  testWidgets('Medicine delete calls soft-delete', (tester) async {
    final fakeRepo = _FakeHealthContextRepository();

    await tester.pumpWidget(
      _app(
        fakeRepo,
        const CurrentMedicineEditPage(medicineId: 'med-1'),
        snapshot: _snapshotWithItems,
      ),
    );

    await tester.tap(find.text('open-profile-edit'));
    await tester.pumpAndSettle();

    await _scrollToSave(tester);
    await tester.tap(find.byKey(const Key('medicine-delete-button')));
    await tester.pump(const Duration(seconds: 2));

    expect(fakeRepo.medicineDeleted, 'med-1');
  });
}

// ── Helpers ──

Future<void> _scrollToSave(WidgetTester tester) async {
  final scrollable = find.byType(Scrollable).first;
  await tester.scrollUntilVisible(find.text('保存'), 220, scrollable: scrollable);
  await tester.pump();
}

Widget _app(
  _FakeHealthContextRepository fakeRepo,
  Widget page, {
  HealthContextSnapshot snapshot = _snapshot,
  AuthSessionNotifier Function()? authSessionNotifier,
}) {
  return ProviderScope(
    overrides: [
      authSessionProvider.overrideWith(
        authSessionNotifier ?? _SignedInAuthSessionNotifier.new,
      ),
      healthContextSnapshotProvider.overrideWith((ref) async => snapshot),
      healthContextRepositoryProvider.overrideWithValue(fakeRepo),
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
      routerConfig: GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: TextButton(
                onPressed: () => context.push('/mine-edit'),
                child: const Text('open-profile-edit'),
              ),
            ),
          ),
          GoRoute(path: '/mine-edit', builder: (context, state) => page),
          GoRoute(
            path: '/login',
            builder: (context, state) =>
                const Scaffold(body: Text('login-page')),
          ),
        ],
      ),
    ),
  );
}

class _SignedInAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return AuthSessionState(
      isAuthenticated: true,
      isLoading: false,
      user: AuthUser(
        id: 'user-1',
        email: 'user@example.com',
        nickname: 'Lumi',
        avatar: null,
        emailVerifiedAt: DateTime.parse('2026-01-01T00:00:00Z'),
        createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2026-01-02T00:00:00Z'),
      ),
    );
  }
}

class _SignedOutAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return const AuthSessionState(isAuthenticated: false, isLoading: false);
  }
}

class _FakeHealthContextRepository implements HealthContextRepository {
  HealthProfileUpdateInput? profileUpdate;
  HealthAllergyWriteInput? allergyCreate;
  HealthAllergyUpdateInput? allergyUpdate;
  String? allergyDeleted;
  HealthConditionWriteInput? conditionCreate;
  HealthConditionUpdateInput? conditionUpdate;
  String? conditionDeleted;
  CurrentMedicineWriteInput? medicineCreate;
  CurrentMedicineUpdateInput? medicineUpdate;
  String? medicineDeleted;

  @override
  Future<HealthContextSnapshot> fetchHealthContext() async => _snapshot;

  @override
  Future<HealthContextSnapshot> updateProfile(
    HealthProfileUpdateInput input,
  ) async {
    profileUpdate = input;
    return _snapshot;
  }

  @override
  Future<HealthContextSnapshot> createAllergy(
    HealthAllergyWriteInput input,
  ) async {
    allergyCreate = input;
    return _snapshot;
  }

  @override
  Future<HealthContextSnapshot> updateAllergy(
    String id,
    HealthAllergyUpdateInput input,
  ) async {
    allergyUpdate = input;
    return _snapshot;
  }

  @override
  Future<HealthContextSnapshot> deleteAllergy(String id) async {
    allergyDeleted = id;
    return _snapshot;
  }

  @override
  Future<HealthContextSnapshot> createCondition(
    HealthConditionWriteInput input,
  ) async {
    conditionCreate = input;
    return _snapshot;
  }

  @override
  Future<HealthContextSnapshot> updateCondition(
    String id,
    HealthConditionUpdateInput input,
  ) async {
    conditionUpdate = input;
    return _snapshot;
  }

  @override
  Future<HealthContextSnapshot> deleteCondition(String id) async {
    conditionDeleted = id;
    return _snapshot;
  }

  @override
  Future<HealthContextSnapshot> createCurrentMedicine(
    CurrentMedicineWriteInput input,
  ) async {
    medicineCreate = input;
    return _snapshot;
  }

  @override
  Future<HealthContextSnapshot> updateCurrentMedicine(
    String id,
    CurrentMedicineUpdateInput input,
  ) async {
    medicineUpdate = input;
    return _snapshot;
  }

  @override
  Future<HealthContextSnapshot> deleteCurrentMedicine(String id) async {
    medicineDeleted = id;
    return _snapshot;
  }
}

const _snapshot = HealthContextSnapshot(
  summary: HealthSummary(
    age: 27,
    onboardingCompleted: true,
    activeAllergyCount: 0,
    conditionCount: 0,
    currentMedicineCount: 0,
    missingCoreProfileFields: [],
  ),
  profile: HealthProfile(
    birthDate: '1999-01-01',
    sexAtBirth: 'female',
    heightCm: 168,
    bloodType: 'O+',
    locale: null,
    timezone: null,
    unitSystem: 'metric',
    onboardingCompletedAt: '2026-01-01T00:00:00.000Z',
    extras: {},
  ),
  allergies: [],
  conditions: [],
  currentMedicines: [],
);

const _snapshotWithItems = HealthContextSnapshot(
  summary: HealthSummary(
    age: 27,
    onboardingCompleted: true,
    activeAllergyCount: 1,
    conditionCount: 1,
    currentMedicineCount: 1,
    missingCoreProfileFields: [],
  ),
  profile: HealthProfile(
    birthDate: '1999-01-01',
    sexAtBirth: 'female',
    heightCm: 168,
    bloodType: 'O+',
    locale: null,
    timezone: null,
    unitSystem: 'metric',
    onboardingCompletedAt: '2026-01-01T00:00:00.000Z',
    extras: {},
  ),
  allergies: [
    AllergyItem(
      id: 'allergy-1',
      label: 'Penicillin',
      kind: 'drug',
      reaction: 'Rash',
      severity: 'moderate',
      isActive: true,
      note: null,
      createdAt: '',
      updatedAt: '',
    ),
  ],
  conditions: [
    ConditionItem(
      id: 'cond-1',
      label: 'Asthma',
      status: 'active',
      diagnosedAt: '2024-02-01',
      resolvedAt: null,
      note: null,
      createdAt: '',
      updatedAt: '',
    ),
  ],
  currentMedicines: [
    CurrentMedicineItem(
      id: 'med-1',
      source: 'drugbank',
      sourceRefId: 'DB01050',
      displayName: 'Ibuprofen',
      strengthText: '200mg',
      doseText: null,
      route: 'oral',
      startedAt: '2026-01-01',
      endedAt: null,
      isCurrent: true,
      note: null,
      createdAt: '',
      updatedAt: '',
    ),
  ],
);
