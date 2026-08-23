import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/report/domain/entities/dashboard.dart';

/// Repository boundary: every expected recoverable failure (network, server
/// business failure) is a `TaskEither` Left produced via
/// `LucentErrorMapper.fromObject`; a successful response is a Right.
abstract interface class ReportRepository {
  TaskEither<LucentFailure, ReportDashboard> fetchDashboard(
    ReportDashboardQuery query,
  );

  /// Signed-out preview value is pure local data — stays a plain [Future]
  /// (today `signedOutDashboard` precedent).
  Future<ReportDashboard> get signedOutDashboard;
}
