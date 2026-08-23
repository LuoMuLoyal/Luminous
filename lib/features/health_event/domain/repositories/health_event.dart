import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';

import 'package:luminous/features/health_event/domain/entities/health_event.dart';

/// Repository interface for user health events.
///
/// Repository boundary: every expected recoverable failure (network, server
/// business failure) is a `TaskEither` Left produced via
/// `LucentErrorMapper.fromObject`; a successful response is a Right. A legal
/// empty history stays a Right, as does "no active event" / "event not
/// found" (404) — those are normal business states, not failures. A missing
/// event body in a write/detail response is a protocol invariant (kept as a
/// recorded `StateError`, mapped to `Left(unknown)` with the cause preserved).
abstract interface class HealthEventRepository {
  /// Returns the current active health event, or null when there is none.
  ///
  /// "No active event" is a normal business state: the server answers 404 and
  /// the repository keeps that as `Right(null)` (documented 404 semantics,
  /// `plans/2026-08-23-luminous-error-migration-order.md` Task 5 Step 1 —
  /// 未配置可选数据保持 Right).
  TaskEither<LucentFailure, HealthEvent?> fetchActive();

  /// Returns one health event by id, or null when it does not exist.
  ///
  /// A not-found (404) event detail is a normal business state and stays
  /// `Right(null)`.
  TaskEither<LucentFailure, HealthEvent?> fetchById(String eventId);

  /// Returns the user health event history.
  ///
  /// A legal empty history stays a Right.
  TaskEither<LucentFailure, List<HealthEvent>> fetchHistory();

  TaskEither<LucentFailure, HealthEvent> create({
    required String title,
    String? reasonRecordId,
    List<String> currentMedicineIds = const [],
  });

  TaskEither<LucentFailure, HealthEvent> checkIn({
    required String eventId,
    required String date,
    required HealthEventOutcome outcome,
  });

  TaskEither<LucentFailure, HealthEvent> end({
    required String eventId,
    required HealthEventOutcome outcome,
  });
}
