import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/semantic_color.dart';
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

      test('creates 7 weekDays starting from Monday', () {
        // 2026-07-11 is Saturday, weekday = 6 (Mon=1)
        final date = DateTime(2026, 7, 11);
        final dashboard = RecordDashboard.signedOut(date);

        expect(dashboard.weekDays.length, 7);
        // Monday of that week is 2026-07-06
        expect(dashboard.weekDays[0].date, DateTime(2026, 7, 6));
        expect(dashboard.weekDays[0].weekdayKey, RecordCopyKey.weekdayMon);
        expect(dashboard.weekDays[6].date, DateTime(2026, 7, 12));
        expect(dashboard.weekDays[6].weekdayKey, RecordCopyKey.weekdaySun);
      });

      test('marks selected day in weekDays', () {
        final date = DateTime(2026, 7, 8); // Wednesday
        final dashboard = RecordDashboard.signedOut(date);

        final selectedDays = dashboard.weekDays.where((d) => d.selected);
        expect(selectedDays.length, 1);
        expect(selectedDays.first.day, 8);
      });

      test('weekDays have empty markers', () {
        final date = DateTime(2026, 7, 11);
        final dashboard = RecordDashboard.signedOut(date);

        for (final day in dashboard.weekDays) {
          expect(day.markers, isEmpty);
          expect(day.hasAlert, isFalse);
        }
      });

      test('has 5 default quick actions', () {
        final dashboard = RecordDashboard.signedOut(DateTime(2026, 7, 11));

        expect(dashboard.quickActions.length, 5);
        expect(
          dashboard.quickActions[0].type,
          RecordEntryType.meal,
        );
        expect(
          dashboard.quickActions[1].type,
          RecordEntryType.water,
        );
        expect(
          dashboard.quickActions[2].type,
          RecordEntryType.symptom,
        );
        expect(
          dashboard.quickActions[3].type,
          RecordEntryType.note,
        );
        expect(
          dashboard.quickActions[4].type,
          RecordEntryType.sleep,
        );
      });

      test('quick actions use neutral softColor and primary accent', () {
        final dashboard = RecordDashboard.signedOut(DateTime(2026, 7, 11));

        for (final action in dashboard.quickActions) {
          expect(action.accent, SemanticColor.primary);
          expect(action.softColor, SemanticColor.neutral);
          expect(action.locked, isFalse);
        }
      });

      test('has 5 default filters', () {
        final dashboard = RecordDashboard.signedOut(DateTime(2026, 7, 11));

        expect(dashboard.filters.length, 5);
        for (final filter in dashboard.filters) {
          expect(filter.selected, isFalse);
          expect(filter.locked, isFalse);
          expect(filter.accent, SemanticColor.primary);
        }
      });

      test('filter types match expected set', () {
        final dashboard = RecordDashboard.signedOut(DateTime(2026, 7, 11));

        final types = dashboard.filters.map((f) => f.type).toSet();
        expect(types.contains(RecordEntryType.water), isTrue);
        expect(types.contains(RecordEntryType.meal), isTrue);
        expect(types.contains(RecordEntryType.symptom), isTrue);
        expect(types.contains(RecordEntryType.sleep), isTrue);
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

    group('_emptyWeekDays — Monday calculation', () {
      test('handles Sunday (weekday=7)', () {
        // 2026-07-12 is Sunday
        final date = DateTime(2026, 7, 12);
        final dashboard = RecordDashboard.signedOut(date);

        // Monday should be 2026-07-06
        expect(dashboard.weekDays[0].date, DateTime(2026, 7, 6));
        expect(dashboard.weekDays[6].day, 12);
        expect(dashboard.weekDays[6].selected, isTrue);
      });

      test('handles Monday (weekday=1)', () {
        // 2026-07-06 is Monday
        final date = DateTime(2026, 7, 6);
        final dashboard = RecordDashboard.signedOut(date);

        expect(dashboard.weekDays[0].date, DateTime(2026, 7, 6));
        expect(dashboard.weekDays[0].selected, isTrue);
        expect(dashboard.weekDays[6].date, DateTime(2026, 7, 12));
      });

      test('handles month boundary', () {
        // 2026-08-01 is Saturday
        final date = DateTime(2026, 8, 1);
        final dashboard = RecordDashboard.signedOut(date);

        // Monday is 2026-07-27
        expect(dashboard.weekDays[0].date, DateTime(2026, 7, 27));
        expect(dashboard.weekDays[0].day, 27);
        expect(dashboard.weekDays[6].date, DateTime(2026, 8, 2));
      });
    });
  });

  group('RecordWeekDay', () {
    test('hasAlert defaults to false', () {
      final day = RecordWeekDay(
        date: DateTime(2026, 7, 6),
        day: 6,
        weekdayKey: RecordCopyKey.weekdayMon,
        selected: false,
        markers: const [],
      );
      expect(day.hasAlert, isFalse);
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
        icon: FLucideIcons.utensils,
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
        icon: FLucideIcons.cupSoda,
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
    test('has all expected types', () {
      expect(RecordEntryType.values.length, 11);
      expect(RecordEntryType.values.contains(RecordEntryType.meal), isTrue);
      expect(RecordEntryType.values.contains(RecordEntryType.water), isTrue);
      expect(RecordEntryType.values.contains(RecordEntryType.sleep), isTrue);
      expect(RecordEntryType.values.contains(RecordEntryType.note), isTrue);
    });
  });

  group('RecordTrendKind enum', () {
    test('has bloodSugar and hydration', () {
      expect(RecordTrendKind.values.length, 2);
      expect(RecordTrendKind.values.contains(RecordTrendKind.bloodSugar), isTrue);
      expect(RecordTrendKind.values.contains(RecordTrendKind.hydration), isTrue);
    });
  });
}
