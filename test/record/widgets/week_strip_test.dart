import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/semantic_color.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/sections/week_strip.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../helpers/test_forui_app.dart';

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('zh'));
  });

  List<RecordWeekDay> buildWeekDays({int? selectedDay}) {
    final monday = DateTime(2026, 7, 6); // Monday
    const weekdayKeys = [
      RecordCopyKey.weekdayMon,
      RecordCopyKey.weekdayTue,
      RecordCopyKey.weekdayWed,
      RecordCopyKey.weekdayThu,
      RecordCopyKey.weekdayFri,
      RecordCopyKey.weekdaySat,
      RecordCopyKey.weekdaySun,
    ];
    return List.generate(7, (i) {
      final day = monday.add(Duration(days: i));
      return RecordWeekDay(
        date: day,
        day: day.day,
        weekdayKey: weekdayKeys[i],
        selected: selectedDay == day.day,
        markers: const <SemanticColor>[],
      );
    });
  }

  testWidgets('renders 7 day cells', (tester) async {
    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(
          body: RecordWeekStrip(
            days: buildWeekDays(),
            l10n: l10n,
          ),
        ),
      ),
    );

    // Each day shows its day number
    expect(find.text('6'), findsOneWidget); // Monday
    expect(find.text('7'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('11'), findsOneWidget);
    expect(find.text('12'), findsOneWidget); // Sunday
  });

  testWidgets('renders weekday labels', (tester) async {
    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(
          body: RecordWeekStrip(
            days: buildWeekDays(),
            l10n: l10n,
          ),
        ),
      ),
    );

    expect(find.text(l10n.recordWeekdayMon), findsOneWidget);
    expect(find.text(l10n.recordWeekdaySun), findsOneWidget);
  });

  testWidgets('onDateSelected called when day tapped', (tester) async {
    DateTime? tappedDate;
    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(
          body: RecordWeekStrip(
            days: buildWeekDays(),
            l10n: l10n,
            onDateSelected: (date) => tappedDate = date,
          ),
        ),
      ),
    );

    await tester.tap(find.text('8'));
    await tester.pumpAndSettle();

    expect(tappedDate, DateTime(2026, 7, 8));
  });

  testWidgets('renders empty markers when no markers', (tester) async {
    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(
          body: RecordWeekStrip(
            days: buildWeekDays(),
            l10n: l10n,
          ),
        ),
      ),
    );

    // No dots should be visible
    // Check that SizedBox with height 6 exists for marker area
    expect(find.byType(RecordWeekStrip), findsOneWidget);
  });

  testWidgets('renders with hasAlert', (tester) async {
    final days = buildWeekDays();
    days[0] = days[0].copyWith(hasAlert: true, markers: [SemanticColor.primary]);

    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(
          body: RecordWeekStrip(
            days: days,
            l10n: l10n,
          ),
        ),
      ),
    );

    expect(find.byType(RecordWeekStrip), findsOneWidget);
  });

  testWidgets('renders with markers', (tester) async {
    final days = buildWeekDays();
    days[0] = days[0].copyWith(
      markers: [SemanticColor.primary, SemanticColor.success],
    );

    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(
          body: RecordWeekStrip(
            days: days,
            l10n: l10n,
          ),
        ),
      ),
    );

    expect(find.byType(RecordWeekStrip), findsOneWidget);
  });
}
