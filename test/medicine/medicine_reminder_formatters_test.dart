import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/features/medicine/data/datasources/medicine_reminder_remote_data_source.dart';
import 'package:luminous/features/medicine/presentation/utils/medicine_reminder_formatters.dart';

MedicineReminderItem _r({String id = '1', int h = 9, int m = 0}) {
  return MedicineReminderItem(
    id: id,
    scheduledHour: h,
    scheduledMinute: m,
    isActive: true,
    createdAt: '2026-06-15T00:00:00Z',
    updatedAt: '2026-06-15T00:00:00Z',
  );
}

void main() {
  group('compareReminderTime', () {
    test('sorts by hour', () {
      expect(compareReminderTime(_r(h: 9), _r(h: 12)), lessThan(0));
      expect(compareReminderTime(_r(h: 12), _r(h: 9)), greaterThan(0));
    });
    test('equal hour/minute returns 0', () {
      expect(compareReminderTime(_r(h: 10, m: 30), _r(h: 10, m: 30)), 0);
    });
    test('breaks ties by minute', () {
      expect(compareReminderTime(_r(h: 8, m: 0), _r(h: 8, m: 15)), lessThan(0));
    });
  });

  group('dateOnly', () {
    test('strips time', () {
      final r = dateOnly(DateTime(2026, 6, 15, 9, 45));
      expect(r.hour, 0);
      expect(r.minute, 0);
    });
  });

  group('parseDateOnly', () {
    test('null/empty returns null', () {
      expect(parseDateOnly(null), isNull);
      expect(parseDateOnly(''), isNull);
    });
    test('parses date and strips time', () {
      final r = parseDateOnly('2026-06-15');
      expect(r!.year, 2026);
      expect(r.hour, 0);
    });
  });

  group('formatDateInput', () {
    test('null returns empty', () {
      expect(formatDateInput(null), '');
    });
    test('YYYY-MM-DD', () {
      expect(formatDateInput(DateTime(2026, 6, 15)), '2026-06-15');
    });
  });

  group('dateTimeTimeLabel', () {
    test('extracts HH:mm', () {
      expect(dateTimeTimeLabel('2026-06-15T09:45:00'), '09:45');
    });
    test('returns original on parse failure', () {
      expect(dateTimeTimeLabel('not-a-date'), 'not-a-date');
    });
  });

  group('deliveryStatusColor', () {
    final colors = FThemes.neutral.light.touch.colors;
    test('delivered → teal', () {
      expect(deliveryStatusColor('delivered', colors), const Color(0xFF0F766E));
    });
    test('failed → error', () {
      expect(deliveryStatusColor('failed', colors), colors.destructive);
    });
    test('scheduled → warningDeep', () {
      expect(
        deliveryStatusColor('scheduled', colors),
        const Color(0xFFB45309),
      );
    });
    test('unknown → mute', () {
      expect(deliveryStatusColor('?', colors), colors.mutedForeground);
    });
  });

  group('trimmedOrNull', () {
    test('trims and returns value', () {
      expect(trimmedOrNull('  hi  '), 'hi');
    });
    test('empty/whitespace returns null', () {
      expect(trimmedOrNull(''), isNull);
      expect(trimmedOrNull('  '), isNull);
    });
  });
}
