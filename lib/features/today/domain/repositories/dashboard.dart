import 'package:fpdart/fpdart.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/shared/domain/failure.dart';

abstract interface class TodayRepository {
  TaskEither<LucentFailure, TodayDashboard> fetchDashboard();

  /// Signed-out placeholder; a pure local value that cannot fail.
  Future<TodayDashboard> get signedOutDashboard;
}
