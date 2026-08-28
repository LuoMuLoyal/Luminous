import 'package:luminous/core/database/connection_providers.dart';
import 'package:luminous/core/network/client_providers.dart';
import 'package:luminous/features/review/data/datasources/dashboard_remote.dart';
import 'package:luminous/features/review/data/repositories/lucent_dashboard.dart';
import 'package:luminous/features/review/data/repositories/lucent_review.dart';
import 'package:luminous/features/review/domain/repositories/dashboard.dart';
import 'package:luminous/features/review/domain/repositories/review.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'review.g.dart';

@riverpod
ReviewRemoteDataSource reviewRemoteDataSource(Ref ref) {
  final api = ref.watch(lucentClientProvider).reports;
  return ReviewRemoteDataSource(api: api);
}

@riverpod
ReviewRepository reviewRepository(Ref ref) {
  final dataSource = ref.watch(reviewRemoteDataSourceProvider);
  final dao = ref.watch(reviewDaoProvider);
  return LucentReviewRepository(dataSource: dataSource, dao: dao);
}

@riverpod
ReviewDashboardRemoteDataSource reviewDashboardRemoteDataSource(Ref ref) {
  final api = ref.watch(lucentClientProvider).reports;
  final dio = ref.watch(lucentDioClientProvider).dio;
  return ReviewDashboardRemoteDataSource(api: api, dio: dio);
}

@riverpod
ReviewDashboardRepository reviewDashboardRepository(Ref ref) {
  final dataSource = ref.watch(reviewDashboardRemoteDataSourceProvider);
  final dao = ref.watch(reviewDashboardDaoProvider);
  return LucentReviewDashboardRepository(dataSource: dataSource, dao: dao);
}
