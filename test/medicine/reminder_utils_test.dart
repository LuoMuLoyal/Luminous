import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/medicine/data/datasources/reminder_remote.dart';
import 'package:luminous/features/medicine/presentation/utils/reminder_formatters.dart';

void main() {
  setUpAll(initializeDateFormatting);
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
    test('delivered returns badgeCheck', () {
      expect(deliveryStatusIcon('delivered'), SemanticIcons.reportAdherence);
    });
    test('failed returns circleAlert', () {
      expect(deliveryStatusIcon('failed'), SemanticIcons.statusError);
    });
    test('default returns clock3', () {
      expect(deliveryStatusIcon('unknown'), SemanticIcons.statusPending);
    });
  });

  group('deliveryStatusColor', () {
    final colors = FTheme.neutral.light.touch.colors;
    test('delivered returns primary', () {
      expect(deliveryStatusColor('delivered', colors), SemanticColor.primary);
    });
    test('failed returns destructive', () {
      expect(deliveryStatusColor('failed', colors), SemanticColor.destructive);
    });
    test('default returns muted', () {
      expect(deliveryStatusColor('unknown', colors), SemanticColor.neutral);
    });
  });

  group('dateTimeTimeLabel', () {
    test('returns HH:mm from ISO string', () {
      expect(
        dateTimeTimeLabel('2026-06-10T08:30:00', const Locale('zh')),
        '08:30',
      );
    });
    test('handles null/empty', () {
      expect(dateTimeTimeLabel('', const Locale('zh')), '');
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
