import 'package:luminous/core/network/client_providers.dart';
import 'package:luminous/features/report/data/repositories/lucent_review.dart';
import 'package:luminous/features/report/domain/repositories/review.dart';
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
  return LucentReviewRepository(dataSource: dataSource);
}
