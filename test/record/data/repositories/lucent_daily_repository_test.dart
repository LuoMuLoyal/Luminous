import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/api/export.dart' as lucent;
import 'package:luminous/core/database/daos/daily_record_dao.dart';
import 'package:luminous/core/database/daos/pending_sync_dao.dart';
import 'package:luminous/core/database/sync/sync_worker.dart';
import 'package:luminous/core/errors/error.dart';
import 'package:luminous/features/record/data/datasources/record.dart';
import 'package:luminous/features/record/data/repositories/lucent_daily.dart';
import 'package:luminous/features/record/data/utils/daily_record_json_codec.dart';
import 'package:luminous/features/record/domain/entities/candidates.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talker_flutter/talker_flutter.dart';

void main() {
  late _FakeDailyRecordRemoteDataSource dataSource;
  late _MockDailyRecordDao dao;
  late _MockPendingSyncDao pendingSyncDao;
  late _FakeSyncWorker syncWorker;
  late LucentDailyRecordRepository repository;

  setUpAll(() {
    registerFallbackValue(_dummyCreateInput);
    registerFallbackValue(_dummyUpdateInput);
    registerFallbackValue(_dummyImageUploadInput);
  });

  setUp(() {
    dataSource = _FakeDailyRecordRemoteDataSource();
    dao = _MockDailyRecordDao();
    pendingSyncDao = _MockPendingSyncDao();
    syncWorker = _FakeSyncWorker(pendingSyncDao: pendingSyncDao);
    repository = LucentDailyRecordRepository(
      dataSource: dataSource,
      dao: dao,
      pendingSyncDao: pendingSyncDao,
      syncWorker: syncWorker,
    );
  });

  group('LucentDailyRecordRepository — fetchRecords', () {
    test('returns cached items when cache is non-empty', () async {
      final cachedItem = _makeItem(id: 'cached-1');
      final cachedJson = DailyRecordJsonCodec.itemToJson(cachedItem);
      when(
        () => dao.fetchByDate('2026-07-12', kind: null),
      ).thenAnswer((_) async => [cachedJson]);

      final result = await repository.fetchRecords('2026-07-12');

      expect(result.items, hasLength(1));
      expect(result.items.first.id, 'cached-1');
      expect(result.total, 1);
      verify(() => dao.fetchByDate('2026-07-12', kind: null)).called(1);
    });

    test(
      'fetches from network when cache is empty and populates cache',
      () async {
        when(
          () => dao.fetchByDate('2026-07-12', kind: null),
        ).thenAnswer((_) async => []);
        when(
          () => dao.replaceByDate(
            '2026-07-12',
            kind: null,
            jsonItems: any(named: 'jsonItems'),
          ),
        ).thenAnswer((_) async {});

        final result = await repository.fetchRecords('2026-07-12');

        expect(result.items, hasLength(2));
        expect(result.items.first.id, 'remote-1');
        expect(result.total, 2);
        verify(
          () => dao.replaceByDate(
            '2026-07-12',
            kind: null,
            jsonItems: any(named: 'jsonItems'),
          ),
        ).called(1);
      },
    );

    test('throws AppError when network fails and cache is empty', () async {
      when(
        () => dao.fetchByDate('2026-07-12', kind: null),
      ).thenAnswer((_) async => []);
      dataSource.fetchRecordsShouldFail = true;

      expect(
        () => repository.fetchRecords('2026-07-12'),
        throwsA(isA<AppError>()),
      );
    });

    test('filters by kind when provided', () async {
      final cachedItem = _makeItem(id: 'water-1');
      when(
        () => dao.fetchByDate('2026-07-12', kind: 'water'),
      ).thenAnswer((_) async => [DailyRecordJsonCodec.itemToJson(cachedItem)]);

      final result = await repository.fetchRecords('2026-07-12', kind: 'water');

      expect(result.items.first.id, 'water-1');
      verify(() => dao.fetchByDate('2026-07-12', kind: 'water')).called(1);
    });
  });

  group('LucentDailyRecordRepository — fetchSummary', () {
    test('delegates to data source', () async {
      final result = await repository.fetchSummary('2026-07-12');
      expect(result.summaries, hasLength(1));
      expect(result.summaries.first.kind, DailyRecordKind.water);
    });
  });

  group('LucentDailyRecordRepository — get', () {
    test('delegates to data source', () async {
      final result = await repository.get('item-1');
      expect(result.id, 'remote-get-1');
    });
  });

  group('LucentDailyRecordRepository — uploadImage', () {
    test('delegates to data source', () async {
      const input = DailyRecordImageUploadInput(
        bytes: [0, 1, 2],
        contentType: 'image/jpeg',
        sizeBytes: 3,
      );
      final result = await repository.uploadImage(input);
      expect(result.objectKey, 'test-key');
    });
  });

  group('LucentDailyRecordRepository — generateCandidates', () {
    test('delegates to data source', () async {
      final result = await repository.generateCandidates(
        text: '喝了一杯水',
        occurredAt: '2026-07-12',
      );
      expect(result.locale, 'zh');
      expect(result.items, hasLength(1));
    });
  });

  group('LucentDailyRecordRepository — create', () {
    test(
      'inserts optimistic copy, creates remotely, and confirms sync',
      () async {
        when(
          () => dao.insertOptimistic(any(), any()),
        ).thenAnswer((_) async => 'local_temp');
        when(() => dao.confirmSync(any(), any())).thenAnswer((_) async {});

        final result = await repository.create(_dummyCreateInput);

        expect(result.id, 'remote-create-1');
        verify(() => dao.insertOptimistic(any(), any())).called(1);
        verify(() => dao.confirmSync(any(), any())).called(1);
      },
    );

    test(
      'enqueues pending sync and returns optimistic item on network failure',
      () async {
        when(
          () => dao.insertOptimistic(any(), any()),
        ).thenAnswer((_) async => 'local_temp');
        when(
          () => pendingSyncDao.enqueue(
            entityType: any(named: 'entityType'),
            entityId: any(named: 'entityId'),
            operation: any(named: 'operation'),
            payload: any(named: 'payload'),
          ),
        ).thenAnswer((_) async => 'pending-id');

        dataSource.createShouldFail = true;

        final result = await repository.create(_dummyCreateInput);

        expect(result.id, startsWith('local_'));
        expect(result.source, 'local');
        verify(
          () => pendingSyncDao.enqueue(
            entityType: 'daily_record',
            entityId: any(named: 'entityId'),
            operation: 'create',
            payload: any(named: 'payload'),
          ),
        ).called(1);
        expect(syncWorker.flushCalled, isTrue);
      },
    );

    test('does not enqueue when pendingSyncDao is null', () async {
      repository = LucentDailyRecordRepository(
        dataSource: dataSource,
        dao: dao,
      );

      when(
        () => dao.insertOptimistic(any(), any()),
      ).thenAnswer((_) async => 'local_temp');
      dataSource.createShouldFail = true;

      final result = await repository.create(_dummyCreateInput);

      expect(result.id, startsWith('local_'));
      verifyNever(
        () => pendingSyncDao.enqueue(
          entityType: any(named: 'entityType'),
          entityId: any(named: 'entityId'),
          operation: any(named: 'operation'),
          payload: any(named: 'payload'),
        ),
      );
    });
  });

  group('LucentDailyRecordRepository — update', () {
    test('updates cache with confirmed server response on success', () async {
      when(() => dao.updateData(any(), any())).thenAnswer((_) async {});

      final result = await repository.update('item-1', _dummyUpdateInput);

      expect(result.id, 'remote-update-1');
      verify(() => dao.updateData('item-1', any())).called(1);
    });

    test(
      'enqueues pending sync and throws AppError on network failure',
      () async {
        when(
          () => pendingSyncDao.enqueue(
            entityType: any(named: 'entityType'),
            entityId: any(named: 'entityId'),
            operation: any(named: 'operation'),
            payload: any(named: 'payload'),
          ),
        ).thenAnswer((_) async => 'pending-id');

        dataSource.updateShouldFail = true;

        expect(
          () => repository.update('item-1', _dummyUpdateInput),
          throwsA(isA<AppError>()),
        );

        // Wait for the async enqueue to complete
        await Future.delayed(Duration.zero);

        verify(
          () => pendingSyncDao.enqueue(
            entityType: 'daily_record',
            entityId: 'item-1',
            operation: 'update',
            payload: any(named: 'payload'),
          ),
        ).called(1);
        expect(syncWorker.flushCalled, isTrue);
      },
    );
  });

  group('LucentDailyRecordRepository — delete', () {
    test('deletes from remote and cache on success', () async {
      when(() => dao.deleteById(any())).thenAnswer((_) async {});

      await repository.delete('item-1');

      verify(() => dao.deleteById('item-1')).called(1);
    });

    test(
      'enqueues pending sync and throws AppError on network failure',
      () async {
        when(
          () => pendingSyncDao.enqueue(
            entityType: any(named: 'entityType'),
            entityId: any(named: 'entityId'),
            operation: any(named: 'operation'),
            payload: any(named: 'payload'),
          ),
        ).thenAnswer((_) async => 'pending-id');

        dataSource.deleteShouldFail = true;

        expect(() => repository.delete('item-1'), throwsA(isA<AppError>()));

        await Future.delayed(Duration.zero);

        verify(
          () => pendingSyncDao.enqueue(
            entityType: 'daily_record',
            entityId: 'item-1',
            operation: 'delete',
            payload: any(named: 'payload'),
          ),
        ).called(1);
        expect(syncWorker.flushCalled, isTrue);
      },
    );
  });

  group('LucentDailyRecordRepository — fetchRecordsResult extension', () {
    test('returns Success on normal fetch', () async {
      when(
        () => dao.fetchByDate('2026-07-12', kind: null),
      ).thenAnswer((_) async => [_dummyJson]);

      final result = await repository.fetchRecordsResult('2026-07-12');

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, isNotNull);
    });

    test('returns Failure on DioException', () async {
      when(
        () => dao.fetchByDate('2026-07-12', kind: null),
      ).thenAnswer((_) async => []);
      dataSource.fetchRecordsShouldFail = true;

      final result = await repository.fetchRecordsResult('2026-07-12');

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<AppError>());
    });
  });
}

// ---------------------------------------------------------------------------
// Fakes / Mocks
// ---------------------------------------------------------------------------

class _FakeDailyRecordRemoteDataSource extends DailyRecordRemoteDataSource {
  _FakeDailyRecordRemoteDataSource()
    : super(
        api: lucent.LucentClient(
          Dio(BaseOptions(baseUrl: 'http://localhost')),
        ).dailyRecords,
        dio: Dio(),
      );

  bool fetchRecordsShouldFail = false;
  bool createShouldFail = false;
  bool updateShouldFail = false;
  bool deleteShouldFail = false;

  @override
  Future<DailyRecordListData> fetchRecords(
    String date, {
    String? kind,
    int page = 1,
    int pageSize = 50,
  }) async {
    if (fetchRecordsShouldFail) {
      throw DioException(
        requestOptions: RequestOptions(path: '/daily-records'),
        type: DioExceptionType.connectionError,
      );
    }
    return DailyRecordListData(
      items: [
        _makeItem(id: 'remote-1'),
        _makeItem(id: 'remote-2'),
      ],
      total: 2,
    );
  }

  @override
  Future<DailyRecordSummaryData> fetchSummary(String date) async {
    return DailyRecordSummaryData(
      summaries: [
        DailyRecordSummary(
          kind: DailyRecordKind.water,
          count: 3,
          latest: _makeItem(id: 'latest-1'),
        ),
      ],
    );
  }

  @override
  Future<DailyRecordItem> get(String id) async {
    return _makeItem(id: 'remote-get-1');
  }

  @override
  Future<DailyRecordAttachmentInput> uploadImage(
    DailyRecordImageUploadInput input,
  ) async {
    return const DailyRecordAttachmentInput(objectKey: 'test-key');
  }

  @override
  Future<DailyRecordCandidateResult> generateCandidates({
    required String text,
    required String occurredAt,
  }) async {
    return DailyRecordCandidateResult(
      locale: 'zh',
      generatedAt: '2026-07-12T10:00:00Z',
      confirmationHint: '确认',
      items: [
        DailyRecordCandidateItem(
          kind: DailyRecordKind.water,
          occurredAt: occurredAt,
          title: '喝水',
          value: '200',
          unit: 'ml',
          rationale: '用户输入',
        ),
      ],
    );
  }

  @override
  Future<DailyRecordItem> create(DailyRecordCreateInput input) async {
    if (createShouldFail) {
      throw DioException(
        requestOptions: RequestOptions(path: '/daily-records'),
        type: DioExceptionType.connectionError,
      );
    }
    return _makeItem(id: 'remote-create-1', source: 'remote');
  }

  @override
  Future<DailyRecordItem> update(
    String id,
    DailyRecordUpdateInput input,
  ) async {
    if (updateShouldFail) {
      throw DioException(
        requestOptions: RequestOptions(path: '/daily-records/$id'),
        type: DioExceptionType.connectionError,
      );
    }
    return _makeItem(id: 'remote-update-1', source: 'remote');
  }

  @override
  Future<void> delete(String id) async {
    if (deleteShouldFail) {
      throw DioException(
        requestOptions: RequestOptions(path: '/daily-records/$id'),
        type: DioExceptionType.connectionError,
      );
    }
  }
}

class _MockDailyRecordDao extends Mock implements DailyRecordDao {}

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

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

DailyRecordItem _makeItem({required String id, String? source}) {
  return DailyRecordItem(
    id: id,
    kind: DailyRecordKind.water,
    occurredAt: '2026-07-12',
    occurredTime: '10:00',
    title: '喝水',
    value: '200',
    unit: 'ml',
    source: source,
    createdAt: '2026-07-12T10:00:00Z',
    updatedAt: '2026-07-12T10:00:00Z',
  );
}

const _dummyCreateInput = DailyRecordCreateInput(
  kind: DailyRecordKind.water,
  occurredAt: '2026-07-12',
  title: '喝水',
  value: '200',
  unit: 'ml',
);

const _dummyUpdateInput = DailyRecordUpdateInput(title: 'Updated title');

const _dummyImageUploadInput = DailyRecordImageUploadInput(
  bytes: [0, 1, 2],
  contentType: 'image/jpeg',
  sizeBytes: 3,
);

final _dummyJson = DailyRecordJsonCodec.itemToJson(_makeItem(id: 'json-1'));
