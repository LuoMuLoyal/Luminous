import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';

void main() {
  group('todayDayMomentFromHour', () {
    test('returns morning for hour 0', () {
      expect(todayDayMomentFromHour(0), TodayDayMoment.morning);
    });

    test('returns morning for hour 6', () {
      expect(todayDayMomentFromHour(6), TodayDayMoment.morning);
    });

    test('returns morning for hour 11', () {
      expect(todayDayMomentFromHour(11), TodayDayMoment.morning);
    });

    test('returns afternoon for hour 12', () {
      expect(todayDayMomentFromHour(12), TodayDayMoment.afternoon);
    });

    test('returns afternoon for hour 15', () {
      expect(todayDayMomentFromHour(15), TodayDayMoment.afternoon);
    });

    test('returns afternoon for hour 17', () {
      expect(todayDayMomentFromHour(17), TodayDayMoment.afternoon);
    });

    test('returns evening for hour 18', () {
      expect(todayDayMomentFromHour(18), TodayDayMoment.evening);
    });

    test('returns evening for hour 23', () {
      expect(todayDayMomentFromHour(23), TodayDayMoment.evening);
    });
  });

  group('TodayWaterSummary.remainingCount', () {
    test('returns difference when target > completed', () {
      const summary = TodayWaterSummary(completedCount: 3, targetCount: 8);
      expect(summary.remainingCount, 5);
    });

    test('returns 0 when completed equals target', () {
      const summary = TodayWaterSummary(completedCount: 8, targetCount: 8);
      expect(summary.remainingCount, 0);
    });

    test('returns 0 when completed exceeds target', () {
      const summary = TodayWaterSummary(completedCount: 10, targetCount: 8);
      expect(summary.remainingCount, 0);
    });

    test('returns target when completed is 0', () {
      const summary = TodayWaterSummary(completedCount: 0, targetCount: 8);
      expect(summary.remainingCount, 8);
    });
  });

  group('TodayWaterSummary.progress', () {
    test('returns 0.0 when completed is 0', () {
      const summary = TodayWaterSummary(completedCount: 0, targetCount: 8);
      expect(summary.progress, 0.0);
    });

    test('returns ratio when partially completed', () {
      const summary = TodayWaterSummary(completedCount: 4, targetCount: 8);
      expect(summary.progress, 0.5);
    });

    test('returns 1.0 when completed equals target', () {
      const summary = TodayWaterSummary(completedCount: 8, targetCount: 8);
      expect(summary.progress, 1.0);
    });

    test('clamps to 1.0 when completed exceeds target', () {
      const summary = TodayWaterSummary(completedCount: 10, targetCount: 8);
      expect(summary.progress, 1.0);
    });
  });

  group('TodayDashboard.signedOut', () {
    test('derives moment from current hour', () {
      final expected = todayDayMomentFromHour(DateTime.now().hour);
      expect(TodayDashboard.signedOut().user.moment, expected);
    });

    test('has zero water completed', () {
      final dashboard = TodayDashboard.signedOut();
      expect(dashboard.water.completedCount, 0);
      expect(dashboard.water.targetCount, 8);
    });

    test('has zero medication', () {
      final dashboard = TodayDashboard.signedOut();
      expect(dashboard.medication.medicineCount, 0);
      expect(dashboard.medication.pendingCount, 0);
    });

    test('has empty vitals list', () {
      expect(TodayDashboard.signedOut().vitals, isEmpty);
    });

    test('has empty environment signals', () {
      expect(TodayDashboard.signedOut().environment.signals, isEmpty);
    });
  });
}
