import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/medicine/data/datasources/medicine_reminder_remote_data_source.dart';
import 'package:luminous/features/medicine/presentation/utils/medicine_reminder_formatters.dart';

void main() {
  group('compareReminderTime', () {
    test('sorts by scheduledHour then scheduledMinute', () {
      final a = _item(8, 0);
      final b = _item(9, 0);
      expect(compareReminderTime(a, b), lessThan(0));
      expect(compareReminderTime(b, a), greaterThan(0));
      expect(compareReminderTime(a, a), 0);
    });
  });

  group('deliveryStatusIcon', () {
    test('delivered returns check_circle', () {
      expect(
        deliveryStatusIcon('delivered'),
        Icons.check_circle_outline_rounded,
      );
    });
    test('failed returns error', () {
      expect(deliveryStatusIcon('failed'), Icons.error_outline_rounded);
    });
    test('default returns schedule', () {
      expect(deliveryStatusIcon('unknown'), Icons.schedule_rounded);
    });
  });

  group('deliveryStatusColor', () {
    final surface = AppThemeSurface.light;
    test('delivered returns teal', () {
      expect(deliveryStatusColor('delivered', surface), surface.teal);
    });
    test('failed returns error', () {
      expect(deliveryStatusColor('failed', surface), surface.error);
    });
    test('default returns mute', () {
      expect(deliveryStatusColor('unknown', surface), surface.mute);
    });
  });

  group('dateTimeTimeLabel', () {
    test('returns HH:mm from ISO string', () {
      expect(dateTimeTimeLabel('2026-06-10T08:30:00.000Z'), '08:30');
    });
    test('handles null/empty', () {
      expect(dateTimeTimeLabel(''), '');
    });
  });

  group('formatDateInput', () {
    test('returns YYYY-MM-DD from DateTime', () {
      final result = formatDateInput(DateTime(2026, 6, 10));
      expect(result, '2026-06-10');
    });
    test('returns empty for null', () {
      expect(formatDateInput(null), '');
    });
  });

  group('trimmedOrNull', () {
    test('returns null for empty', () => expect(trimmedOrNull(''), isNull));
    test(
      'returns null for whitespace',
      () => expect(trimmedOrNull('   '), isNull),
    );
    test(
      'returns trimmed value',
      () => expect(trimmedOrNull('  hello  '), 'hello'),
    );
  });
}

// Minimal MedicineReminderItem for comparator testing.
MedicineReminderItem _item(int hour, int minute) {
  return MedicineReminderItem(
    id: 'r-1',
    scheduledHour: hour,
    scheduledMinute: minute,
    isActive: true,
    createdAt: '2026-06-10T08:00:00.000Z',
    updatedAt: '2026-06-10T08:00:00.000Z',
  );
}
