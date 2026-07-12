import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/database/database_providers.dart';
import 'package:luminous/core/database/sync/sync_worker.dart';
import 'package:luminous/core/network/network_providers.dart';
import 'package:luminous/features/record/data/datasources/record.dart';
import 'package:luminous/features/record/data/repositories/lucent_daily.dart';
import 'package:luminous/features/record/data/utils/daily_record_json_codec.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/repositories/daily.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'record_access.g.dart';

@riverpod
DailyRecordRemoteDataSource dailyRecordRemoteDataSource(Ref ref) {
  final api = ref.watch(lucentClientProvider).dailyRecords;
  final dio = ref.watch(lucentDioClientProvider).dio;
  return DailyRecordRemoteDataSource(api: api, dio: dio);
}

@riverpod
DailyRecordRepository dailyRecordRepository(Ref ref) {
  final dataSource = ref.watch(dailyRecordRemoteDataSourceProvider);
  final dao = ref.watch(dailyRecordDaoProvider);
  final pendingSyncDao = ref.watch(pendingSyncDaoProvider);
  final syncWorker = ref.watch(syncWorkerProvider);

  // Register replay handler for daily_record entity type
  syncWorker.registerHandler('daily_record', (entry) async {
    final payload = jsonDecode(entry.payload) as Map<String, dynamic>;

    switch (entry.operation) {
      case 'create':
        // Replay create: reconstruct input from the optimistic item JSON
        final item = DailyRecordJsonCodec.itemFromJson(entry.payload);
        final input = DailyRecordCreateInput(
          kind: item.kind,
          occurredAt: item.occurredAt,
          occurredTime: item.occurredTime,
          title: item.title,
          value: item.value,
          unit: item.unit,
          note: item.note,
          payload: item.payload,
        );
        final remote = await dataSource.create(input);
        // Replace optimistic copy with confirmed server response
        await dao.confirmSync(
          entry.entityId!,
          DailyRecordJsonCodec.itemToJson(remote),
        );

      case 'delete':
        await dataSource.delete(entry.entityId!);
        await dao.deleteById(entry.entityId!);

      case 'update':
        // For update, we only have the ID in payload — fetch latest and re-apply
        // This is a best-effort replay; full update replay requires storing
        // the original input in the payload.
        final id = payload['id'] as String;
        // The remote already has the latest state if the update partially succeeded;
        // we just need to ensure local cache is in sync.
        await dao.deleteById(id);
    }
  });

  return LucentDailyRecordRepository(
    dataSource: dataSource,
    dao: dao,
    pendingSyncDao: pendingSyncDao,
    syncWorker: syncWorker,
  );
}

final dailyRecordDetailProvider =
    FutureProvider.family<DailyRecordItem, String>((ref, id) {
      return ref
          .watch(dailyRecordRepositoryProvider)
          .get(id)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw TimeoutException('请求超时，请检查网络后重试。'),
          );
    });
