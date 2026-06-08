import 'package:test/test.dart';
import 'package:lucent_openapi/lucent_openapi.dart';

// tests for CreateMedicineReminderDto
void main() {
  final CreateMedicineReminderDto? instance = /* CreateMedicineReminderDto(...) */ null;
  // TODO add properties to the entity

  group(CreateMedicineReminderDto, () {
    // Linked current medicine id.
    // String currentMedicineId
    test('to test the property `currentMedicineId`', () async {
      // TODO
    });

    // Reminder label.
    // Object label
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

    // Whether this reminder is active.
    // bool isActive (default value: true)
    test('to test the property `isActive`', () async {
      // TODO
    });

    // User note.
    // Object note
    test('to test the property `note`', () async {
      // TODO
    });

  });
}
