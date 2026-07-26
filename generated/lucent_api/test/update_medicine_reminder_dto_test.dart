import 'package:test/test.dart';
import 'package:lucent_api/lucent_api.dart';

// tests for UpdateMedicineReminderDto
void main() {
  final UpdateMedicineReminderDto?
  instance = /* UpdateMedicineReminderDto(...) */ null;
  // TODO add properties to the entity

  group(UpdateMedicineReminderDto, () {
    // Linked current medicine id.
    // String currentMedicineId
    test('to test the property `currentMedicineId`', () async {
      // TODO
    });

    // Reminder label.
    // String label
    test('to test the property `label`', () async {
      // TODO
    });

    // Scheduled local hour, 0-23.
    // num scheduledHour
    test('to test the property `scheduledHour`', () async {
      // TODO
    });

    // Scheduled local minute, 0-59.
    // num scheduledMinute
    test('to test the property `scheduledMinute`', () async {
      // TODO
    });

    // Weekday numbers 0-6, where null means every day.
    // List<num> daysOfWeek
    test('to test the property `daysOfWeek`', () async {
      // TODO
    });

    // Date in YYYY-MM-DD format when the reminder starts. Use null to clear.
    // String startDate
    test('to test the property `startDate`', () async {
      // TODO
    });

    // Date in YYYY-MM-DD format when the reminder ends. Use null to clear.
    // String endDate
    test('to test the property `endDate`', () async {
      // TODO
    });

    // Whether this reminder is active.
    // bool isActive
    test('to test the property `isActive`', () async {
      // TODO
    });

    // User note.
    // String note
    test('to test the property `note`', () async {
      // TODO
    });
  });
}
