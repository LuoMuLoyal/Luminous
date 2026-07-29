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
}
