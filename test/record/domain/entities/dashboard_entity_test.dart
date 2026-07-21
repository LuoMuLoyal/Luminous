import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';

void main() {
  group('RecordDashboard.signedOut', () {
    final testDate = DateTime(2026, 7, 12); // Sunday

    test('uses the provided selectedDate', () {
      final dashboard = RecordDashboard.signedOut(testDate);

      expect(dashboard.selectedDate, testDate);
      expect(dashboard.selectedDay, 12);
    });

    test('generates 7 week days starting from Monday', () {
      final dashboard = RecordDashboard.signedOut(testDate);

      expect(dashboard.weekDays.length, 7);
      // 2026-07-12 is Sunday (weekday = 7), so Monday is 2026-07-06
      expect(dashboard.weekDays.first.date, DateTime(2026, 7, 6));
      expect(dashboard.weekDays.last.date, DateTime(2026, 7, 12));
    });

    test('marks the selected date as selected in week days', () {
      final dashboard = RecordDashboard.signedOut(testDate);

      final selectedDay = dashboard.weekDays.firstWhere((d) => d.day == 12);
      expect(selectedDay.selected, isTrue);
    });

    test('non-selected days are not marked as selected', () {
      final dashboard = RecordDashboard.signedOut(testDate);

      final nonSelectedDays = dashboard.weekDays.where((d) => d.day != 12);
      for (final day in nonSelectedDays) {
        expect(day.selected, isFalse);
      }
    });

    test('week days have empty markers', () {
      final dashboard = RecordDashboard.signedOut(testDate);

      for (final day in dashboard.weekDays) {
        expect(day.markers, isEmpty);
      }
    });

    test('week days have correct weekday keys', () {
      final dashboard = RecordDashboard.signedOut(testDate);

      // Monday to Sunday
      expect(dashboard.weekDays[0].weekdayKey, RecordCopyKey.weekdayMon);
      expect(dashboard.weekDays[1].weekdayKey, RecordCopyKey.weekdayTue);
      expect(dashboard.weekDays[2].weekdayKey, RecordCopyKey.weekdayWed);
      expect(dashboard.weekDays[3].weekdayKey, RecordCopyKey.weekdayThu);
      expect(dashboard.weekDays[4].weekdayKey, RecordCopyKey.weekdayFri);
      expect(dashboard.weekDays[5].weekdayKey, RecordCopyKey.weekdaySat);
      expect(dashboard.weekDays[6].weekdayKey, RecordCopyKey.weekdaySun);
    });

    test('has empty month days', () {
      final dashboard = RecordDashboard.signedOut(testDate);

      expect(dashboard.monthDays, isEmpty);
    });

    test('has 7 default quick actions', () {
      final dashboard = RecordDashboard.signedOut(testDate);

      expect(dashboard.quickActions.length, 7);
      final types = dashboard.quickActions.map((a) => a.type).toSet();
      expect(types, contains(RecordEntryType.symptom));
      expect(types, contains(RecordEntryType.medication));
      expect(types, contains(RecordEntryType.water));
      expect(types, contains(RecordEntryType.meal));
      expect(types, contains(RecordEntryType.sleep));
      expect(types, contains(RecordEntryType.mood));
      expect(types, contains(RecordEntryType.note));
    });

    test('quick actions are not locked by default', () {
      final dashboard = RecordDashboard.signedOut(testDate);

      for (final action in dashboard.quickActions) {
        expect(action.locked, isFalse);
      }
    });

    test('has 7 default filters', () {
      final dashboard = RecordDashboard.signedOut(testDate);

      expect(dashboard.filters.length, 7);
      for (final filter in dashboard.filters) {
        expect(filter.selected, isFalse);
        expect(filter.locked, isFalse);
      }
    });

    test('has empty summary items', () {
      final dashboard = RecordDashboard.signedOut(testDate);

      expect(dashboard.summary.items, isEmpty);
    });

    test('has empty timeline', () {
      final dashboard = RecordDashboard.signedOut(testDate);

      expect(dashboard.timeline, isEmpty);
    });

    test('has empty trends', () {
      final dashboard = RecordDashboard.signedOut(testDate);

      expect(dashboard.trends, isEmpty);
    });
  });

  group('RecordDashboard.signedOut week calculation', () {
    test('correctly calculates Monday for a Wednesday', () {
      final wednesday = DateTime(2026, 7, 8); // Wednesday
      final dashboard = RecordDashboard.signedOut(wednesday);

      expect(dashboard.weekDays.first.date, DateTime(2026, 7, 6)); // Monday
      expect(dashboard.weekDays[2].date, wednesday);
      expect(dashboard.weekDays[2].selected, isTrue);
    });

    test('correctly calculates Monday for a Monday', () {
      final monday = DateTime(2026, 7, 6); // Monday
      final dashboard = RecordDashboard.signedOut(monday);

      expect(dashboard.weekDays.first.date, monday);
      expect(dashboard.weekDays.first.selected, isTrue);
    });

    test('correctly handles month boundary', () {
      final aug1 = DateTime(2026, 8, 1); // Saturday
      final dashboard = RecordDashboard.signedOut(aug1);

      // Monday is July 27
      expect(dashboard.weekDays.first.date, DateTime(2026, 7, 27));
      expect(dashboard.weekDays[5].date, aug1);
      expect(dashboard.weekDays[5].selected, isTrue);
    });
  });

  group('RecordEntryType enum', () {
    test('contains all expected types', () {
      expect(
        RecordEntryType.values,
        containsAll([
          RecordEntryType.meal,
          RecordEntryType.water,
          RecordEntryType.sleep,
          RecordEntryType.medication,
          RecordEntryType.mood,
          RecordEntryType.note,
        ]),
      );
    });
  });

  group('RecordTrendKind enum', () {
    test('contains bloodSugar and hydration', () {
      expect(
        RecordTrendKind.values,
        containsAll([RecordTrendKind.bloodSugar, RecordTrendKind.hydration]),
      );
    });
  });
}
