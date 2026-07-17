import 'package:luminous/core/network/network_providers.dart';
import 'package:luminous/features/report/data/datasources/report.dart';
import 'package:luminous/features/report/data/repositories/lucent.dart';
import 'package:luminous/features/report/domain/repositories/report.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'repository.g.dart';

@riverpod
ReportRemoteDataSource reportRemoteDataSource(Ref ref) {
  final api = ref.watch(lucentClientProvider).reports;
  final dio = ref.watch(lucentDioClientProvider).dio;
  return ReportRemoteDataSource(api: api, dio: dio);
}

@riverpod
ReportRepository reportRepository(Ref ref) {
  final dataSource = ref.watch(reportRemoteDataSourceProvider);
  return LucentReportRepository(dataSource: dataSource);
}
