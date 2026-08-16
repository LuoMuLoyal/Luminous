import 'package:luminous/features/medicine/domain/entities/reminder.dart';

/// Domain interface for reading and writing medicine reminders.
///
/// Implemented by [MedicineReminderRemoteDataSource] in the data layer.
/// Consumers in other features should depend on this interface, not the
/// concrete data source.
abstract interface class ReminderRepository {
  /// Fetches all active reminders.
  Future<List<MedicineReminderItem>> fetchActive();

  /// Fetches all reminders (active and inactive).
  Future<List<MedicineReminderItem>> fetchAll();

  /// Fetches reminder delivery logs.
  Future<List<ReminderDeliveryItem>> fetchDeliveries({
    String? date,
    int limit = 20,
  });

  /// Creates a new reminder.
  Future<MedicineReminderItem> create(MedicineReminderWriteInput input);

  /// Updates an existing reminder.
  Future<MedicineReminderItem> update(
    String id,
    MedicineReminderWriteInput input,
  );

  /// Deletes a reminder.
  Future<void> delete(String id);

  /// Upserts a whole medicine reminder group in a single transaction.
  ///
  /// Slots carrying an [MedicineReminderSlotUpsertInput.id] are updated,
  /// slots without one are created, and existing group slots missing from the
  /// input are soft-deleted server-side. Returns the resulting group items.
  Future<List<MedicineReminderItem>> upsertGroup(
    MedicineReminderGroupUpsertInput input,
  );

  /// Reports that a local notification for the reminder was delivered
  /// (idempotent on the server: the same `reminderId|date|time` key writes a
  /// `channel='local'`, `status='delivered'` audit row at most once).
  Future<void> reportLocalReceipt({
    required String reminderId,
    required String scheduledDate,
    required String scheduledTime,
  });

  /// Reports the client's local scheduling capability so the server only
  /// falls back to JPush when local delivery is unconfirmed or unavailable.
  ///
  /// [state] is one of `active` / `unavailable` / `disabled`.
  Future<void> reportLocalCapability(String state);
}
