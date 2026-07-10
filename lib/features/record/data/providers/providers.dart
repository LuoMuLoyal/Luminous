import 'dart:async';
import 'package:luminous/core/network/network_providers.dart';
import 'package:luminous/features/record/data/datasources/remote_data_source.dart';
import 'package:luminous/features/record/data/repositories/lucent_daily_repository.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/repositories/daily_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@riverpod
DailyRecordRemoteDataSource dailyRecordRemoteDataSource(Ref ref) {
  final api = ref.watch(lucentClientProvider).dailyRecords;
  final dio = ref.watch(lucentDioClientProvider).dio;
  return DailyRecordRemoteDataSource(api: api, dio: dio);
}

@riverpod
DailyRecordRepository dailyRecordRepository(Ref ref) {
  final dataSource = ref.watch(dailyRecordRemoteDataSourceProvider);
  return LucentDailyRecordRepository(dataSource: dataSource);
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
