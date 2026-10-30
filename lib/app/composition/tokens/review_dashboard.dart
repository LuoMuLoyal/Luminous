import 'package:luminous/app/composition/tokens/review_style.dart';
import 'package:luminous/core/database/connection_providers.dart';
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/features/review/data/datasources/dashboard_remote.dart';
import 'package:luminous/features/review/data/repositories/lucent_dashboard.dart';
import 'package:luminous/features/review/domain/repositories/dashboard.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'review_dashboard.g.dart';

/// Composition-root glue for the review dashboard.
///
/// The repository needs the dashboard design tokens (`app/composition/
/// tokens/review_style.dart`), which `review/data/` may not import. The data
/// provider file re-exports [reviewDashboardRepositoryProvider].
///
/// This file deliberately does **not** import `app/composition/review/
/// review.dart`: that file re-exports [reviewDashboardRepositoryProvider] for
/// its consumers, so importing it back would close an import cycle. The remote
/// data source provider is a plain `review/data/` provider, so it is declared
/// here where this file already depends on `review/data/` — `review/review.dart`
/// then only has to carry [reviewRepositoryProvider] and the re-export.

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
  return LucentReviewDashboardRepository(
    dataSource: dataSource,
    dao: dao,
    style: const ReviewDashboardStyle(),
  );
}
