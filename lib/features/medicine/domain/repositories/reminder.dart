import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/medicine/domain/entities/reminder.dart';

/// Domain interface for reading and writing medicine reminders.
///
/// Implemented by [MedicineReminderRemoteDataSource] in the data layer.
/// Consumers in other features should depend on this interface, not the
/// concrete data source.
///
/// Repository boundary: every expected recoverable failure (network, server
/// business failure) is a `TaskEither` Left produced via
/// `LucentErrorMapper.fromObject`; a legal empty item set stays a Right.
abstract interface class ReminderRepository {
  /// Fetches all active reminders.
  TaskEither<LucentFailure, List<MedicineReminderItem>> fetchActive();

  /// Fetches all reminders (active and inactive).
  TaskEither<LucentFailure, List<MedicineReminderItem>> fetchAll();

  /// Fetches reminder delivery logs.
  TaskEither<LucentFailure, List<ReminderDeliveryItem>> fetchDeliveries({
    String? date,
    int limit = 20,
  });

  /// Creates a new reminder.
  TaskEither<LucentFailure, MedicineReminderItem> create(
    MedicineReminderWriteInput input,
  );

  /// Updates an existing reminder.
  TaskEither<LucentFailure, MedicineReminderItem> update(
    String id,
    MedicineReminderWriteInput input,
  );

  /// Deletes a reminder.
  TaskEither<LucentFailure, void> delete(String id);

  /// Upserts a whole medicine reminder group in a single transaction.
  ///
  /// Slots carrying an [MedicineReminderSlotUpsertInput.id] are updated,
  /// slots without one are created, and existing group slots missing from the
  /// input are soft-deleted server-side. Returns the resulting group items.
  TaskEither<LucentFailure, List<MedicineReminderItem>> upsertGroup(
    MedicineReminderGroupUpsertInput input,
  );

  /// Reports that a local notification for the reminder was delivered
  /// (idempotent on the server: the same `reminderId|date|time` key writes a
  /// `channel='local'`, `status='delivered'` audit row at most once).
  TaskEither<LucentFailure, void> reportLocalReceipt({
    required String reminderId,
    required String scheduledDate,
    required String scheduledTime,
  });

  /// Reports the client's local scheduling capability so the server only
  /// falls back to JPush when local delivery is unconfirmed or unavailable.
  ///
  /// [state] is one of `active` / `unavailable` / `disabled`.
  TaskEither<LucentFailure, void> reportLocalCapability(String state);
}
