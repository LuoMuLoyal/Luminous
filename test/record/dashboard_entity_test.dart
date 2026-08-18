import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';

void main() {
  group('RecordDashboard', () {
    group('signedOut factory', () {
      test('creates dashboard with selectedDate', () {
        final date = DateTime(2026, 7, 11);
        final dashboard = RecordDashboard.signedOut(date);

        expect(dashboard.selectedDate, date);
        expect(dashboard.selectedDay, 11);
      });

      test('has 7 default quick actions', () {
        final dashboard = RecordDashboard.signedOut(DateTime(2026, 7, 11));

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

      test('quick actions use neutral softColor and primary accent', () {
        final dashboard = RecordDashboard.signedOut(DateTime(2026, 7, 11));

        for (final action in dashboard.quickActions) {
          expect(action.accent, SemanticColor.primary);
          expect(action.softColor, SemanticColor.neutral);
          expect(action.locked, isFalse);
        }
      });

      test('has 7 default filters', () {
        final dashboard = RecordDashboard.signedOut(DateTime(2026, 7, 11));

        expect(dashboard.filters.length, 7);
        for (final filter in dashboard.filters) {
          expect(filter.selected, isFalse);
          expect(filter.locked, isFalse);
          expect(filter.accent, SemanticColor.primary);
        }
      });

      test('filter types match expected set', () {
        final dashboard = RecordDashboard.signedOut(DateTime(2026, 7, 11));

        final types = dashboard.filters.map((f) => f.type).toSet();
        expect(types.contains(RecordEntryType.symptom), isTrue);
        expect(types.contains(RecordEntryType.medication), isTrue);
        expect(types.contains(RecordEntryType.water), isTrue);
        expect(types.contains(RecordEntryType.meal), isTrue);
        expect(types.contains(RecordEntryType.sleep), isTrue);
        expect(types.contains(RecordEntryType.mood), isTrue);
        expect(types.contains(RecordEntryType.note), isTrue);
      });

      test('has empty monthDays, timeline, trends', () {
        final dashboard = RecordDashboard.signedOut(DateTime(2026, 7, 11));

        expect(dashboard.monthDays, isEmpty);
        expect(dashboard.timeline, isEmpty);
        expect(dashboard.trends, isEmpty);
      });

      test('has empty summary items', () {
        final dashboard = RecordDashboard.signedOut(DateTime(2026, 7, 11));

        expect(dashboard.summary.items, isEmpty);
      });
    });
  });

  group('RecordCalendarDay', () {
    test('hasAlert defaults to false', () {
      const day = RecordCalendarDay(
        day: 1,
        inMonth: true,
        selected: false,
        markers: [],
      );
      expect(day.hasAlert, isFalse);
    });
  });

  group('RecordQuickAction', () {
    test('locked defaults to false', () {
      const action = RecordQuickAction(
        type: RecordEntryType.meal,
        icon: SemanticIcons.recordMeal,
        titleKey: RecordCopyKey.typeMeal,
        subtitleKey: RecordCopyKey.summaryTimesUnit,
        accent: SemanticColor.primary,
        softColor: SemanticColor.neutral,
      );
      expect(action.locked, isFalse);
    });
  });

  group('RecordFilter', () {
    test('locked defaults to false', () {
      const filter = RecordFilter(
        type: RecordEntryType.water,
        titleKey: RecordCopyKey.typeWater,
        icon: SemanticIcons.recordWater,
        accent: SemanticColor.primary,
        selected: false,
      );
      expect(filter.locked, isFalse);
    });
  });

  group('RecordCopyKey enum', () {
    test('has all weekday keys', () {
      expect(RecordCopyKey.weekdaySun, isNotNull);
      expect(RecordCopyKey.weekdayMon, isNotNull);
      expect(RecordCopyKey.weekdayTue, isNotNull);
      expect(RecordCopyKey.weekdayWed, isNotNull);
      expect(RecordCopyKey.weekdayThu, isNotNull);
      expect(RecordCopyKey.weekdayFri, isNotNull);
      expect(RecordCopyKey.weekdaySat, isNotNull);
    });

    test('has all type keys', () {
      expect(RecordCopyKey.typeMeal, isNotNull);
      expect(RecordCopyKey.typeVitals, isNotNull);
      expect(RecordCopyKey.typeWater, isNotNull);
      expect(RecordCopyKey.typeMood, isNotNull);
      expect(RecordCopyKey.typeSymptom, isNotNull);
      expect(RecordCopyKey.typeActivity, isNotNull);
      expect(RecordCopyKey.typeMedication, isNotNull);
      expect(RecordCopyKey.typeSleep, isNotNull);
      expect(RecordCopyKey.typeHeartRate, isNotNull);
      expect(RecordCopyKey.typeWeight, isNotNull);
      expect(RecordCopyKey.typeNote, isNotNull);
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
