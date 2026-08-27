import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';

/// Dashboard repository boundary.
///
/// Every expected recoverable failure (network, server business failure) is a
/// `TaskEither` Left produced via `LucentErrorMapper.fromObject`; a successful
/// response is a Right.
abstract interface class ReviewDashboardRepository {
  TaskEither<LucentFailure, ReviewDashboard> fetchDashboard(
    ReviewDashboardQuery query,
  );

  /// Signed-out preview value is pure local data — stays a plain [Future]
  /// (today `signedOutDashboard` precedent).
  Future<ReviewDashboard> get signedOutDashboard;
}
