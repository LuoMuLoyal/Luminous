import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_reminder_providers.dart';

void main() {
  test('initial state', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final s = c.read(medicineReminderFormProvider);
    expect(s.isSaving, false);
    expect(s.errorMessage, isNull);
    expect(s.saved, false);
  });

  test('times sort by hour then minute', () {
    final times = <MedicineReminderTimeInput>[
      const MedicineReminderTimeInput(hour: 10, minute: 30),
      const MedicineReminderTimeInput(hour: 8, minute: 0),
      const MedicineReminderTimeInput(hour: 10, minute: 0),
    ];
    times.sort((a, b) {
      final h = a.hour.compareTo(b.hour);
      return h != 0 ? h : a.minute.compareTo(b.minute);
    });
    expect(times[0].hour, 8);
    expect(times[2].hour, 10);
    expect(times[2].minute, 30);
  });
}
