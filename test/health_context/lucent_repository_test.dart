import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/database/daos/health_context_dao.dart';
import 'package:luminous/core/database/daos/pending_sync_dao.dart';
import 'package:luminous/core/database/sync/worker.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/health_context/data/datasources/snapshot.dart';
import 'package:luminous/features/health_context/data/mappers/health_context.dart';
import 'package:luminous/features/health_context/data/repositories/lucent.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../helpers/task_either.dart';

// ── Fakes ───────────────────────────────────────────────────────

class _FakeHealthContextRemoteDataSource
    implements HealthContextRemoteDataSource {
  HealthContextResponseDto? fetchResult;
  HealthContextResponseDto? updateProfileResult;
  HealthContextResponseDto? createAllergyResult;
  HealthContextResponseDto? updateAllergyResult;
  HealthContextResponseDto? deleteAllergyResult;
  HealthContextResponseDto? createConditionResult;
  HealthContextResponseDto? updateConditionResult;
  HealthContextResponseDto? deleteConditionResult;
  HealthContextResponseDto? createCurrentMedicineResult;
  HealthContextResponseDto? updateCurrentMedicineResult;
  HealthContextResponseDto? deleteCurrentMedicineResult;

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
  Future<HealthContextResponseDto> fetchHealthContext() async {
    fetchCallCount++;
    if (fetchError != null) throw fetchError!;
    return fetchResult ?? _buildDto();
  }

  @override
  Future<HealthContextResponseDto> updateProfile(
    HealthProfileUpdateInput input,
  ) async {
    if (writeShouldFail) {
      throw _networkError('/api/v1/user/health-context/profile');
    }
    return updateProfileResult ?? _buildDto();
  }

  @override
  Future<HealthContextResponseDto> createAllergy(
    HealthAllergyWriteInput input,
  ) async {
    if (writeShouldFail) {
      throw _networkError('/api/v1/user/health-context/allergies');
    }
    return createAllergyResult ?? _buildDto();
  }

  @override
  Future<HealthContextResponseDto> updateAllergy(
    String id,
    HealthAllergyUpdateInput input,
  ) async {
    if (writeShouldFail) {
      throw _networkError('/api/v1/user/health-context/allergies/$id');
    }
    return updateAllergyResult ?? _buildDto();
  }

  @override
  Future<HealthContextResponseDto> deleteAllergy(String id) async {
    if (writeShouldFail) {
      throw _networkError('/api/v1/user/health-context/allergies/$id');
    }
    return deleteAllergyResult ?? _buildDto();
  }

  @override
  Future<HealthContextResponseDto> createCondition(
    HealthConditionWriteInput input,
  ) async {
    if (writeShouldFail) {
      throw _networkError('/api/v1/user/health-context/conditions');
    }
    return createConditionResult ?? _buildDto();
  }

  @override
  Future<HealthContextResponseDto> updateCondition(
    String id,
    HealthConditionUpdateInput input,
  ) async {
    if (writeShouldFail) {
      throw _networkError('/api/v1/user/health-context/conditions/$id');
    }
    return updateConditionResult ?? _buildDto();
  }

  @override
  Future<HealthContextResponseDto> deleteCondition(String id) async {
    if (writeShouldFail) {
      throw _networkError('/api/v1/user/health-context/conditions/$id');
    }
    return deleteConditionResult ?? _buildDto();
  }

  @override
  Future<HealthContextResponseDto> createCurrentMedicine(
    CurrentMedicineWriteInput input,
  ) async {
    if (writeShouldFail) {
      throw _networkError('/api/v1/user/health-context/current-medicines');
    }
    return createCurrentMedicineResult ?? _buildDto();
  }

  @override
  Future<HealthContextResponseDto> updateCurrentMedicine(
    String id,
    CurrentMedicineUpdateInput input,
  ) async {
    if (writeShouldFail) {
      throw _networkError('/api/v1/user/health-context/current-medicines/$id');
    }
    return updateCurrentMedicineResult ?? _buildDto();
  }

  @override
  Future<HealthContextResponseDto> deleteCurrentMedicine(String id) async {
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

HealthContextResponseDto _buildDto({
  int? age,
  bool onboardingCompleted = true,
  int activeAllergyCount = 0,
  int conditionCount = 0,
  int currentMedicineCount = 0,
}) {
  return HealthContextResponseDto(
    summary: UserHealthSummaryDto(
      age: age,
      onboardingCompleted: onboardingCompleted,
      activeAllergyCount: activeAllergyCount,
      conditionCount: conditionCount,
      currentMedicineCount: currentMedicineCount,
      missingCoreProfileFields: [],
    ),
    profile: UserHealthProfileDto(
      birthDate: null,
      sexAtBirth: SexAtBirth.unknown,
      heightCm: null,
      weightKg: null,
      bloodType: null,
      locale: null,
      timezone: null,
      unitSystem: UnitSystem.metric,
      onboardingCompletedAt: null,
      emergencyContact: null,
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

      final result = await expectTaskRight(repo.fetchHealthContext());

      expect(result.summary.age, 30);
      expect(result.summary.activeAllergyCount, 2);
      expect(dataSource.fetchCallCount, 1);
      verify(() => dao.replace(any())).called(1);
    });

    test('cache hit → returns cached without network fetch', () async {
      cachedJson = _encodeSnapshot();

      final result = await expectTaskRight(repo.fetchHealthContext());

      expect(dataSource.fetchCallCount, 0);
      expect(result.summary.onboardingCompleted, isTrue);
    });

    test('cache hit → background refresh triggered', () async {
      cachedJson = _encodeSnapshot();

      await expectTaskRight(repo.fetchHealthContext());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(dataSource.fetchCallCount, 1);
    });

    test('background refresh is throttled to 30s', () async {
      cachedJson = _encodeSnapshot();

      await expectTaskRight(repo.fetchHealthContext());
      await Future.delayed(const Duration(milliseconds: 100));

      await expectTaskRight(repo.fetchHealthContext());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(dataSource.fetchCallCount, 1);
    });

    test('network error surfaces as a Left when cache is empty', () async {
      dataSource.fetchError = Exception('network error');

      final failure = await expectTaskLeft(repo.fetchHealthContext());

      expect(failure.kind, LucentFailureKind.unknown);
    });

    test(
      '404 Problem Details keeps its code on an empty-cache fetch',
      () async {
        const path = '/api/v1/user/health-context';
        dataSource.fetchError = DioException(
          requestOptions: RequestOptions(path: path),
          response: Response<Object>(
            requestOptions: RequestOptions(path: path),
            statusCode: 404,
            headers: Headers()
              ..set(Headers.contentTypeHeader, 'application/problem+json'),
            data: <String, dynamic>{
              'type':
                  'https://api.lumos.example/problems/HEALTH_CONTEXT_NOT_FOUND',
              'title': 'Not found',
              'detail': '健康档案不存在',
              'code': 'HEALTH_CONTEXT_NOT_FOUND',
            },
          ),
        );

        final failure = await expectTaskLeft(repo.fetchHealthContext());

        expect(failure.code, 'HEALTH_CONTEXT_NOT_FOUND');
        expect(failure.statusCode, 404);
        expect(failure.kind, LucentFailureKind.business);
      },
    );
  });

  group('updateProfile', () {
    test('calls dataSource and caches result', () async {
      dataSource.updateProfileResult = _buildDto(age: 25);

      const input = HealthProfileUpdateInput();
      final result = await expectTaskRight(repo.updateProfile(input));

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
      final result = await expectTaskRight(repo.createAllergy(input));

      expect(result.summary.activeAllergyCount, 1);
      verify(() => dao.replace(any())).called(1);
    });
  });

  group('updateAllergy', () {
    test('calls dataSource with id and caches result', () async {
      dataSource.updateAllergyResult = _buildDto(activeAllergyCount: 1);

      const input = HealthAllergyUpdateInput();
      final result = await expectTaskRight(
        repo.updateAllergy('allergy-1', input),
      );

      expect(result.summary.activeAllergyCount, 1);
      verify(() => dao.replace(any())).called(1);
    });
  });

  group('deleteAllergy', () {
    test('calls dataSource with id and caches result', () async {
      dataSource.deleteAllergyResult = _buildDto(activeAllergyCount: 0);

      final result = await expectTaskRight(repo.deleteAllergy('allergy-1'));

      expect(result.summary.activeAllergyCount, 0);
      verify(() => dao.replace(any())).called(1);
    });
  });

  group('createCondition', () {
    test('calls dataSource and caches result', () async {
      dataSource.createConditionResult = _buildDto(conditionCount: 1);

      const input = HealthConditionWriteInput(label: 'Hypertension');
      final result = await expectTaskRight(repo.createCondition(input));

      expect(result.summary.conditionCount, 1);
      verify(() => dao.replace(any())).called(1);
    });
  });

  group('updateCondition', () {
    test('calls dataSource with id and caches result', () async {
      dataSource.updateConditionResult = _buildDto(conditionCount: 1);

      const input = HealthConditionUpdateInput();
      final result = await expectTaskRight(
        repo.updateCondition('cond-1', input),
      );

      expect(result.summary.conditionCount, 1);
      verify(() => dao.replace(any())).called(1);
    });
  });

  group('deleteCondition', () {
    test('calls dataSource with id and caches result', () async {
      dataSource.deleteConditionResult = _buildDto(conditionCount: 0);

      final result = await expectTaskRight(repo.deleteCondition('cond-1'));

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
      final result = await expectTaskRight(repo.createCurrentMedicine(input));

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
      final result = await expectTaskRight(
        repo.updateCurrentMedicine('med-1', input),
      );

      expect(result.summary.currentMedicineCount, 1);
      verify(() => dao.replace(any())).called(1);
    });
  });

  group('deleteCurrentMedicine', () {
    test('calls dataSource with id and caches result', () async {
      dataSource.deleteCurrentMedicineResult = _buildDto(
        currentMedicineCount: 0,
      );

      final result = await expectTaskRight(repo.deleteCurrentMedicine('med-1'));

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

      final failure = await expectTaskLeft(
        repo.createAllergy(
          const HealthAllergyWriteInput(
            kind: HealthAllergyKind.food,
            label: 'Peanuts',
          ),
        ),
      );

      expect(failure.isNetworkConnectivityError, isTrue);
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

      final failure = await expectTaskLeft(
        repo.updateProfile(const HealthProfileUpdateInput()),
      );

      expect(failure.isNetworkConnectivityError, isTrue);
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

        final failure = await expectTaskLeft(
          repo.deleteCurrentMedicine('med-1'),
        );

        expect(failure.isNetworkConnectivityError, isTrue);
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

      await expectTaskLeft(
        repo.createAllergy(
          const HealthAllergyWriteInput(
            kind: HealthAllergyKind.food,
            label: 'Peanuts',
          ),
        ),
      );

      verifyNever(
        () => pendingSyncDao.enqueue(
          entityType: any(named: 'entityType'),
          operation: any(named: 'operation'),
          payload: any(named: 'payload'),
        ),
      );
    });

    test(
      'enqueue failure does not mask the original network failure Left',
      () async {
        dataSource.writeShouldFail = true;
        when(
          () => pendingSyncDao.enqueue(
            entityType: any(named: 'entityType'),
            operation: any(named: 'operation'),
            payload: any(named: 'payload'),
          ),
        ).thenThrow(Exception('local db write failed'));

        final failure = await expectTaskLeft(
          repo.createAllergy(
            const HealthAllergyWriteInput(
              kind: HealthAllergyKind.food,
              label: 'Peanuts',
            ),
          ),
        );

        // The enqueue (local DB) failure is logged, but the Left must still
        // carry the original network failure's kind.
        expect(failure.isNetworkConnectivityError, isTrue);
        expect(failure.kind, LucentFailureKind.network);
      },
    );
  });

  group('cache write failure paths', () {
    test(
      'path A: cache write failure after empty-cache fetch surfaces a Left',
      () async {
        dataSource.fetchResult = _buildDto(age: 30);
        when(() => dao.replace(any())).thenThrow(Exception('disk full'));

        final failure = await expectTaskLeft(repo.fetchHealthContext());

        expect(failure.kind, LucentFailureKind.unknown);
        expect(dataSource.fetchCallCount, 1);
      },
    );

    test(
      'path B: background refresh cache write failure keeps cached snapshot',
      () async {
        cachedJson = _encodeSnapshot();
        when(() => dao.replace(any())).thenThrow(Exception('disk full'));

        // Cache hit returns the cached snapshot; the background refresh's
        // cache write fails but is best-effort and only observed.
        final result = await expectTaskRight(repo.fetchHealthContext());
        await Future.delayed(const Duration(milliseconds: 100));

        expect(result.summary.onboardingCompleted, isTrue);
        expect(dataSource.fetchCallCount, 1);
      },
    );

    test(
      'path C: write-path cache write failure after remote success is a Left '
      'without pending-sync enqueue',
      () async {
        final pendingSyncDao = _MockPendingSyncDao();
        final syncWorker = _FakeSyncWorker(pendingSyncDao: pendingSyncDao);
        repo = LucentHealthContextRepository(
          dataSource: dataSource,
          mapper: mapper,
          dao: dao,
          pendingSyncDao: pendingSyncDao,
          syncWorker: syncWorker,
        );
        when(() => dao.replace(any())).thenThrow(Exception('disk full'));

        // The remote write itself succeeds; the failure is the cache write
        // on the success path, which must surface as a Left (not a silent
        // success) and must not enqueue a pending sync entry.
        final failure = await expectTaskLeft(
          repo.createAllergy(
            const HealthAllergyWriteInput(
              kind: HealthAllergyKind.food,
              label: 'Peanuts',
            ),
          ),
        );

        expect(failure.kind, LucentFailureKind.unknown);
        verifyNever(
          () => pendingSyncDao.enqueue(
            entityType: any(named: 'entityType'),
            operation: any(named: 'operation'),
            payload: any(named: 'payload'),
          ),
        );
        expect(syncWorker.flushCalled, isFalse);
      },
    );
  });

  group('cache JSON round-trip', () {
    test('snapshot with allergies survives cache round-trip', () async {
      dataSource.createAllergyResult = HealthContextResponseDto(
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
          weightKg: null,
          bloodType: null,
          locale: null,
          timezone: null,
          unitSystem: UnitSystem.metric,
          onboardingCompletedAt: null,
          emergencyContact: null,
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

      await expectTaskRight(
        repo.createAllergy(
          const HealthAllergyWriteInput(
            kind: HealthAllergyKind.food,
            label: 'Peanuts',
          ),
        ),
      );

      dataSource.fetchCallCount = 0;
      final result = await expectTaskRight(repo.fetchHealthContext());

      expect(dataSource.fetchCallCount, 0);
      expect(result.allergies.length, 1);
      expect(result.allergies[0].id, 'allergy-1');
      expect(result.allergies[0].label, 'Peanuts');
      expect(result.allergies[0].kind, 'food');
      expect(result.allergies[0].isActive, isTrue);
    });

    test('snapshot with conditions survives cache round-trip', () async {
      dataSource.createConditionResult = HealthContextResponseDto(
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
          weightKg: null,
          bloodType: null,
          locale: null,
          timezone: null,
          unitSystem: UnitSystem.metric,
          onboardingCompletedAt: null,
          emergencyContact: null,
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

      await expectTaskRight(
        repo.createCondition(
          const HealthConditionWriteInput(label: 'Hypertension'),
        ),
      );

      dataSource.fetchCallCount = 0;
      final result = await expectTaskRight(repo.fetchHealthContext());

      expect(result.conditions.length, 1);
      expect(result.conditions[0].id, 'cond-1');
      expect(result.conditions[0].label, 'Hypertension');
      expect(result.conditions[0].status, 'active');
      expect(result.conditions[0].note, 'Under treatment');
    });

    test('snapshot with currentMedicines survives cache round-trip', () async {
      dataSource.createCurrentMedicineResult = HealthContextResponseDto(
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
          weightKg: null,
          bloodType: null,
          locale: null,
          timezone: null,
          unitSystem: UnitSystem.metric,
          onboardingCompletedAt: null,
          emergencyContact: null,
          extras: {},
        ),
        allergies: [],
        conditions: [],
        currentMedicines: [
          UserCurrentMedicineItemDto(
            id: 'med-1',
            source_: MedicineSource.cn,
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

      await expectTaskRight(
        repo.createCurrentMedicine(
          const CurrentMedicineWriteInput(
            source: HealthMedicineSource.cn,
            displayName: 'Aspirin',
          ),
        ),
      );

      dataSource.fetchCallCount = 0;
      final result = await expectTaskRight(repo.fetchHealthContext());

      expect(result.currentMedicines.length, 1);
      expect(result.currentMedicines[0].id, 'med-1');
      expect(result.currentMedicines[0].displayName, 'Aspirin');
      expect(result.currentMedicines[0].source, 'cn');
      expect(result.currentMedicines[0].isCurrent, isTrue);
    });

    test('snapshot with profile extras survives cache round-trip', () async {
      dataSource.updateProfileResult = HealthContextResponseDto(
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
          weightKg: null,
          bloodType: 'A+',
          locale: 'zh-CN',
          timezone: 'Asia/Shanghai',
          unitSystem: UnitSystem.metric,
          onboardingCompletedAt: '2026-07-11T08:00:00.000Z',
          emergencyContact: null,
          extras: {'customKey': 'customValue'},
        ),
        allergies: [],
        conditions: [],
        currentMedicines: [],
      );

      await expectTaskRight(
        repo.updateProfile(const HealthProfileUpdateInput()),
      );

      dataSource.fetchCallCount = 0;
      final result = await expectTaskRight(repo.fetchHealthContext());

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
