import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/network/lucent_network_providers.dart';
import 'package:luminous/features/record/data/datasources/daily_record_remote_data_source.dart';
import 'package:luminous/features/record/data/repositories/lucent_daily_record_repository.dart';
import 'package:luminous/features/record/domain/repositories/daily_record_repository.dart';

final dailyRecordRemoteDataSourceProvider = Provider<DailyRecordRemoteDataSource>((ref) {
  final api = ref.watch(lucentDailyRecordsApiProvider);
  final dio = ref.watch(lucentDioClientProvider).dio;
  return DailyRecordRemoteDataSource(api: api, dio: dio);
});

final dailyRecordRepositoryProvider = Provider<DailyRecordRepository>((ref) {
  final dataSource = ref.watch(dailyRecordRemoteDataSourceProvider);
  return LucentDailyRecordRepository(dataSource: dataSource);
});
