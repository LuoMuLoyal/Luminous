import 'package:luminous/app/composition/review/review.dart';
import 'package:luminous/app/composition/tokens/review_style.dart';
import 'package:luminous/core/database/connection_providers.dart';
import 'package:luminous/features/review/data/repositories/lucent_dashboard.dart';
import 'package:luminous/features/review/domain/repositories/dashboard.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'review_dashboard.g.dart';

/// Composition-root glue for the review dashboard.
///
/// The repository needs the dashboard design tokens (`app/composition/
/// review_style.dart`), which `review/data/` may not import. The data
/// provider file re-exports [reviewDashboardRepositoryProvider].

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
