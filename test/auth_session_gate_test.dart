import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_write_inputs.dart';
import 'package:luminous/features/health_context/domain/repositories/health_context_repository.dart';
import 'package:luminous/features/medicine/data/repositories/mock_medicine_workspace_repository.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_workspace.dart';
import 'package:luminous/features/medicine/domain/repositories/medicine_workspace_repository.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_workspace_provider.dart';
import 'package:luminous/features/mine/data/repositories/mock_mine_repository.dart';
import 'package:luminous/features/mine/domain/entities/mine_dashboard.dart';
import 'package:luminous/features/mine/domain/repositories/mine_repository.dart';
import 'package:luminous/features/mine/presentation/providers/mine_dashboard_provider.dart';
import 'package:luminous/features/record/data/repositories/mock_record_repository.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/domain/repositories/record_repository.dart';
import 'package:luminous/features/record/presentation/providers/record_dashboard_provider.dart';
import 'package:luminous/features/today/data/repositories/mock_today_repository.dart';
import 'package:luminous/features/today/domain/entities/today_dashboard.dart';
import 'package:luminous/features/today/domain/repositories/today_repository.dart';
import 'package:luminous/features/today/presentation/providers/today_dashboard_provider.dart';

void main() {
  test(
    'restoring auth keeps protected providers loading without repo calls',
    () {
      final todayRepository = _CountingTodayRepository();
      final medicineRepository = _CountingMedicineWorkspaceRepository();
      final mineRepository = _CountingMineRepository();
      final recordRepository = _CountingRecordRepository();
      final healthRepository = _CountingHealthContextRepository();
      final container = ProviderContainer(
        overrides: [
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

      expect(container.read(todayDashboardProvider).isLoading, isTrue);
      expect(container.read(medicineWorkspaceProvider).isLoading, isTrue);
      expect(container.read(mineDashboardProvider).isLoading, isTrue);
      expect(container.read(recordDashboardProvider).isLoading, isTrue);
      expect(container.read(healthContextSnapshotProvider).isLoading, isTrue);

      expect(todayRepository.calls, 0);
      expect(medicineRepository.calls, 0);
      expect(mineRepository.calls, 0);
      expect(recordRepository.calls, 0);
      expect(healthRepository.fetchCalls, 0);
    },
  );

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
    expect(medicine.plan.items, isEmpty);
    expect(mine.account.isAuthenticated, isFalse);
    expect(record.timeline, isNotEmpty);
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
  Future<TodayDashboard> fetchDashboard() async {
    calls += 1;
    return MockTodayRepository.previewDashboard;
  }
}

class _CountingMedicineWorkspaceRepository
    implements MedicineWorkspaceRepository {
  int calls = 0;

  @override
  Future<MedicineWorkspace> fetchWorkspace() async {
    calls += 1;
    return MockMedicineWorkspaceRepository.previewWorkspace;
  }
}

class _CountingMineRepository implements MineRepository {
  int calls = 0;

  @override
  Future<MineDashboard> fetchDashboard() async {
    calls += 1;
    return const MockMineRepository().fetchDashboard();
  }
}

class _CountingRecordRepository implements RecordRepository {
  int calls = 0;

  @override
  Future<RecordDashboard> fetchDashboard(DateTime selectedDate) async {
    calls += 1;
    return const MockRecordRepository().fetchDashboard(selectedDate);
  }
}

class _CountingHealthContextRepository implements HealthContextRepository {
  int fetchCalls = 0;

  @override
  Future<HealthContextSnapshot> fetchHealthContext() async {
    fetchCalls += 1;
    return _snapshot;
  }

  @override
  Future<HealthContextSnapshot> createAllergy(
    HealthAllergyWriteInput input,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<HealthContextSnapshot> createCondition(
    HealthConditionWriteInput input,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<HealthContextSnapshot> createCurrentMedicine(
    CurrentMedicineWriteInput input,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<HealthContextSnapshot> deleteAllergy(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<HealthContextSnapshot> deleteCondition(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<HealthContextSnapshot> deleteCurrentMedicine(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<HealthContextSnapshot> updateAllergy(
    String id,
    HealthAllergyUpdateInput input,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<HealthContextSnapshot> updateCondition(
    String id,
    HealthConditionUpdateInput input,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<HealthContextSnapshot> updateCurrentMedicine(
    String id,
    CurrentMedicineUpdateInput input,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<HealthContextSnapshot> updateProfile(
    HealthProfileUpdateInput input,
  ) async {
    throw UnimplementedError();
  }
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

final _snapshot = HealthContextSnapshot(
  summary: const HealthSummary(
    age: 27,
    onboardingCompleted: true,
    activeAllergyCount: 0,
    conditionCount: 0,
    currentMedicineCount: 0,
    missingCoreProfileFields: <String>[],
  ),
  profile: const HealthProfile(
    birthDate: '1999-01-15',
    sexAtBirth: 'female',
    heightCm: 165,
    pregnancyState: null,
    lactationState: null,
    bloodType: null,
    locale: null,
    timezone: null,
    unitSystem: null,
    onboardingCompletedAt: '2026-01-01T00:00:00Z',
    extras: <String, dynamic>{},
  ),
  allergies: const <AllergyItem>[],
  conditions: const <ConditionItem>[],
  currentMedicines: const <CurrentMedicineItem>[],
);
