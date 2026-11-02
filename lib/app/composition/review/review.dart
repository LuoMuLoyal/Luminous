import 'package:luminous/core/database/connection_providers.dart';
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/features/review/data/repositories/lucent_review.dart';
import 'package:luminous/features/review/domain/repositories/review.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// `reviewDashboardRepositoryProvider` / `reviewDashboardRemoteDataSourceProvider`
// are assembled in `tokens/review_dashboard.dart` (the dashboard repository
// needs the design tokens, which `review/data/` may not import). They are
// re-exported here so consumers keep a single import, but this file must not be
// imported back by `tokens/review_dashboard.dart` — that would close an import
// cycle.
export 'package:luminous/app/composition/tokens/review_dashboard.dart'
    show
        reviewDashboardRemoteDataSourceProvider,
        reviewDashboardRepositoryProvider;

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
