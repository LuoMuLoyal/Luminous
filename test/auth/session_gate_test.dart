import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/core/network/client/session_store.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:luminous/features/health_context/domain/repositories/snapshot.dart';
import 'package:luminous/features/medicine/data/providers/workspace.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';
import 'package:luminous/features/medicine/domain/repositories/workspace.dart';
import 'package:luminous/features/medicine/presentation/providers/workspace.dart';
import 'package:luminous/features/mine/data/providers/mine.dart';
import 'package:luminous/features/mine/domain/entities/dashboard.dart';
import 'package:luminous/features/mine/domain/repositories/profile.dart';
import 'package:luminous/features/mine/presentation/providers/dashboard.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/domain/repositories/record.dart';
import 'package:luminous/features/record/presentation/providers/dashboard.dart';
import 'package:luminous/features/today/data/providers/today_suggestion.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/domain/repositories/dashboard.dart';
import 'package:luminous/features/today/presentation/providers/dashboard.dart';

import '../helpers/feature_mocks.dart';
import '../helpers/test_helpers.dart';

void main() {
  test('restoring auth attempts cache-first fetches (offline-first)', () async {
    final todayRepository = _CountingTodayRepository();
    final medicineRepository = _CountingMedicineWorkspaceRepository();
    final mineRepository = _CountingMineRepository();
    final recordRepository = _CountingRecordRepository();
    final healthRepository = _CountingHealthContextRepository();
    // A returning user has a stored session — the stored-session gate in
    // authGuarded fires the fetch so cache-first repositories return local
    // data immediately instead of keeping the UI in a skeleton.
    final sessionStore = MemorySessionStore()
      ..tokens = const LucentSessionTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      );
    final container = ProviderContainer(
      overrides: [
        lucentSessionStoreProvider.overrideWithValue(sessionStore),
        todayRepositoryProvider.overrideWithValue(todayRepository),
        medicineWorkspaceRepositoryProvider.overrideWithValue(
          medicineRepository,
        ),
        mineRepositoryProvider.overrideWithValue(mineRepository),
        recordRepositoryProvider.overrideWithValue(recordRepository),
        healthContextRepositoryProvider.overrideWithValue(healthRepository),
      ],
    );
    addTearDown(container.dispose);

    // During restore authGuarded now attempts the fetch so cache-first
    // repositories return local data immediately instead of keeping the
    // UI in an indefinite skeleton (offline-first, ADR-0006).
    final today = await container.read(todayDashboardProvider.future);
    final medicine = await container.read(medicineWorkspaceProvider.future);
    final mine = await container.read(mineDashboardProvider.future);
    final record = await container.read(recordDashboardProvider.future);
    final health = await container.read(healthContextSnapshotProvider.future);

    expect(todayRepository.calls, 1);
    expect(medicineRepository.calls, 1);
    expect(mineRepository.calls, 1);
    expect(recordRepository.calls, 1);
    expect(healthRepository.fetchCalls, 1);

    expect(today, isA<TodayDashboard>());
    expect(medicine, isA<MedicineWorkspace>());
    expect(mine, isA<MineDashboard>());
    expect(record, isA<RecordDashboard>());
    expect(health, isA<HealthContextSnapshot>());
  });

  test('signed out dashboard providers use local data only', () async {
    final todayRepository = _CountingTodayRepository();
    final medicineRepository = _CountingMedicineWorkspaceRepository();
    final mineRepository = _CountingMineRepository();
    final recordRepository = _CountingRecordRepository();
    final healthRepository = _CountingHealthContextRepository();
    final container = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(_SignedOutAuthSessionNotifier.new),
        todayRepositoryProvider.overrideWithValue(todayRepository),
        medicineWorkspaceRepositoryProvider.overrideWithValue(
          medicineRepository,
        ),
        mineRepositoryProvider.overrideWithValue(mineRepository),
        recordRepositoryProvider.overrideWithValue(recordRepository),
        healthContextRepositoryProvider.overrideWithValue(healthRepository),
      ],
    );
    addTearDown(container.dispose);

    final today = await container.read(todayDashboardProvider.future);
    final medicine = await container.read(medicineWorkspaceProvider.future);
    final mine = await container.read(mineDashboardProvider.future);
    final record = await container.read(recordDashboardProvider.future);

    expect(today.water.completedCount, 0);
    expect(medicine.plan.items, isNotEmpty);
    expect(mine.account.isAuthenticated, isFalse);
    expect(record.timeline, isNotEmpty);

    // authGuarded is async — trigger the provider, let the error settle on
    // the microtask queue, then verify the provider entered error state.
    container.read(healthContextSnapshotProvider);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final healthState = container.read(healthContextSnapshotProvider);
    expect(healthState.hasError, isTrue);
    expect(healthState.error, isA<AuthRequiredException>());

    expect(todayRepository.calls, 0);
    expect(medicineRepository.calls, 0);
    expect(mineRepository.calls, 0);
    expect(recordRepository.calls, 0);
    expect(healthRepository.fetchCalls, 0);
  });

  test('signed in providers call protected repositories', () async {
    final todayRepository = _CountingTodayRepository();
    final medicineRepository = _CountingMedicineWorkspaceRepository();
    final mineRepository = _CountingMineRepository();
    final recordRepository = _CountingRecordRepository();
    final healthRepository = _CountingHealthContextRepository();
    final container = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
        todayRepositoryProvider.overrideWithValue(todayRepository),
        medicineWorkspaceRepositoryProvider.overrideWithValue(
          medicineRepository,
        ),
        mineRepositoryProvider.overrideWithValue(mineRepository),
        recordRepositoryProvider.overrideWithValue(recordRepository),
        healthContextRepositoryProvider.overrideWithValue(healthRepository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(todayDashboardProvider.future);
    await container.read(medicineWorkspaceProvider.future);
    await container.read(mineDashboardProvider.future);
    await container.read(recordDashboardProvider.future);
    await container.read(healthContextSnapshotProvider.future);

    expect(todayRepository.calls, 1);
    expect(medicineRepository.calls, 1);
    expect(mineRepository.calls, 1);
    expect(recordRepository.calls, 1);
    expect(healthRepository.fetchCalls, 1);
  });
}

class _CountingTodayRepository implements TodayRepository {
  int calls = 0;

  @override
  TaskEither<LucentFailure, TodayDashboard> fetchDashboard() {
    calls += 1;
    return TaskEither.right(MockTodayRepository.previewDashboard);
  }

  @override
  Future<TodayDashboard> get signedOutDashboard =>
      Future.value(TodayDashboard.signedOut());
}

class _CountingMedicineWorkspaceRepository
    implements MedicineWorkspaceRepository {
  int calls = 0;

  @override
  TaskEither<LucentFailure, MedicineWorkspace> fetchWorkspace() {
    calls += 1;
    return TaskEither.right(MockMedicineWorkspaceRepository.previewWorkspace);
  }

  @override
  Future<MedicineWorkspace> get signedOutWorkspace =>
      Future.value(MockMedicineWorkspaceRepository.previewWorkspace);
}

class _CountingMineRepository implements MineRepository {
  int calls = 0;

  @override
  TaskEither<LucentFailure, MineDashboard> fetchDashboard() {
    calls += 1;
    return const MockMineRepository().fetchDashboard();
  }

  @override
  Future<MineDashboard> get signedOutDashboard =>
      Future.value(MineDashboard.signedOut());
}

class _CountingRecordRepository implements RecordRepository {
  int calls = 0;

  @override
  TaskEither<LucentFailure, RecordDashboard> fetchDashboard(
    DateTime selectedDate, {
    RecordEntryType? filterType,
  }) {
    calls += 1;
    return const MockRecordRepository().fetchDashboard(
      selectedDate,
      filterType: filterType,
    );
  }

  @override
  Future<RecordDashboard> signedOutDashboard(
    DateTime selectedDate, {
    RecordEntryType? filterType,
  }) => const MockRecordRepository().signedOutDashboard(
    selectedDate,
    filterType: filterType,
  );
}

class _CountingHealthContextRepository implements HealthContextRepository {
  int fetchCalls = 0;

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> fetchHealthContext() {
    fetchCalls += 1;
    return TaskEither.right(_snapshot);
  }

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> createAllergy(
    HealthAllergyWriteInput input,
  ) => throw UnimplementedError();

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> createCondition(
    HealthConditionWriteInput input,
  ) => throw UnimplementedError();

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> createCurrentMedicine(
    CurrentMedicineWriteInput input,
  ) => throw UnimplementedError();

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> deleteAllergy(String id) =>
      throw UnimplementedError();

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> deleteCondition(String id) =>
      throw UnimplementedError();

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> deleteCurrentMedicine(
    String id,
  ) => throw UnimplementedError();

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> updateAllergy(
    String id,
    HealthAllergyUpdateInput input,
  ) => throw UnimplementedError();

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> updateCondition(
    String id,
    HealthConditionUpdateInput input,
  ) => throw UnimplementedError();

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> updateCurrentMedicine(
    String id,
    CurrentMedicineUpdateInput input,
  ) => throw UnimplementedError();

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> updateProfile(
    HealthProfileUpdateInput input,
  ) => throw UnimplementedError();
}

class _SignedOutAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return const AuthSessionState(isAuthenticated: false, isLoading: false);
  }
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

const _snapshot = HealthContextSnapshot(
  summary: HealthSummary(
    age: 27,
    onboardingCompleted: true,
    activeAllergyCount: 0,
    conditionCount: 0,
    currentMedicineCount: 0,
    missingCoreProfileFields: <String>[],
  ),
  profile: HealthProfile(
    birthDate: '1999-01-15',
    sexAtBirth: 'female',
    heightCm: 165,
    weightKg: null,
    activityLevel: null,
    dietaryPreferences: null,
    locale: null,
    timezone: null,
    unitSystem: null,
    onboardingCompletedAt: '2026-01-01T00:00:00Z',
    extras: <String, dynamic>{},
  ),
  allergies: <AllergyItem>[],
  conditions: <ConditionItem>[],
  currentMedicines: <CurrentMedicineItem>[],
);
