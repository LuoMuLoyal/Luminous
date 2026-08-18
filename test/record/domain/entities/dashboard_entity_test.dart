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
