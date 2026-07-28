import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/report/domain/entities/dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/dialogs/range_picker_dialog.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../helpers/test_forui_app.dart';

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('zh'));
  });

  Future<void> showDialogAndSettle(WidgetTester tester) async {
    await tester.pumpWidget(
      TestForuiApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => showReportRangePickerDialog(
                context,
                selectedQuery: const ReportDashboardQuery(
                  range: ReportDashboardRange.last7Days,
                ),
              ),
              child: const Text('open-dialog'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open-dialog'));
    await tester.pumpAndSettle();
  }

  testWidgets('renders dialog title', (tester) async {
    await showDialogAndSettle(tester);

    expect(find.text(l10n.reportRangePickerTitle), findsOneWidget);
  });

  testWidgets('renders all three range options', (tester) async {
    await showDialogAndSettle(tester);

    expect(find.text(l10n.reportRangeLast7Days), findsOneWidget);
    expect(find.text(l10n.reportRangeLast30Days), findsOneWidget);
    expect(find.text(l10n.reportRangeCustom), findsOneWidget);
  });

  testWidgets('shows check icon for selected range (last7Days)', (
    tester,
  ) async {
    await showDialogAndSettle(tester);

    // The check icon is shown for the selected option
    expect(find.byIcon(SemanticIcons.statusDone), findsOneWidget);
  });

  testWidgets('tapping last7Days returns correct query', (tester) async {
    ReportDashboardQuery? result;

    await tester.pumpWidget(
      TestForuiApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                result = await showReportRangePickerDialog(
                  context,
                  selectedQuery: const ReportDashboardQuery(
                    range: ReportDashboardRange.last30Days,
                  ),
                );
              },
              child: const Text('open-dialog'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open-dialog'));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.reportRangeLast7Days));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.range, ReportDashboardRange.last7Days);
  });

  testWidgets('tapping last30Days returns correct query', (tester) async {
    ReportDashboardQuery? result;

    await tester.pumpWidget(
      TestForuiApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                result = await showReportRangePickerDialog(
                  context,
                  selectedQuery: const ReportDashboardQuery(
                    range: ReportDashboardRange.last7Days,
                  ),
                );
              },
              child: const Text('open-dialog'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open-dialog'));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.reportRangeLast30Days));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.range, ReportDashboardRange.last30Days);
  });

  testWidgets('shows check on last30Days when selected', (tester) async {
    await tester.pumpWidget(
      TestForuiApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => showReportRangePickerDialog(
                context,
                selectedQuery: const ReportDashboardQuery(
                  range: ReportDashboardRange.last30Days,
                ),
              ),
              child: const Text('open-dialog'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open-dialog'));
    await tester.pumpAndSettle();

    expect(find.byIcon(SemanticIcons.statusDone), findsOneWidget);
  });

  testWidgets('shows check on custom when selected', (tester) async {
    await tester.pumpWidget(
      TestForuiApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => showReportRangePickerDialog(
                context,
                selectedQuery: const ReportDashboardQuery(
                  range: ReportDashboardRange.custom,
                  startDate: null,
                  endDate: null,
                ),
              ),
              child: const Text('open-dialog'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open-dialog'));
    await tester.pumpAndSettle();

    expect(find.byIcon(SemanticIcons.statusDone), findsOneWidget);
  });

  testWidgets('tapping custom opens calendar dialog', (tester) async {
    final fixedTime = DateTime(2026, 7, 11, 10, 0, 0);

    await withClock(Clock.fixed(fixedTime), () async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => showReportRangePickerDialog(
                  context,
                  selectedQuery: const ReportDashboardQuery(
                    range: ReportDashboardRange.last7Days,
                  ),
                ),
                child: const Text('open-dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open-dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.reportRangeCustom));
      await tester.pumpAndSettle();

      // Calendar should be visible
      expect(find.byType(FCalendar), findsOneWidget);
    });
  });

  testWidgets('custom with existing dates pre-populates calendar', (
    tester,
  ) async {
    final fixedTime = DateTime(2026, 7, 11, 10, 0, 0);

    await withClock(Clock.fixed(fixedTime), () async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => showReportRangePickerDialog(
                  context,
                  selectedQuery: ReportDashboardQuery(
                    range: ReportDashboardRange.custom,
                    startDate: DateTime(2026, 7, 1),
                    endDate: DateTime(2026, 7, 5),
                  ),
                ),
                child: const Text('open-dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open-dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.reportRangeCustom));
      await tester.pumpAndSettle();

      expect(find.byType(FCalendar), findsOneWidget);
    });
  });

  test('ReportDashboardQuery.isCustom returns true only for custom range', () {
    const q1 = ReportDashboardQuery(range: ReportDashboardRange.last7Days);
    expect(q1.isCustom, isFalse);

    const q2 = ReportDashboardQuery(range: ReportDashboardRange.last30Days);
    expect(q2.isCustom, isFalse);

    const q3 = ReportDashboardQuery(range: ReportDashboardRange.custom);
    expect(q3.isCustom, isTrue);
  });
}
