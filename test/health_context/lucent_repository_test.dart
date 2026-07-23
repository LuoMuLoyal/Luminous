import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/api/export.dart';
import 'package:luminous/core/database/daos/health_context_dao.dart';
import 'package:luminous/core/database/daos/pending_sync_dao.dart';
import 'package:luminous/core/database/sync/sync_worker.dart';
import 'package:luminous/core/errors/error.dart';
import 'package:luminous/features/health_context/data/datasources/snapshot.dart';
import 'package:luminous/features/health_context/data/mappers/health_context.dart';
import 'package:luminous/features/health_context/data/repositories/lucent.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talker_flutter/talker_flutter.dart';

// ── Fakes ───────────────────────────────────────────────────────

class _FakeHealthContextRemoteDataSource
    implements HealthContextRemoteDataSource {
  HealthContextDataDto? fetchResult;
  HealthContextDataDto? updateProfileResult;
  HealthContextDataDto? createAllergyResult;
  HealthContextDataDto? updateAllergyResult;
  HealthContextDataDto? deleteAllergyResult;
  HealthContextDataDto? createConditionResult;
  HealthContextDataDto? updateConditionResult;
  HealthContextDataDto? deleteConditionResult;
  HealthContextDataDto? createCurrentMedicineResult;
  HealthContextDataDto? updateCurrentMedicineResult;
  HealthContextDataDto? deleteCurrentMedicineResult;

  Object? fetchError;
  int fetchCallCount = 0;

  /// When true, write operations throw a [DioException] simulating
  /// network failure.
  bool writeShouldFail = false;

  DioException _networkError(String path) => DioException(
    requestOptions: RequestOptions(
      path: path,
      method: 'POST',
      data: <String, dynamic>{'test': true},
    ),
    type: DioExceptionType.connectionError,
  );

  @override
  Future<HealthContextDataDto> fetchHealthContext() async {
    fetchCallCount++;
    if (fetchError != null) throw fetchError!;
    return fetchResult ?? _buildDto();
  }

  @override
  Future<HealthContextDataDto> updateProfile(
    HealthProfileUpdateInput input,
  ) async {
    if (writeShouldFail) {
      throw _networkError('/api/v1/user/health-context/profile');
    }
    return updateProfileResult ?? _buildDto();
  }

  @override
  Future<HealthContextDataDto> createAllergy(
    HealthAllergyWriteInput input,
  ) async {
    if (writeShouldFail) {
      throw _networkError('/api/v1/user/health-context/allergies');
    }
    return createAllergyResult ?? _buildDto();
  }

  @override
  Future<HealthContextDataDto> updateAllergy(
    String id,
    HealthAllergyUpdateInput input,
  ) async {
    if (writeShouldFail) {
      throw _networkError('/api/v1/user/health-context/allergies/$id');
    }
    return updateAllergyResult ?? _buildDto();
  }

  @override
  Future<HealthContextDataDto> deleteAllergy(String id) async {
    if (writeShouldFail) {
      throw _networkError('/api/v1/user/health-context/allergies/$id');
    }
    return deleteAllergyResult ?? _buildDto();
  }

  @override
  Future<HealthContextDataDto> createCondition(
    HealthConditionWriteInput input,
  ) async {
    if (writeShouldFail) {
      throw _networkError('/api/v1/user/health-context/conditions');
    }
    return createConditionResult ?? _buildDto();
  }

  @override
  Future<HealthContextDataDto> updateCondition(
    String id,
    HealthConditionUpdateInput input,
  ) async {
    if (writeShouldFail) {
      throw _networkError('/api/v1/user/health-context/conditions/$id');
    }
    return updateConditionResult ?? _buildDto();
  }

  @override
  Future<HealthContextDataDto> deleteCondition(String id) async {
    if (writeShouldFail) {
      throw _networkError('/api/v1/user/health-context/conditions/$id');
    }
    return deleteConditionResult ?? _buildDto();
  }

  @override
  Future<HealthContextDataDto> createCurrentMedicine(
    CurrentMedicineWriteInput input,
  ) async {
    if (writeShouldFail) {
      throw _networkError('/api/v1/user/health-context/current-medicines');
    }
    return createCurrentMedicineResult ?? _buildDto();
  }

  @override
  Future<HealthContextDataDto> updateCurrentMedicine(
    String id,
    CurrentMedicineUpdateInput input,
  ) async {
    if (writeShouldFail) {
      throw _networkError('/api/v1/user/health-context/current-medicines/$id');
    }
    return updateCurrentMedicineResult ?? _buildDto();
  }

  @override
  Future<HealthContextDataDto> deleteCurrentMedicine(String id) async {
    if (writeShouldFail) {
      throw _networkError('/api/v1/user/health-context/current-medicines/$id');
    }
    return deleteCurrentMedicineResult ?? _buildDto();
  }
}

class _MockHealthContextDao extends Mock implements HealthContextDao {}

class _MockPendingSyncDao extends Mock implements PendingSyncDao {}

class _FakeSyncWorker extends SyncWorker {
  _FakeSyncWorker({required super.pendingSyncDao})
    : super(dio: Dio(), talker: Talker());

  bool flushCalled = false;

  @override
  Future<void> flush() async {
    flushCalled = true;
  }
}

// ── DTO builder ─────────────────────────────────────────────────

HealthContextDataDto _buildDto({
  int? age,
  bool onboardingCompleted = true,
  int activeAllergyCount = 0,
  int conditionCount = 0,
  int currentMedicineCount = 0,
}) {
  return HealthContextDataDto(
    summary: UserHealthSummaryDto(
      age: age,
      onboardingCompleted: onboardingCompleted,
      activeAllergyCount: activeAllergyCount,
      conditionCount: conditionCount,
      currentMedicineCount: currentMedicineCount,
      missingCoreProfileFields: [],
    ),
    profile: const UserHealthProfileDto(
      birthDate: null,
      sexAtBirth: SexAtBirth.unknown,
      heightCm: null,
      bloodType: null,
      locale: null,
      timezone: null,
      unitSystem: UnitSystem.metric,
      onboardingCompletedAt: null,
      extras: {},
    ),
    allergies: [],
    conditions: [],
    currentMedicines: [],
  );
}

String _encodeSnapshot() {
  return '{"summary":{"age":null,"onboardingCompleted":true,"activeAllergyCount":0,"conditionCount":0,"currentMedicineCount":0,"missingCoreProfileFields":[]},"profile":{"birthDate":null,"sexAtBirth":null,"heightCm":null,"bloodType":null,"locale":null,"timezone":null,"unitSystem":null,"onboardingCompletedAt":null,"extras":{}},"allergies":[],"conditions":[],"currentMedicines":[]}';
}

// ── Tests ───────────────────────────────────────────────────────

void main() {
  late _FakeHealthContextRemoteDataSource dataSource;
  late HealthContextMapper mapper;
  late _MockHealthContextDao dao;
  late LucentHealthContextRepository repo;
  String? cachedJson;

  setUp(() {
    registerFallbackValue('');
    dataSource = _FakeHealthContextRemoteDataSource();
    mapper = HealthContextMapper();
    dao = _MockHealthContextDao();
    cachedJson = null;
    when(() => dao.fetch()).thenAnswer((_) async => cachedJson);
    when(() => dao.replace(any())).thenAnswer((invocation) async {
      cachedJson = invocation.positionalArguments[0] as String;
    });
    repo = LucentHealthContextRepository(
      dataSource: dataSource,
      mapper: mapper,
      dao: dao,
    );
  });

  group('fetchHealthContext', () {
    test('cache empty → fetches from network and caches', () async {
      dataSource.fetchResult = _buildDto(age: 30, activeAllergyCount: 2);

      final result = await repo.fetchHealthContext();

      expect(result.summary.age, 30);
      expect(result.summary.activeAllergyCount, 2);
      expect(dataSource.fetchCallCount, 1);
      verify(() => dao.replace(any())).called(1);
    });

    test('cache hit → returns cached without network fetch', () async {
      cachedJson = _encodeSnapshot();

      final result = await repo.fetchHealthContext();

      expect(dataSource.fetchCallCount, 0);
      expect(result.summary.onboardingCompleted, isTrue);
    });

    test('cache hit → background refresh triggered', () async {
      cachedJson = _encodeSnapshot();

      await repo.fetchHealthContext();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(dataSource.fetchCallCount, 1);
    });

    test('background refresh is throttled to 30s', () async {
      cachedJson = _encodeSnapshot();

      await repo.fetchHealthContext();
      await Future.delayed(const Duration(milliseconds: 100));

      await repo.fetchHealthContext();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(dataSource.fetchCallCount, 1);
    });

    test('network error propagates when cache is empty', () async {
      dataSource.fetchError = Exception('network error');

      expect(() => repo.fetchHealthContext(), throwsA(isA<Exception>()));
    });
  });

  group('updateProfile', () {
    test('calls dataSource and caches result', () async {
      dataSource.updateProfileResult = _buildDto(age: 25);

      const input = HealthProfileUpdateInput();
      final result = await repo.updateProfile(input);

      expect(result.summary.age, 25);
      verify(() => dao.replace(any())).called(1);
    });
  });

  group('createAllergy', () {
    test('calls dataSource and caches result', () async {
      dataSource.createAllergyResult = _buildDto(activeAllergyCount: 1);

      const input = HealthAllergyWriteInput(
        kind: HealthAllergyKind.food,
        label: 'Peanuts',
      );
      final result = await repo.createAllergy(input);

      expect(result.summary.activeAllergyCount, 1);
      verify(() => dao.replace(any())).called(1);
    });
  });

  group('updateAllergy', () {
    test('calls dataSource with id and caches result', () async {
      dataSource.updateAllergyResult = _buildDto(activeAllergyCount: 1);

      const input = HealthAllergyUpdateInput();
      final result = await repo.updateAllergy('allergy-1', input);

      expect(result.summary.activeAllergyCount, 1);
      verify(() => dao.replace(any())).called(1);
    });
  });

  group('deleteAllergy', () {
    test('calls dataSource with id and caches result', () async {
      dataSource.deleteAllergyResult = _buildDto(activeAllergyCount: 0);

      final result = await repo.deleteAllergy('allergy-1');

      expect(result.summary.activeAllergyCount, 0);
      verify(() => dao.replace(any())).called(1);
    });
  });

  group('createCondition', () {
    test('calls dataSource and caches result', () async {
      dataSource.createConditionResult = _buildDto(conditionCount: 1);

      const input = HealthConditionWriteInput(label: 'Hypertension');
      final result = await repo.createCondition(input);

      expect(result.summary.conditionCount, 1);
      verify(() => dao.replace(any())).called(1);
    });
  });

  group('updateCondition', () {
    test('calls dataSource with id and caches result', () async {
      dataSource.updateConditionResult = _buildDto(conditionCount: 1);

      const input = HealthConditionUpdateInput();
      final result = await repo.updateCondition('cond-1', input);

      expect(result.summary.conditionCount, 1);
      verify(() => dao.replace(any())).called(1);
    });
  });

  group('deleteCondition', () {
    test('calls dataSource with id and caches result', () async {
      dataSource.deleteConditionResult = _buildDto(conditionCount: 0);

      final result = await repo.deleteCondition('cond-1');

      expect(result.summary.conditionCount, 0);
      verify(() => dao.replace(any())).called(1);
    });
  });

  group('createCurrentMedicine', () {
    test('calls dataSource and caches result', () async {
      dataSource.createCurrentMedicineResult = _buildDto(
        currentMedicineCount: 1,
      );

      const input = CurrentMedicineWriteInput(
        source: HealthMedicineSource.cn,
        displayName: 'Aspirin',
      );
      final result = await repo.createCurrentMedicine(input);

      expect(result.summary.currentMedicineCount, 1);
      verify(() => dao.replace(any())).called(1);
    });
  });

  group('updateCurrentMedicine', () {
    test('calls dataSource with id and caches result', () async {
      dataSource.updateCurrentMedicineResult = _buildDto(
        currentMedicineCount: 1,
      );

      const input = CurrentMedicineUpdateInput();
      final result = await repo.updateCurrentMedicine('med-1', input);

      expect(result.summary.currentMedicineCount, 1);
      verify(() => dao.replace(any())).called(1);
    });
  });

  group('deleteCurrentMedicine', () {
    test('calls dataSource with id and caches result', () async {
      dataSource.deleteCurrentMedicineResult = _buildDto(
        currentMedicineCount: 0,
      );

      final result = await repo.deleteCurrentMedicine('med-1');

      expect(result.summary.currentMedicineCount, 0);
      verify(() => dao.replace(any())).called(1);
    });
  });

  group('offline write-path replay', () {
    late _MockPendingSyncDao pendingSyncDao;
    late _FakeSyncWorker syncWorker;

    setUp(() {
      pendingSyncDao = _MockPendingSyncDao();
      syncWorker = _FakeSyncWorker(pendingSyncDao: pendingSyncDao);
      repo = LucentHealthContextRepository(
        dataSource: dataSource,
        mapper: mapper,
        dao: dao,
        pendingSyncDao: pendingSyncDao,
        syncWorker: syncWorker,
      );
      when(
        () => pendingSyncDao.enqueue(
          entityType: any(named: 'entityType'),
          entityId: any(named: 'entityId'),
          operation: any(named: 'operation'),
          payload: any(named: 'payload'),
        ),
      ).thenAnswer((_) async => 'pending-id');
    });

    test('createAllergy enqueues pending sync on network failure', () async {
      dataSource.writeShouldFail = true;

      expect(
        () => repo.createAllergy(
          const HealthAllergyWriteInput(
            kind: HealthAllergyKind.food,
            label: 'Peanuts',
          ),
        ),
        throwsA(isA<AppError>()),
      );

      await Future.delayed(Duration.zero);

      verify(
        () => pendingSyncDao.enqueue(
          entityType: 'health_context',
          operation: 'write',
          payload: any(named: 'payload'),
        ),
      ).called(1);
      expect(syncWorker.flushCalled, isTrue);
    });

    test('updateProfile enqueues pending sync on network failure', () async {
      dataSource.writeShouldFail = true;

      expect(
        () => repo.updateProfile(const HealthProfileUpdateInput()),
        throwsA(isA<AppError>()),
      );

      await Future.delayed(Duration.zero);

      verify(
        () => pendingSyncDao.enqueue(
          entityType: 'health_context',
          operation: 'write',
          payload: any(named: 'payload'),
        ),
      ).called(1);
    });

    test(
      'deleteCurrentMedicine enqueues pending sync on network failure',
      () async {
        dataSource.writeShouldFail = true;

        expect(
          () => repo.deleteCurrentMedicine('med-1'),
          throwsA(isA<AppError>()),
        );

        await Future.delayed(Duration.zero);

        verify(
          () => pendingSyncDao.enqueue(
            entityType: 'health_context',
            operation: 'write',
            payload: any(named: 'payload'),
          ),
        ).called(1);
      },
    );

    test('does not enqueue when pendingSyncDao is null', () async {
      repo = LucentHealthContextRepository(
        dataSource: dataSource,
        mapper: mapper,
        dao: dao,
      );
      dataSource.writeShouldFail = true;

      expect(
        () => repo.createAllergy(
          const HealthAllergyWriteInput(
            kind: HealthAllergyKind.food,
            label: 'Peanuts',
          ),
        ),
        throwsA(isA<AppError>()),
      );

      await Future.delayed(Duration.zero);

      verifyNever(
        () => pendingSyncDao.enqueue(
          entityType: any(named: 'entityType'),
          operation: any(named: 'operation'),
          payload: any(named: 'payload'),
        ),
      );
    });
  });

  group('cache JSON round-trip', () {
    test('snapshot with allergies survives cache round-trip', () async {
      dataSource.createAllergyResult = const HealthContextDataDto(
        summary: UserHealthSummaryDto(
          age: 30,
          onboardingCompleted: true,
          activeAllergyCount: 1,
          conditionCount: 0,
          currentMedicineCount: 0,
          missingCoreProfileFields: [],
        ),
        profile: UserHealthProfileDto(
          birthDate: null,
          sexAtBirth: SexAtBirth.unknown,
          heightCm: null,
          bloodType: null,
          locale: null,
          timezone: null,
          unitSystem: UnitSystem.metric,
          onboardingCompletedAt: null,
          extras: {},
        ),
        allergies: [
          UserAllergyItemDto(
            id: 'allergy-1',
            kind: UserAllergyKind.food,
            label: 'Peanuts',
            reaction: null,
            severity: UserAllergySeverity.severe,
            isActive: true,
            note: null,
            extras: null,
            recordedAt: null,
            createdAt: '2026-07-11T08:00:00.000Z',
            updatedAt: '2026-07-11T08:00:00.000Z',
          ),
        ],
        conditions: [],
        currentMedicines: [],
      );

      await repo.createAllergy(
        const HealthAllergyWriteInput(
          kind: HealthAllergyKind.food,
          label: 'Peanuts',
        ),
      );

      dataSource.fetchCallCount = 0;
      final result = await repo.fetchHealthContext();

      expect(dataSource.fetchCallCount, 0);
      expect(result.allergies.length, 1);
      expect(result.allergies[0].id, 'allergy-1');
      expect(result.allergies[0].label, 'Peanuts');
      expect(result.allergies[0].kind, 'food');
      expect(result.allergies[0].isActive, isTrue);
    });

    test('snapshot with conditions survives cache round-trip', () async {
      dataSource.createConditionResult = const HealthContextDataDto(
        summary: UserHealthSummaryDto(
          age: null,
          onboardingCompleted: true,
          activeAllergyCount: 0,
          conditionCount: 1,
          currentMedicineCount: 0,
          missingCoreProfileFields: [],
        ),
        profile: UserHealthProfileDto(
          birthDate: null,
          sexAtBirth: SexAtBirth.unknown,
          heightCm: null,
          bloodType: null,
          locale: null,
          timezone: null,
          unitSystem: UnitSystem.metric,
          onboardingCompletedAt: null,
          extras: {},
        ),
        allergies: [],
        conditions: [
          UserConditionItemDto(
            id: 'cond-1',
            label: 'Hypertension',
            status: UserConditionStatus.active,
            diagnosedAt: '2026-01-01',
            resolvedAt: null,
            note: 'Under treatment',
            extras: null,
            createdAt: '2026-07-11T08:00:00.000Z',
            updatedAt: '2026-07-11T08:00:00.000Z',
          ),
        ],
        currentMedicines: [],
      );

      await repo.createCondition(
        const HealthConditionWriteInput(label: 'Hypertension'),
      );

      dataSource.fetchCallCount = 0;
      final result = await repo.fetchHealthContext();

      expect(result.conditions.length, 1);
      expect(result.conditions[0].id, 'cond-1');
      expect(result.conditions[0].label, 'Hypertension');
      expect(result.conditions[0].status, 'active');
      expect(result.conditions[0].note, 'Under treatment');
    });

    test('snapshot with currentMedicines survives cache round-trip', () async {
      dataSource.createCurrentMedicineResult = const HealthContextDataDto(
        summary: UserHealthSummaryDto(
          age: null,
          onboardingCompleted: true,
          activeAllergyCount: 0,
          conditionCount: 0,
          currentMedicineCount: 1,
          missingCoreProfileFields: [],
        ),
        profile: UserHealthProfileDto(
          birthDate: null,
          sexAtBirth: SexAtBirth.unknown,
          heightCm: null,
          bloodType: null,
          locale: null,
          timezone: null,
          unitSystem: UnitSystem.metric,
          onboardingCompletedAt: null,
          extras: {},
        ),
        allergies: [],
        conditions: [],
        currentMedicines: [
          UserCurrentMedicineItemDto(
            id: 'med-1',
            source: MedicineSource.cn,
            sourceRefId: 'ref-1',
            displayName: 'Aspirin',
            strengthText: '100mg',
            doseText: '1 tablet',
            route: 'oral',
            startedAt: '2026-07-01',
            endedAt: null,
            isCurrent: true,
            note: null,
            sourcePayload: null,
            createdAt: '2026-07-11T08:00:00.000Z',
            updatedAt: '2026-07-11T08:00:00.000Z',
          ),
        ],
      );

      await repo.createCurrentMedicine(
        const CurrentMedicineWriteInput(
          source: HealthMedicineSource.cn,
          displayName: 'Aspirin',
        ),
      );

      dataSource.fetchCallCount = 0;
      final result = await repo.fetchHealthContext();

      expect(result.currentMedicines.length, 1);
      expect(result.currentMedicines[0].id, 'med-1');
      expect(result.currentMedicines[0].displayName, 'Aspirin');
      expect(result.currentMedicines[0].source, 'cn');
      expect(result.currentMedicines[0].isCurrent, isTrue);
    });

    test('snapshot with profile extras survives cache round-trip', () async {
      dataSource.updateProfileResult = const HealthContextDataDto(
        summary: UserHealthSummaryDto(
          age: 35,
          onboardingCompleted: true,
          activeAllergyCount: 0,
          conditionCount: 0,
          currentMedicineCount: 0,
          missingCoreProfileFields: [],
        ),
        profile: UserHealthProfileDto(
          birthDate: '1991-05-15',
          sexAtBirth: SexAtBirth.female,
          heightCm: 165.0,
          bloodType: 'A+',
          locale: 'zh-CN',
          timezone: 'Asia/Shanghai',
          unitSystem: UnitSystem.metric,
          onboardingCompletedAt: '2026-07-11T08:00:00.000Z',
          extras: {'customKey': 'customValue'},
        ),
        allergies: [],
        conditions: [],
        currentMedicines: [],
      );

      await repo.updateProfile(const HealthProfileUpdateInput());

      dataSource.fetchCallCount = 0;
      final result = await repo.fetchHealthContext();

      expect(result.profile.birthDate, '1991-05-15');
      expect(result.profile.sexAtBirth, 'female');
      expect(result.profile.heightCm, 165.0);
      expect(result.profile.bloodType, 'A+');
      expect(result.profile.locale, 'zh-CN');
      expect(result.profile.timezone, 'Asia/Shanghai');
      expect(result.profile.unitSystem, 'metric');
      expect(result.profile.onboardingCompletedAt, '2026-07-11T08:00:00.000Z');
      expect(result.profile.extras['customKey'], 'customValue');
    });
  });
}
