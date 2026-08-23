import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/mine/domain/entities/dashboard.dart';

/// Repository boundary for the Mine dashboard.
///
/// Every expected recoverable failure (network, server business failure) is a
/// `TaskEither` Left produced via `LucentErrorMapper.fromObject`; a successful
/// response is a Right.
abstract interface class MineRepository {
  /// Returns the authenticated Mine dashboard, aggregating the user profile /
  /// health archive / current medicines from the health-context snapshot.
  ///
  /// A snapshot load failure (network or server) is a Left; the dashboard is
  /// never fabricated from default values on failure.
  TaskEither<LucentFailure, MineDashboard> fetchDashboard();

  /// Returns the signed-out (guest) dashboard.
  ///
  /// Pure local value — never fails, stays a plain [Future] (today
  /// `signedOutDashboard` precedent).
  Future<MineDashboard> get signedOutDashboard;
}
