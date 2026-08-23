import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';

/// Domain interface for the record dashboard surface.
///
/// Repository boundary: every expected recoverable failure is a `TaskEither`
/// Left produced via `LucentErrorMapper.fromObject`. The secondary record
/// inputs (timeline records, daily summary) degrade to empty on failure
/// (recorded via talker — product behaviour), so a Left here means an
/// unexpected error.
abstract interface class RecordRepository {
  TaskEither<LucentFailure, RecordDashboard> fetchDashboard(
    DateTime selectedDate, {
    RecordEntryType? filterType,
  });

  /// Signed-out placeholder; a pure local value that cannot fail.
  Future<RecordDashboard> signedOutDashboard(
    DateTime selectedDate, {
    RecordEntryType? filterType,
  });
}
